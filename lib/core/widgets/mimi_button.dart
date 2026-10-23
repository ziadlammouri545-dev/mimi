import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../theme/theme_context.dart';
import '../theme/tokens.dart';
import 'status_dot.dart';

enum MimiButtonVariant { primary, secondary, ghost }

enum MimiButtonSize { standard, compact }

/// The three brand buttons. Primary is a 10% accent wash with a 20% border,
/// never a solid fill. Secondary is a bare link with a sweeping underline.
class MimiButton extends StatefulWidget {
  const MimiButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = MimiButtonVariant.primary,
    this.size = MimiButtonSize.standard,
    this.icon,
    this.trailingArrow = false,
    this.isLoading = false,
    this.expand = false,
  });

  const MimiButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingArrow = false,
    this.isLoading = false,
  }) : variant = MimiButtonVariant.secondary,
       size = MimiButtonSize.standard,
       expand = false;

  const MimiButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.size = MimiButtonSize.standard,
    this.icon,
    this.trailingArrow = false,
    this.isLoading = false,
    this.expand = false,
  }) : variant = MimiButtonVariant.ghost;

  final String label;
  final VoidCallback? onPressed;
  final MimiButtonVariant variant;
  final MimiButtonSize size;
  final IconData? icon;
  final bool trailingArrow;
  final bool isLoading;
  final bool expand;

  @override
  State<MimiButton> createState() => _MimiButtonState();
}

class _MimiButtonState extends State<MimiButton> {
  var _hovered = false;
  var _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final lit = _enabled && (_hovered || _pressed);
    final child = widget.variant == MimiButtonVariant.secondary
        ? _SecondaryBody(widget: widget, lit: lit)
        : _FilledBody(widget: widget, lit: lit);
    return MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: _enabled ? widget.onPressed : null,
        child: AnimatedOpacity(
          duration: Motion.fast,
          opacity: _enabled || widget.isLoading ? 1 : 0.45,
          child: child,
        ),
      ),
    );
  }
}

class _FilledBody extends StatelessWidget {
  const _FilledBody({required this.widget, required this.lit});

  final MimiButton widget;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    final primary = widget.variant == MimiButtonVariant.primary;
    final compact = widget.size == MimiButtonSize.compact;
    final fill = primary
        ? MimiColors.accent.withValues(alpha: lit ? 0.18 : MimiAlpha.fill)
        : Colors.transparent;
    final border = primary
        ? MimiColors.accent.withValues(
            alpha: lit ? MimiAlpha.borderHover : MimiAlpha.border,
          )
        : (lit ? MimiColors.borderSoft : MimiColors.borderSubtle);
    final textColor = primary || lit
        ? MimiColors.textWhite
        : MimiColors.textMuted;
    return AnimatedContainer(
      duration: Motion.fast,
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, lit && primary ? -1 : 0, 0),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? Space.s3 + 2 : Space.lg,
        vertical: compact ? Space.s2 + 2 : Space.sm,
      ),
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(MimiRadius.btn),
        boxShadow: lit && primary ? const [MimiShadow.glowHover] : null,
      ),
      child: _Label(widget: widget, color: textColor, lit: lit),
    );
  }
}

class _SecondaryBody extends StatelessWidget {
  const _SecondaryBody({required this.widget, required this.lit});

  final MimiButton widget;
  final bool lit;

  @override
  Widget build(BuildContext context) {
    final color = lit ? MimiColors.textWhite : MimiColors.textMuted;
    // The stack takes the label's width; the underline sweeps by scaling
    // from the left edge, so it needs no fractional sizing.
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: _Label(
            widget: widget,
            color: color,
            lit: lit,
            weightRegular: true,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedContainer(
            duration: Motion.hover,
            curve: Curves.easeOut,
            height: 1,
            transformAlignment: Alignment.centerLeft,
            transform: Matrix4.diagonal3Values(lit ? 1 : 0.001, 1, 1),
            color: MimiColors.textCyan,
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({
    required this.widget,
    required this.color,
    required this.lit,
    this.weightRegular = false,
  });

  final MimiButton widget;
  final Color color;
  final bool lit;
  final bool weightRegular;

  @override
  Widget build(BuildContext context) {
    final style = (weightRegular ? context.text.ui : context.text.button)
        .copyWith(color: color);
    return Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          const StatusDot(tone: DotTone.live, pulse: true),
          const SizedBox(width: Space.s2 + 2),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 16, color: color),
          const SizedBox(width: Space.s2 + 2),
        ],
        Flexible(child: Text(widget.label, style: style, maxLines: 1)),
        if (widget.trailingArrow) ...[
          const SizedBox(width: Space.s2 + 2),
          AnimatedSlide(
            duration: Motion.hover,
            curve: Curves.easeOut,
            offset: Offset(lit ? 0.2 : 0, 0),
            child: Icon(Icons.arrow_forward, size: 16, color: color),
          ),
        ],
      ],
    );
  }
}
