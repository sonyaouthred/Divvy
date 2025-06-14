import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// This class represents all the colors, themes, and decorations used
/// across the Divvy app.
class DivvyTheme {
  DivvyTheme._();

  // Theme colors
  static const Color background = Colors.white;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color darkGreen = Color(0xFF344E41);
  static const Color mediumGreen = Color(0xFF588157);
  static const Color lightGreen = Color(0xFFA3B18A);
  static const Color beige = Color(0xFFEEECE8);
  static const Color lightGrey = Color(0xFFA09D9D);
  static const Color darkGrey = Color(0xFF444444);
  static const Color darkBeige = Color(0xFFC1BDB4);
  static const Color brightRed = Color(0xFFFF0000);
  static const Color lightRed = Color(0xFFEA8484);
  static const Color darkRed = Color(0xFFA70000);
  static const Color shadow = Color(0xFFCFCFCF);
  static const Color altBeige = Color.fromARGB(255, 225, 223, 216);

  // Profile picture colors
  static const Color red = Color(0xFFF94144);
  static const Color orange = Color(0xFFF8961E);
  static const Color yellow = Color(0xFFF9C74F);
  static const Color green = Color(0xFF90BE6D);
  static const Color teal = Color(0xFF43AA8B);
  static const Color blue = Color(0xFF277DA1);
  static const Color purple = Color(0xFFB117D3);
  static const Color pink = Color(0xFFD82E7D);

  // Text Themes

  static TextStyle homeScreenTitle = GoogleFonts.baloo2(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w800,
      fontSize: 45,
      color: darkGreen,
    ),
  );
  static TextStyle screenTitle = GoogleFonts.baloo2(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 30,
      color: darkGreen,
    ),
  );

  static TextStyle largeHeaderRed = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 20,
      color: darkRed,
    ),
  );

  static TextStyle largeHeaderBlack = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: black,
    ),
  );
  static TextStyle largeBodyBlack = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 17,
      color: black,
    ),
  );
  static TextStyle largeHeaderGrey = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 20,
      color: darkGrey,
    ),
  );
  static TextStyle bodyBoldGrey = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: darkGrey,
    ),
  );
  static TextStyle bodyBoldBlack = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: black,
    ),
  );
  static TextStyle bodyBoldRed = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: darkRed,
    ),
  );
  static TextStyle bodyBlack = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 15,
      color: black,
    ),
  );
  static TextStyle bodyGreen = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 15,
      color: darkGreen,
    ),
  );
  static TextStyle smallBodyBlack = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 13,
      color: black,
    ),
  );
  static TextStyle bodyGrey = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 15,
      color: lightGrey,
    ),
  );
  static TextStyle smallBodyGrey = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 13,
      color: lightGrey,
    ),
  );
  static TextStyle detailGrey = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 11,
      color: lightGrey,
    ),
  );

  static TextStyle smallBodyWhite = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 13,
      color: white,
    ),
  );
  static TextStyle smallBodyRed = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 12,
      color: darkRed,
    ),
  );
  static TextStyle largeBoldMedGreen = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 20,
      color: mediumGreen,
    ),
  );
  static TextStyle largeBoldMedGrey = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 20,
      color: lightGrey,
    ),
  );
  static TextStyle largeBoldMedWhite = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 20,
      color: white,
    ),
  );
  static TextStyle smallBoldMedGreen = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 15,
      color: mediumGreen,
    ),
  );

  static TextStyle smallBoldMedGrey = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 15,
      color: lightGrey,
    ),
  );
  static TextStyle smallBoldMedWhite = GoogleFonts.inter(
    textStyle: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 15,
      color: white,
    ),
  );
  // Box decorations

  static BoxDecoration standardBox = BoxDecoration(
    color: DivvyTheme.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(color: DivvyTheme.shadow, blurRadius: 3, spreadRadius: 0),
    ],
  );

  static BoxDecoration greenBox = BoxDecoration(
    color: DivvyTheme.darkGreen,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(color: DivvyTheme.shadow, blurRadius: 5, spreadRadius: 2),
    ],
  );

  static BoxDecoration medGreenBox = BoxDecoration(
    color: DivvyTheme.mediumGreen,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(color: DivvyTheme.shadow, blurRadius: 5, spreadRadius: 2),
    ],
  );

  static BoxDecoration completeBox(bool isDone) => BoxDecoration(
    color: isDone ? DivvyTheme.mediumGreen : DivvyTheme.background,
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
      BoxShadow(color: DivvyTheme.shadow, blurRadius: 3, spreadRadius: 0),
    ],
  );

  static BoxDecoration box(Color color) => BoxDecoration(
    color: DivvyTheme.white,
    border: BoxBorder.all(color: color, width: 2),
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(color: DivvyTheme.shadow, blurRadius: 3, spreadRadius: 0),
    ],
  );

  static BoxDecoration circleWhite = BoxDecoration(
    color: DivvyTheme.white,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(color: DivvyTheme.shadow, blurRadius: 10, spreadRadius: 0),
    ],
  );

  static BoxDecoration oval(Color color) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(50),
    boxShadow: [
      BoxShadow(color: DivvyTheme.shadow, blurRadius: 10, spreadRadius: 0),
    ],
  );

  static BoxDecoration profileCircle(Color color) =>
      BoxDecoration(color: color, shape: BoxShape.circle);

  static BoxDecoration circleBeige = BoxDecoration(
    color: DivvyTheme.white,
    shape: BoxShape.circle,
    border: BoxBorder.all(color: DivvyTheme.shadow, width: 2),
  );

  static BoxDecoration textInput = BoxDecoration(
    color: DivvyTheme.white,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(color: DivvyTheme.shadow, blurRadius: 5, spreadRadius: 2),
    ],
  );
}
