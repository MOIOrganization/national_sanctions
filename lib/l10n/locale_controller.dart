import 'package:flutter/material.dart';

class AppLocaleController extends ChangeNotifier {
  AppLocaleController({Locale locale = arabic}) : _locale = locale;

  static const Locale arabic = Locale('ar');
  static const Locale english = Locale('en');

  Locale _locale;

  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  void setLocale(Locale locale) {
    if (_locale == locale) {
      return;
    }

    _locale = locale;
    notifyListeners();
  }

  void toggle() {
    setLocale(isArabic ? english : arabic);
  }
}

class LocaleScope extends InheritedNotifier<AppLocaleController> {
  const LocaleScope({
    super.key,
    required AppLocaleController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppLocaleController of(BuildContext context) {
    final LocaleScope? scope = context
        .dependOnInheritedWidgetOfExactType<LocaleScope>();

    assert(scope != null, 'LocaleScope is missing from the widget tree.');

    return scope!.notifier!;
  }
}
