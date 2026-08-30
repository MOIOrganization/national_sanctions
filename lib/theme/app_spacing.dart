import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const double page = lg;
  static const double card = lg;
}

class AppRadius {
  AppRadius._();

  static const double standard = 12;
  static const double hero = 16;

  static const BorderRadius border = BorderRadius.all(
    Radius.circular(standard),
  );

  static const BorderRadius heroBorder = BorderRadius.all(
    Radius.circular(hero),
  );
}
