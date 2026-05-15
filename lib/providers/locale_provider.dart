import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = WidgetsBinding.instance.platformDispatcher.locale;

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  void updateFromSystem() {
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    if (_locale != systemLocale) {
      _locale = systemLocale;
      notifyListeners();
    }
  }
}
