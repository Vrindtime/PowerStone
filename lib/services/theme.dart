import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animations/animations.dart';

ThemeData apptheme = ThemeData(
  useMaterial3: false,
  primaryColor: const Color.fromRGBO(39, 221, 127, 1),
  splashColor: const Color.fromRGBO(217, 217, 217, .25),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromRGBO(39, 221, 127, 1),
    brightness: Brightness.dark,
  ),
  scaffoldBackgroundColor: const Color.fromRGBO(42, 45, 44, 1),
  textTheme: TextTheme(
    labelLarge: GoogleFonts.inter(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ), //use .copyWith(attribute) to
    labelMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ), //change the properties,
    labelSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white,
    ),
    titleMedium: const TextStyle(fontSize: 12), // later on specific elements
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
    },
  ),
  visualDensity: VisualDensity.adaptivePlatformDensity,
);
