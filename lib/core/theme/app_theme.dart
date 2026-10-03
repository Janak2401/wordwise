import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

/// Colors that change between light and dark mode. Read with `AppPalette.of(context)`
/// instead of picking `AppColors.x` / `AppColors.lightX` by hand.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color borderBright;
  final Color absent;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.borderBright,
    required this.absent,
  });

  static const dark = AppPalette(
    background: AppColors.background,
    surface: AppColors.surface,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    border: AppColors.border,
    borderBright: AppColors.borderBright,
    absent: AppColors.absent,
  );

  static const light = AppPalette(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    border: AppColors.lightBorder,
    borderBright: AppColors.lightBorderBright,
    absent: AppColors.keyAbsentLight,
  );

  static AppPalette of(BuildContext context) => Theme.of(context).extension<AppPalette>() ?? dark;

  @override
  AppPalette copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? borderBright,
    Color? absent,
  }) {
    return AppPalette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      borderBright: borderBright ?? this.borderBright,
      absent: absent ?? this.absent,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderBright: Color.lerp(borderBright, other.borderBright, t)!,
      absent: Color.lerp(absent, other.absent, t)!,
    );
  }
}

class AppTheme {
  static ThemeData get darkTheme => _build(Brightness.dark, AppPalette.dark);

  static ThemeData get lightTheme => _build(Brightness.light, AppPalette.light);

  static ThemeData _build(Brightness brightness, AppPalette palette) {
    final isDark = brightness == Brightness.dark;
    final baseScheme = isDark ? const ColorScheme.dark() : const ColorScheme.light();
    final baseText = isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

    return ThemeData(
      brightness: brightness,
      scaffoldBackgroundColor: palette.background,
      colorScheme: baseScheme.copyWith(
        surface: palette.surface,
        primary: AppColors.correct,
        secondary: AppColors.wrongPosition,
        error: AppColors.errorRed,
      ),
      dividerColor: palette.border,
      // Text without an explicit color falls back to the palette's primary text color.
      textTheme: GoogleFonts.interTextTheme(baseText).apply(
        bodyColor: palette.textPrimary,
        displayColor: palette.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.textSecondary),
      ),
      extensions: [palette],
    );
  }
}
