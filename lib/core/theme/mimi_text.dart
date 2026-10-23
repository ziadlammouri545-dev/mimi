import 'package:flutter/material.dart';

import 'tokens.dart';

/// Text styles named after brand/typography.md roles, never after sizes.
/// Mono roles expect uppercase input; MonoLabel does that for you.
class MimiText extends ThemeExtension<MimiText> {
  const MimiText({
    required this.display,
    required this.headline,
    required this.title,
    required this.metric,
    required this.lead,
    required this.body,
    required this.bodySmall,
    required this.ui,
    required this.button,
    required this.uiSmall,
    required this.label,
    required this.eyebrow,
    required this.micro,
    required this.mono,
  });

  final TextStyle display;
  final TextStyle headline;
  final TextStyle title;
  final TextStyle metric;
  final TextStyle lead;
  final TextStyle body;
  final TextStyle bodySmall;
  final TextStyle ui;
  final TextStyle button;
  final TextStyle uiSmall;
  final TextStyle label;
  final TextStyle eyebrow;
  final TextStyle micro;
  final TextStyle mono;

  static const standard = MimiText(
    display: TextStyle(
      fontFamily: MimiFonts.serif,
      fontSize: 40,
      fontWeight: MimiFontWeight.medium,
      height: MimiLineHeight.display,
      letterSpacing: 40 * MimiTracking.display,
      color: MimiColors.textWhite,
    ),
    headline: TextStyle(
      fontFamily: MimiFonts.serif,
      fontSize: MimiFontSize.sectionMin,
      fontWeight: MimiFontWeight.medium,
      height: 1.1,
      letterSpacing: MimiFontSize.sectionMin * MimiTracking.tight,
      color: MimiColors.textWhite,
    ),
    title: TextStyle(
      fontFamily: MimiFonts.serif,
      fontSize: MimiFontSize.cardTitle,
      fontWeight: MimiFontWeight.medium,
      height: MimiLineHeight.title,
      letterSpacing: MimiFontSize.cardTitle * MimiTracking.tight,
      color: MimiColors.textWhite,
    ),
    metric: TextStyle(
      fontFamily: MimiFonts.serif,
      fontSize: MimiFontSize.heroMin,
      fontWeight: MimiFontWeight.regular,
      height: 1,
      letterSpacing: MimiFontSize.heroMin * MimiTracking.tight,
      color: MimiColors.textWhite,
    ),
    lead: TextStyle(
      fontFamily: MimiFonts.body,
      fontSize: MimiFontSize.leadMax,
      fontWeight: MimiFontWeight.regular,
      height: 1.7,
      color: MimiColors.textMuted,
    ),
    body: TextStyle(
      fontFamily: MimiFonts.body,
      fontSize: MimiFontSize.body,
      fontWeight: MimiFontWeight.regular,
      height: MimiLineHeight.body,
      color: MimiColors.textMuted,
    ),
    bodySmall: TextStyle(
      fontFamily: MimiFonts.body,
      fontSize: 13,
      fontWeight: MimiFontWeight.regular,
      height: 1.6,
      color: MimiColors.textMuted,
    ),
    ui: TextStyle(
      fontFamily: MimiFonts.sans,
      fontSize: MimiFontSize.ui,
      fontWeight: MimiFontWeight.regular,
      height: 1.4,
      letterSpacing: MimiFontSize.ui * MimiTracking.ui,
      color: MimiColors.textWhite,
    ),
    button: TextStyle(
      fontFamily: MimiFonts.sans,
      fontSize: MimiFontSize.ui,
      fontWeight: MimiFontWeight.medium,
      height: 1.2,
      letterSpacing: MimiFontSize.ui * MimiTracking.ui,
      color: MimiColors.textWhite,
    ),
    uiSmall: TextStyle(
      fontFamily: MimiFonts.sans,
      fontSize: MimiFontSize.uiSmall,
      fontWeight: MimiFontWeight.regular,
      height: 1.4,
      color: MimiColors.textMuted,
    ),
    label: TextStyle(
      fontFamily: MimiFonts.mono,
      fontSize: MimiFontSize.label,
      fontWeight: MimiFontWeight.regular,
      height: 1.4,
      letterSpacing: MimiFontSize.label * MimiTracking.label,
      color: MimiColors.textFaint,
    ),
    eyebrow: TextStyle(
      fontFamily: MimiFonts.mono,
      fontSize: MimiFontSize.label,
      fontWeight: MimiFontWeight.regular,
      height: 1.4,
      letterSpacing: MimiFontSize.label * MimiTracking.eyebrow,
      color: MimiColors.textCyanSoft,
    ),
    micro: TextStyle(
      fontFamily: MimiFonts.mono,
      fontSize: MimiFontSize.micro,
      fontWeight: MimiFontWeight.regular,
      height: 1.4,
      letterSpacing: MimiFontSize.micro * MimiTracking.micro,
      color: MimiColors.textFaint,
    ),
    mono: TextStyle(
      fontFamily: MimiFonts.mono,
      fontSize: MimiFontSize.uiSmall,
      fontWeight: MimiFontWeight.light,
      height: 1.5,
      color: MimiColors.textCyanSoft,
    ),
  );

  @override
  MimiText copyWith() => this;

  @override
  MimiText lerp(MimiText? other, double t) =>
      t < 0.5 || other == null ? this : other;
}
