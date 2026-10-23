import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../theme/theme_context.dart';
import '../theme/tokens.dart';
import 'status_dot.dart';

/// A selectable pill for presets and filters. Selected uses the highlight
/// surface with the accent border; there is no filled state.
class MimiChip extends StatefulWidget {
  const MimiChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  State<MimiChip> createState() => _MimiChipState();
}

class _MimiChipState extends State<MimiChip> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final on = widget.selected;
    final lit = on || _hovered;
    final color = lit ? MimiColors.textWhite : MimiColors.textMuted;
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(
            horizontal: Space.sm,
            vertical: Space.s2 - 2,
          ),
          decoration: BoxDecoration(
            color: on ? MimiColors.bgHighlight : Colors.transparent,
            border: Border.all(
              color: on
                  ? MimiColors.borderCyan
                  : _hovered
                  ? MimiColors.borderSoft
                  : MimiColors.borderSubtle,
            ),
            borderRadius: BorderRadius.circular(MimiRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 14, color: color),
                const SizedBox(width: Space.s1 + 2),
              ],
              Text(
                widget.label,
                style: context.text.uiSmall.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A tiny mono tag, 2px radius, for statuses and badges. Not tappable.
class MimiTag extends StatelessWidget {
  const MimiTag(
    this.label, {
    super.key,
    this.tone,
    this.accent = false,
    this.pulse = false,
  });

  final String label;
  final DotTone? tone;
  final bool accent;
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    final style = context.text.label.copyWith(
      color: accent ? MimiColors.textCyanSoft : MimiColors.textMuted,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Space.s2 - 2,
        vertical: Space.s1 - 2,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: accent ? MimiColors.borderCyan : MimiColors.borderSubtle,
        ),
        borderRadius: BorderRadius.circular(MimiRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tone != null) ...[
            StatusDot(tone: tone!, pulse: pulse, size: 5),
            const SizedBox(width: Space.s1 + 2),
          ],
          Text(label.toUpperCase(), style: style),
        ],
      ),
    );
  }
}
