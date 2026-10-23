import '../theme/tokens.dart';

/// Shared timings, named by role. Values come from brand/motion.md.
abstract final class Motion {
  static const fast = MimiMotion.fast;
  static const hover = MimiMotion.hover;
  static const base = MimiMotion.med;
  static const slow = MimiMotion.keyframe;
  static const enter = MimiMotion.reveal;
  static const exit = MimiMotion.fast;
  static const stagger = MimiMotion.stagger;

  /// The signature curve: very fast start, long settle.
  static const ease = MimiMotion.easeBrand;
  static const uiEase = MimiMotion.easeUi;
}
