import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pixel_colors.dart';

class PixelTextStyles {
  static TextStyle get appTitle =>
      GoogleFonts.pressStart2p(color: PixelColors.primary, fontSize: 13);

  static TextStyle get header =>
      GoogleFonts.pressStart2p(color: PixelColors.textPrimary, fontSize: 12);

  static TextStyle get body =>
      GoogleFonts.vt323(color: PixelColors.textPrimary, fontSize: 18);

  static TextStyle get bodyMuted =>
      GoogleFonts.vt323(color: PixelColors.textMuted, fontSize: 18);

  static TextStyle get sectionHeader => GoogleFonts.vt323(
    color: PixelColors.primary,
    fontSize: 18,
    letterSpacing: 2,
  );

  static TextStyle get amountBig =>
      GoogleFonts.pressStart2p(color: PixelColors.textPrimary, fontSize: 20);

  static TextStyle get buttonText =>
      GoogleFonts.pressStart2p(color: Colors.black, fontSize: 12);

  static TextStyle get bodySmall =>
      GoogleFonts.vt323(color: PixelColors.textMuted, fontSize: 14);

  static TextStyle get amountSmall =>
      GoogleFonts.pressStart2p(color: PixelColors.textPrimary, fontSize: 10);
}
