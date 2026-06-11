import 'package:flutter/widgets.dart';

class VTranslation {
  const VTranslation._();

  static const LocalizationsDelegate<dynamic> delegate =
      _NoopLocalizationDelegate();
}

class _NoopLocalizationDelegate extends LocalizationsDelegate<dynamic> {
  const _NoopLocalizationDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<dynamic> load(Locale locale) async => null;

  @override
  bool shouldReload(covariant LocalizationsDelegate<dynamic> old) => false;
}
