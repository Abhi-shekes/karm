import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme_mode_provider.dart';
import '../../../core/design/app_colors.dart';
import '../../../core/design/app_text_styles.dart';
import '../../auth/application/auth_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final type = context.textStyles;
    final themeMode = ref.watch(appThemeModeProvider);
    final user = ref.watch(authStateChangesProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (user != null) ...[
            Text(user.displayName ?? user.email ?? 'Signed in', style: type.taskTitle),
            if (user.email != null) ...[
              const SizedBox(height: 2),
              Text(user.email!, style: type.taskNotes),
            ],
            const SizedBox(height: 28),
          ],
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.people_outline, color: colors.ink),
            title: Text('Friends', style: type.taskTitle),
            trailing: Icon(Icons.chevron_right, color: colors.inkMuted),
            onTap: () => context.push('/friends'),
          ),
          const SizedBox(height: 20),
          Text('Appearance', style: type.sectionTitle),
          const SizedBox(height: 10),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) =>
                ref.read(appThemeModeProvider.notifier).set(selection.first),
          ),
          const SizedBox(height: 36),
          OutlinedButton(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}
