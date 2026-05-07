import 'package:flutter/material.dart';

class AppWidgetValues {
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16);
  static const EdgeInsets cardPadding = EdgeInsets.all(18);
  static const EdgeInsets actionBarPadding = EdgeInsets.fromLTRB(16, 8, 16, 16);

  static const double radiusMd = 16;
  static const double radiusLg = 22;
  static const double radiusXl = 24;

  static const double fieldSpacing = 12;
  static const double sectionSpacing = 16;
  static const double itemSpacing = 10;

  static const SizedBox section = SizedBox(height: sectionSpacing);
  static const SizedBox field = SizedBox(height: fieldSpacing);

  static BorderRadius get borderRadiusMd => BorderRadius.circular(radiusMd);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
  static BorderRadius get borderRadiusXl => BorderRadius.circular(radiusXl);

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      blurRadius: 12,
      offset: Offset(0, 6),
      color: Color(0x1A000000),
    ),
  ];
}