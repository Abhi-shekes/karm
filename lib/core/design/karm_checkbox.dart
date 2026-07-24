import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Karm's signature interaction: a hand-drawn ink-stroke checkmark that
/// draws on when a task is completed. This is the one deliberately
/// memorable moment in the app — everything else stays quiet by design.
///
/// Respects the system reduced-motion setting by snapping instantly
/// instead of animating the stroke.
class KarmCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;

  const KarmCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 24,
  });

  @override
  State<KarmCheckbox> createState() => _KarmCheckboxState();
}

class _KarmCheckboxState extends State<KarmCheckbox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _progress;

  static const _duration = Duration(milliseconds: 220);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
      value: widget.value ? 1 : 0,
    );
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  }

  @override
  void didUpdateWidget(covariant KarmCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value == widget.value) return;

    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduceMotion) {
      _controller.value = widget.value ? 1 : 0;
    } else if (widget.value) {
      _controller.forward(from: 0);
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    // Padding brings the tappable area up to a >=48dp target even though
    // the visible glyph stays small and quiet.
    final padding = ((48 - widget.size) / 2).clamp(0.0, double.infinity);

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) => CustomPaint(
            size: Size.square(widget.size),
            painter: _KarmCheckboxPainter(
              progress: _progress.value,
              borderColor: colors.inkMuted,
              fillColor: colors.sage,
              strokeColor: colors.paper,
            ),
          ),
        ),
      ),
    );
  }
}

class _KarmCheckboxPainter extends CustomPainter {
  final double progress;
  final Color borderColor;
  final Color fillColor;
  final Color strokeColor;

  _KarmCheckboxPainter({
    required this.progress,
    required this.borderColor,
    required this.fillColor,
    required this.strokeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(6),
    ).deflate(1);

    final borderPaint = Paint()
      ..color = borderColor.withValues(alpha: 1 - progress * 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRRect(rrect, borderPaint);

    if (progress <= 0) return;

    canvas.drawRRect(rrect, Paint()..color = fillColor.withValues(alpha: progress));

    final checkPath = Path()
      ..moveTo(size.width * 0.22, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.72)
      ..lineTo(size.width * 0.80, size.height * 0.28);

    final metric = checkPath.computeMetrics().first;
    final drawn = metric.extractPath(0, metric.length * progress.clamp(0.0, 1.0));

    canvas.drawPath(
      drawn,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _KarmCheckboxPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
