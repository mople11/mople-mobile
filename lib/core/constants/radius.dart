import 'package:flutter/widgets.dart';

/// 어디가남 Design System — Corner radius tokens. Rounded, premium form language.
abstract final class AppRadius {
  AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xl2 = 28;
  static const double pill = 999;

  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXl2 = BorderRadius.all(Radius.circular(xl2));
  static const BorderRadius radiusPill = BorderRadius.all(
    Radius.circular(pill),
  );
}
