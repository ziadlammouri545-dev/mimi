import 'package:flutter/material.dart';

import 'mimi_text.dart';
import 'tokens.dart';

/// The one ThemeData. Dark only, the brand never designed a light theme.
/// Screens never set a color literal; they read this or MimiText.
ThemeData buildMimiTheme() {
  const scheme = ColorScheme.dark(
    primary: MimiColors.textCyan,
    onPrimary: MimiColors.bgPrimary,
    secondary: MimiColors.textCyanSoft,
    onSecondary: MimiColors.bgPrimary,
    surface: MimiColors.bgPrimary,
    onSurface: MimiColors.textWhite,
    surfaceContainerLow: MimiColors.bgSecondary,
    surfaceContainer: MimiColors.bgCard,
    surfaceContainerHigh: MimiColors.bgCardElevated,
    surfaceContainerHighest: MimiColors.bgHighlight,
    onSurfaceVariant: MimiColors.textMuted,
    outline: MimiColors.borderSoft,
    outlineVariant: MimiColors.borderSubtle,
    // The brand has no status hue. Errors read as white on the neutral ramp.
    error: MimiColors.textWhite,
    onError: MimiColors.bgPrimary,
  );
  const text = MimiText.standard;
  const accentSelection = Color.fromRGBO(168, 204, 216, MimiAlpha.border);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: MimiColors.bgPrimary,
    canvasColor: MimiColors.bgPrimary,
    fontFamily: MimiFonts.sans,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    focusColor: Colors.transparent,
    extensions: const [text],
    textTheme: TextTheme(
      displayLarge: text.display,
      displayMedium: text.headline,
      headlineLarge: text.headline,
      headlineMedium: text.title,
      titleLarge: text.title,
      titleMedium: text.ui,
      bodyLarge: text.lead,
      bodyMedium: text.body,
      bodySmall: text.bodySmall,
      labelLarge: text.button,
      labelMedium: text.uiSmall,
      labelSmall: text.label,
    ),
    iconTheme: const IconThemeData(color: MimiColors.textMuted, size: 20),
    dividerTheme: const DividerThemeData(
      color: MimiColors.borderSubtle,
      thickness: 1,
      space: 1,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: MimiColors.textCyan,
      selectionColor: accentSelection,
      selectionHandleColor: MimiColors.textCyan,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MimiColors.bgCard,
      hintStyle: text.ui.copyWith(color: MimiColors.textFaint),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Space.md,
        vertical: Space.sm,
      ),
      border: _inputBorder(MimiColors.borderSubtle),
      enabledBorder: _inputBorder(MimiColors.borderSubtle),
      focusedBorder: _inputBorder(MimiColors.borderCyan),
      errorBorder: _inputBorder(MimiColors.borderSoft),
      focusedErrorBorder: _inputBorder(MimiColors.borderCyan),
      errorStyle: text.uiSmall,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: const WidgetStatePropertyAll(3),
      radius: const Radius.circular(MimiRadius.btn),
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? MimiColors.borderSoft
            : const Color.fromRGBO(255, 255, 255, 0.05),
      ),
    ),
    dialogTheme: const DialogThemeData(
      backgroundColor: MimiColors.bgCardElevated,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(MimiRadius.lg)),
        side: BorderSide(color: MimiColors.borderSoft),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: MimiColors.bgCardElevated,
        border: Border.all(color: MimiColors.borderSoft),
        borderRadius: BorderRadius.circular(MimiRadius.sm),
      ),
      textStyle: text.uiSmall.copyWith(color: MimiColors.textWhite),
      waitDuration: MimiMotion.med,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: MimiColors.bgCardElevated,
      contentTextStyle: text.ui,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MimiRadius.btn),
        side: const BorderSide(color: MimiColors.borderSoft),
      ),
    ),
  );
}

OutlineInputBorder _inputBorder(Color color) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(MimiRadius.sm),
  borderSide: BorderSide(color: color),
);
