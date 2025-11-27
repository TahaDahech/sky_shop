import 'package:flutter/material.dart';

/// Central place to configure the app theme.
ThemeData buildLightTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    useMaterial3: true,
  );
}


