import 'package:flutter/widgets.dart';

class SupportedLocales {
  const SupportedLocales._();

  static const Locale english = Locale('en');
  static const Locale hebrew = Locale('he');

  static const List<Locale> all = <Locale>[english, hebrew];
}
