import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.black,
      primary: Colors.black,
      secondary: Colors.grey.shade600,
      background: Colors.white,
      surface: Colors.grey.shade100,
      surfaceVariant: Colors.grey.shade50,
      onPrimary: Colors.white,
      onBackground: Colors.black87,
      error: Colors.red,
      onSurface: Colors.black87,
      onSurfaceVariant: Colors.grey.shade700,
    ),

    extensions: <ThemeExtension<dynamic>>[
      CustomColors(
        avatarBackground: Colors.blueGrey.withAlpha(25),
      ),
    ],

    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black54,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
      ),
    ),
  );
}

class CustomColors extends ThemeExtension<CustomColors> {
  final Color? avatarBackground;

  const CustomColors({this.avatarBackground});

  @override
  CustomColors copyWith({Color? avatarBackground}) {
    return CustomColors(
      avatarBackground: avatarBackground ?? this.avatarBackground,
    );
  }

  @override
  CustomColors lerp(ThemeExtension<CustomColors>? other, double t) {
    if (other is! CustomColors) return this;
    return CustomColors(
      avatarBackground: Color.lerp(avatarBackground, other.avatarBackground, t),
    );
  }
}
