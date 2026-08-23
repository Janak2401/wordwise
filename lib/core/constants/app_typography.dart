import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static final TextStyle title = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 4.0,
    color: AppColors.textPrimary,
  );

  static final TextStyle tileLetter = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodyRegular = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static final TextStyle bodySecondary = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static final TextStyle bodyItalic = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary,
  );

  static final TextStyle keyLabel = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle buttonLabel = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static final TextStyle headerItalic = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary,
  );
}
