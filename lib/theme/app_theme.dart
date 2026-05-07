import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_widget_values.dart';

class AppTheme {
  static ThemeData light() {
    return _buildTheme(
      appColors: AppColors.light,
      brightness: Brightness.light,
      overlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  static ThemeData dark() {
    return _buildTheme(
      appColors: AppColors.dark,
      brightness: Brightness.dark,
      overlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  static ThemeData _buildTheme({
    required AppColors appColors,
    required Brightness brightness,
    required SystemUiOverlayStyle overlayStyle,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: appColors.accent,
      brightness: brightness,
    ).copyWith(
      primary: appColors.accent,
      secondary: appColors.accent,
      surface: appColors.cardBackground,
      onSurface: appColors.textPrimary,
      error: appColors.errorForeground,
      onPrimary: brightness == Brightness.dark ? Colors.black : Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: appColors.backgroundPrimary,
      extensions: [appColors],
    );

    return base.copyWith(
      cardColor: appColors.cardBackground,

      iconTheme: base.iconTheme.copyWith(
        color: appColors.accent,
      ),

      textTheme: base.textTheme.copyWith(
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: appColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 14,
          color: appColors.textSecondary,
        ),
        bodyMedium: TextStyle(
          fontSize: 13,
          color: appColors.textSecondary,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: appColors.textMuted,
        ),
        labelMedium: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: appColors.textSecondary,
        ),
      ),


      cardTheme: CardThemeData(
        color: appColors.cardBackground,
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: AppWidgetValues.borderRadiusXl,
        ),
        shadowColor: Colors.black.withAlpha(30),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: appColors.textPrimary,
        unselectedLabelColor: appColors.textMuted,
        indicatorColor: appColors.accent,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        indicatorSize: TabBarIndicatorSize.label,
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: appColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: appColors.textPrimary),
        actionsIconTheme: IconThemeData(color: appColors.textPrimary),
        titleTextStyle: TextStyle(
          color: appColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: overlayStyle,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: appColors.backgroundSecondary,
        labelStyle: TextStyle(color: appColors.textSecondary),
        hintStyle: TextStyle(color: appColors.textMuted),
        errorStyle: TextStyle(color: appColors.errorForeground),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: AppWidgetValues.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppWidgetValues.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppWidgetValues.borderRadiusMd,
          borderSide: BorderSide(
            color: appColors.accent,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppWidgetValues.borderRadiusMd,
          borderSide: BorderSide(
            color: appColors.errorForeground,
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppWidgetValues.borderRadiusMd,
          borderSide: BorderSide(
            color: appColors.errorForeground,
            width: 1.4,
          ),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          backgroundColor: appColors.accent,
          foregroundColor: brightness == Brightness.dark
              ? Colors.black
              : appColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: appColors.disabled.withAlpha(90)),
          foregroundColor: appColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: appColors.accent,
        foregroundColor: brightness == Brightness.dark
            ? Colors.black
            : appColors.textPrimary,
        elevation: 4,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: appColors.navSelected,
        unselectedItemColor: appColors.navUnselected,
        selectedIconTheme: IconThemeData(color: appColors.navSelected),
        unselectedIconTheme: IconThemeData(color: appColors.navUnselected),
        backgroundColor: brightness == Brightness.dark
            ? appColors.backgroundSecondary
            : appColors.cardBackground,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: appColors.accent,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: appColors.textPrimary,
        textColor: appColors.textPrimary,
      ),

      dividerColor: appColors.disabled.withAlpha(50),
    );
  }
}