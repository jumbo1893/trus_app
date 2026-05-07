import 'package:flutter/material.dart';

class AppInputDecorations {
  static InputDecoration filled({
    required String label,
    String? hint,
    String? errorText,
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
    );
  }

  static InputDecoration readOnly({
    required String label,
    String? hint,
    String? errorText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      suffixIcon: suffixIcon,
    );
  }

  static InputDecoration search({
    String hint = 'Hledat',
    Widget? suffixIcon,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      suffixIcon: suffixIcon,
      prefixIcon: prefixIcon,
    );
  }
}