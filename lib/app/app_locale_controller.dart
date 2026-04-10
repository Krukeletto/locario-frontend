import 'package:flutter/widgets.dart';

class AppLocaleController extends ChangeNotifier {
  Locale _locale = const Locale('pl');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) {
      return;
    }

    _locale = locale;
    notifyListeners();
  }
}
