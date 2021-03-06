import 'package:flutter/material.dart';

class AppTheme {
  static final light = ThemeData(
    brightness: Brightness.light,
    primarySwatch: MaterialColor(Colors.black.value, const {
      50: Color(0xff919191),
      100: Color(0xff7b7b7b),
      200: Color(0xff656565),
      300: Color(0xff4f4f4f),
      400: Color(0xff393939),
      500: Color(0xff232323),
      600: Color(0xff0d0d0d),
      700: Color(0xff000000),
      800: Color(0xff000000),
      900: Color(0xff000000),
    }),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.teal,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
    }),
  );
}
