import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

import '../tasks/domain/task_tile_data.dart';

class QuickAddResult {
  final String title;
  final DateTime? dueDate;
  final bool flagged;
  final List<String> tags;

  const QuickAddResult({
    required this.title,
    required this.dueDate,
    required this.flagged,
    required this.tags,
  });
}

/// Natural-language task parsing and daily-planning suggestions via
/// Gemini, called through the Firebase AI Logic client SDK (Gemini
/// Developer API backend — works on the free Spark plan, no Vertex/Blaze
/// needed) and gated by App Check.
class AiQuickAddService {
  AiQuickAddService(this._structuredModel, this._textModel);

  final GenerativeModel _structuredModel;
  final GenerativeModel _textModel;

  factory AiQuickAddService.create() {
    final schema = Schema.object(
      properties: {
        'title': Schema.string(
          description: 'The task title with date/time phrases removed, kept concise',
        ),
        'dueDateIso': Schema.string(
          description:
              'ISO-8601 date-time if the input mentions a date/time, otherwise an empty string',
        ),
        'flagged': Schema.boolean(
          description:
              'True if the input signals urgency or importance (e.g. "urgent", "important", "!!")',
        ),
        'tags': Schema.array(
          items: Schema.string(),
          description: 'Zero to three short lowercase category tags implied by the task',
        ),
      },
    );

    final structuredModel = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );
    final textModel = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');

    return AiQuickAddService(structuredModel, textModel);
  }

  Future<QuickAddResult> parse(String input) async {
    final now = DateTime.now();
    final prompt =
        'Current date/time: ${now.toIso8601String()} (${_weekdayName(now)}).\n'
        'Parse this quick-add task input into structured fields: "$input"';

    final response = await _structuredModel.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text == null || text.isEmpty) {
      throw StateError('The assistant returned an empty response.');
    }

    final json = jsonDecode(text) as Map<String, dynamic>;
    final dueDateIso = json['dueDateIso'] as String?;
    return QuickAddResult(
      title: (json['title'] as String? ?? input).trim(),
      dueDate: (dueDateIso == null || dueDateIso.isEmpty) ? null : DateTime.tryParse(dueDateIso),
      flagged: json['flagged'] as bool? ?? false,
      tags: List<String>.from(json['tags'] as List? ?? const []),
    );
  }

  Future<String> planMyDay(List<TaskTileData> tasks) async {
    if (tasks.isEmpty) return "You've got nothing on today — a good day to get ahead on something.";

    final list = tasks.map((t) {
      final due = t.dueDate == null ? '' : ' (due ${t.dueDate})';
      final flag = t.priority > 0 ? ' [flagged]' : '';
      return '- ${t.title}$due$flag';
    }).join('\n');

    final prompt =
        "Here's today's task list:\n$list\n\n"
        'In 2-4 short, direct sentences, suggest a sensible order to tackle these '
        'and call out anything overdue or time-sensitive. No fluff, no headers, plain prose.';

    final response = await _textModel.generateContent([Content.text(prompt)]);
    return response.text?.trim() ?? "Couldn't come up with a plan right now.";
  }

  String _weekdayName(DateTime dt) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dt.weekday - 1];
}
