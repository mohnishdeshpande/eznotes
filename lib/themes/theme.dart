import 'package:flutter/material.dart';

const borderRadius = 24.0;
const borderWidth = 2.0;
const padding = 16.0;

class MyTheme {
  static InputDecorationTheme myInputDecoration(Color color) {
    return InputDecorationTheme(
      // padding
      contentPadding: const EdgeInsets.all(padding),
      isDense: false,
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      // borders
      enabledBorder: buildBorder(Colors.grey[600]!),
      disabledBorder: buildBorder(Colors.grey[300]!),
      focusedBorder: buildBorder(Colors.blue),
      errorBorder: buildBorder(Colors.red),
    );
  }

  static OutlineInputBorder buildBorder(Color color, {bool isNote = false}) {
    return OutlineInputBorder(
      borderRadius: const BorderRadius.all(
        Radius.circular(borderRadius),
      ),
      borderSide: BorderSide(
        color: color,
        width: (isNote) ? borderWidth * 2 : borderWidth,
      ),
    );
  }

  static ElevatedButtonThemeData myElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: const StadiumBorder(),
      ),
    );
  }

  static TextStyle myTextStyle() {
    return TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 16,
      color: Colors.grey[600],
    );
  }
}
