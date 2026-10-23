import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A loading block that breathes instead of spinning. Things in Mimi
/// surface out of the dark; nothing rotates.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 14,
    this.radius = MimiRadius.xs,
  });

  const Skeleton.card({super.key, this.width, this.height = 96})
    : radius = MimiRadius.card;

  const Skeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = size;

  final double? width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: MimiMotion.fade,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context) && _breath.isAnimating) {
      _breath.stop();
    }
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, _) => Opacity(
        opacity: 0.55 + 0.45 * Curves.easeInOut.transform(_breath.value),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: MimiColors.bgCardElevated,
            border: Border.all(color: MimiColors.borderSubtle),
            borderRadius: BorderRadius.circular(widget.radius),
          ),
        ),
      ),
    );
  }
}

/// A few text-like lines, for lists that have not arrived yet.
class SkeletonLines extends StatelessWidget {
  const SkeletonLines({super.key, this.lines = 3});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines; i++) ...[
          if (i > 0) const SizedBox(height: Space.xs),
          FractionallySizedBox(
            widthFactor: i == lines - 1 ? 0.6 : 1 - i * 0.12,
            alignment: Alignment.centerLeft,
            child: const Skeleton(),
          ),
        ],
      ],
    );
  }
}
