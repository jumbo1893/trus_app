import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color accent;
  final Color accentSoft;
  /// Original orange used by older screens; kept separate so light mode does not visually change.
  final Color legacyAccent;
  final Color legacyAccentDark;
  final Color buttonForeground;
  final Color fieldTextAccent;
  final Color shadow;
  final Color border;
  final Color successSolid;
  final Color warningSolid;
  final Color errorSolid;
  final Color infoSolid;

  final Color backgroundPrimary;
  final Color backgroundSecondary;
  final Color cardBackground;

  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textMuted;
  final Color disabled;

  final Color infoBackground;
  final Color infoForeground;

  final Color warningBackground;
  final Color warningForeground;

  final Color errorBackground;
  final Color errorForeground;

  final Color successBackground;
  final Color successForeground;

  final Color overlayBackground;
  final Color navSelected;
  final Color navUnselected;

  final Color appBarHighlight;
  final Color appBarTopTint;
  final Color appBarCollapsedBackground;

  const AppColors({
    required this.accent,
    required this.accentSoft,
    required this.legacyAccent,
    required this.legacyAccentDark,
    required this.buttonForeground,
    required this.fieldTextAccent,
    required this.shadow,
    required this.border,
    required this.successSolid,
    required this.warningSolid,
    required this.errorSolid,
    required this.infoSolid,
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.cardBackground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textMuted,
    required this.disabled,
    required this.infoBackground,
    required this.infoForeground,
    required this.warningBackground,
    required this.warningForeground,
    required this.errorBackground,
    required this.errorForeground,
    required this.successBackground,
    required this.successForeground,
    required this.overlayBackground,
    required this.navSelected,
    required this.navUnselected,
    required this.appBarHighlight,
    required this.appBarTopTint,
    required this.appBarCollapsedBackground,
  });

  @override
  AppColors copyWith({
    Color? accent,
    Color? accentSoft,
    Color? legacyAccent,
    Color? legacyAccentDark,
    Color? buttonForeground,
    Color? fieldTextAccent,
    Color? shadow,
    Color? border,
    Color? successSolid,
    Color? warningSolid,
    Color? errorSolid,
    Color? infoSolid,
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? cardBackground,
    Color? textPrimary,
    Color? textTertiary,
    Color? textSecondary,
    Color? textMuted,
    Color? disabled,
    Color? infoBackground,
    Color? infoForeground,
    Color? warningBackground,
    Color? warningForeground,
    Color? errorBackground,
    Color? errorForeground,
    Color? successBackground,
    Color? successForeground,
    Color? overlayBackground,
    Color? navSelected,
    Color? navUnselected,
    Color? appBarHighlight,
    Color? appBarTopTint,
    Color? appBarCollapsedBackground,
  }) {
    return AppColors(
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      legacyAccent: legacyAccent ?? this.legacyAccent,
      legacyAccentDark: legacyAccentDark ?? this.legacyAccentDark,
      buttonForeground: buttonForeground ?? this.buttonForeground,
      fieldTextAccent: fieldTextAccent ?? this.fieldTextAccent,
      shadow: shadow ?? this.shadow,
      border: border ?? this.border,
      successSolid: successSolid ?? this.successSolid,
      warningSolid: warningSolid ?? this.warningSolid,
      errorSolid: errorSolid ?? this.errorSolid,
      infoSolid: infoSolid ?? this.infoSolid,
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      cardBackground: cardBackground ?? this.cardBackground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textMuted: textMuted ?? this.textMuted,
      disabled: disabled ?? this.disabled,
      infoBackground: infoBackground ?? this.infoBackground,
      infoForeground: infoForeground ?? this.infoForeground,
      warningBackground: warningBackground ?? this.warningBackground,
      warningForeground: warningForeground ?? this.warningForeground,
      errorBackground: errorBackground ?? this.errorBackground,
      errorForeground: errorForeground ?? this.errorForeground,
      successBackground: successBackground ?? this.successBackground,
      successForeground: successForeground ?? this.successForeground,
      overlayBackground: overlayBackground ?? this.overlayBackground,
      navSelected: navSelected ?? this.navSelected,
      navUnselected: navUnselected ?? this.navUnselected,
      appBarHighlight: appBarHighlight ?? this.appBarHighlight,
      appBarTopTint: appBarTopTint ?? this.appBarTopTint,
      appBarCollapsedBackground:
      appBarCollapsedBackground ?? this.appBarCollapsedBackground,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;

    return AppColors(
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      legacyAccent: Color.lerp(legacyAccent, other.legacyAccent, t)!,
      legacyAccentDark: Color.lerp(legacyAccentDark, other.legacyAccentDark, t)!,
      buttonForeground: Color.lerp(buttonForeground, other.buttonForeground, t)!,
      fieldTextAccent: Color.lerp(fieldTextAccent, other.fieldTextAccent, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      border: Color.lerp(border, other.border, t)!,
      successSolid: Color.lerp(successSolid, other.successSolid, t)!,
      warningSolid: Color.lerp(warningSolid, other.warningSolid, t)!,
      errorSolid: Color.lerp(errorSolid, other.errorSolid, t)!,
      infoSolid: Color.lerp(infoSolid, other.infoSolid, t)!,
      backgroundPrimary: Color.lerp(backgroundPrimary, other.backgroundPrimary, t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      infoBackground: Color.lerp(infoBackground, other.infoBackground, t)!,
      infoForeground: Color.lerp(infoForeground, other.infoForeground, t)!,
      warningBackground: Color.lerp(warningBackground, other.warningBackground, t)!,
      warningForeground: Color.lerp(warningForeground, other.warningForeground, t)!,
      errorBackground: Color.lerp(errorBackground, other.errorBackground, t)!,
      errorForeground: Color.lerp(errorForeground, other.errorForeground, t)!,
      successBackground: Color.lerp(successBackground, other.successBackground, t)!,
      successForeground: Color.lerp(successForeground, other.successForeground, t)!,
      overlayBackground: Color.lerp(overlayBackground, other.overlayBackground, t)!,
      navSelected: Color.lerp(navSelected, other.navSelected, t)!,
      navUnselected: Color.lerp(navUnselected, other.navUnselected, t)!,
      appBarHighlight: Color.lerp(appBarHighlight, other.appBarHighlight, t)!,
      appBarTopTint: Color.lerp(appBarTopTint, other.appBarTopTint, t)!,
      appBarCollapsedBackground: Color.lerp(
        appBarCollapsedBackground,
        other.appBarCollapsedBackground,
        t,
      )!,
    );
  }

  static const light = AppColors(
    accent: Color(0xFFF59E0B),
    accentSoft: Color(0xFFFFF7E6),
    legacyAccent: Color(0xFFFF8303),
    legacyAccentDark: Color(0xFFEE8303),
    buttonForeground: Colors.black,
    fieldTextAccent: Colors.indigo,
    shadow: Colors.black,
    border: Color(0xFFE5E7EB),
    successSolid: Colors.green,
    warningSolid: Colors.orange,
    errorSolid: Colors.red,
    infoSolid: Colors.blue,
    backgroundPrimary: Color(0xFFF5F6F8),
    backgroundSecondary: Color(0xFFF9FAFB),
    cardBackground: Colors.white,
    textPrimary: Color(0xFF111827),
    textSecondary: Color(0xFF4B5563),
    textTertiary: Colors.black87,
    textMuted: Color(0xFF6B7280),
    disabled: Color(0xFF9CA3AF),
    infoBackground: Color(0xFFEFF6FF),
    infoForeground: Color(0xFF2563EB),
    warningBackground: Color(0xFFFFF7ED),
    warningForeground: Color(0xFFD97706),
    errorBackground: Color(0xFFFEF2F2),
    errorForeground: Color(0xFFDC2626),
    successBackground: Color(0xFFF0FDF4),
    successForeground: Color(0xFF16A34A),
    overlayBackground: Color(0x66000000),
    navSelected: Color(0xFFF59E0B),
    navUnselected: Color(0xFF6B7280),
    appBarHighlight: Color(0xFFFFE082),
    appBarTopTint: Color(0x1AF59E0B),
    appBarCollapsedBackground: Color(0xFFF5F6F8),
  );

  static const dark = AppColors(
    accent: Color(0xFFF59E0B),
    accentSoft: Color(0xFF3B2A08),
    legacyAccent: Color(0xFFFF8303),
    legacyAccentDark: Color(0xFFEE8303),
    buttonForeground: Colors.black,
    fieldTextAccent: Color(0xFF93C5FD),
    shadow: Colors.black,
    border: Color(0xFF334155),
    successSolid: Color(0xFF4ADE80),
    warningSolid: Color(0xFFFBBF24),
    errorSolid: Color(0xFFF87171),
    infoSolid: Color(0xFF60A5FA),
    backgroundPrimary: Color(0xFF0F172A),
    backgroundSecondary: Color(0xFF111827),
    cardBackground: Color(0xFF1F2937),
    textPrimary: Color(0xFFF9FAFB),
    textSecondary: Color(0xFFD1D5DB),
    textTertiary: Colors.white70,
    textMuted: Color(0xFF9CA3AF),
    disabled: Color(0xFF6B7280),
    infoBackground: Color(0xFF1E3A5F),
    infoForeground: Color(0xFF60A5FA),
    warningBackground: Color(0xFF4A2E05),
    warningForeground: Color(0xFFFBBF24),
    errorBackground: Color(0xFF4C1D1D),
    errorForeground: Color(0xFFF87171),
    successBackground: Color(0xFF052E16),
    successForeground: Color(0xFF4ADE80),
    overlayBackground: Color(0x99000000),
    navSelected: Color(0xFFF59E0B),
    navUnselected: Color(0xFF9CA3AF),
    appBarHighlight: Color(0xFFFBBF24),
    appBarTopTint: Color(0x33F59E0B),
    appBarCollapsedBackground: Color(0xFF0F172A),
  );
}

extension AppColorsContextExtension on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}