import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Font, size and weight only. Colors come from the theme or [AppPalette].
class AppTypography {
  static final TextStyle title = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    letterSpacing: 4.0,
  );

  static final TextStyle tileLetter = GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w800,
  );

  static final TextStyle bodyRegular = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static final TextStyle bodySecondary = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle bodyItalic = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    fontStyle: FontStyle.italic,
  );

  static final TextStyle keyLabel = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle buttonLabel = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle headerItalic = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );
}
