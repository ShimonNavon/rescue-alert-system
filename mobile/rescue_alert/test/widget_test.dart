import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

import 'package:rescue_alert/l10n/app_localizations.dart';

void main() {
  test('Localization returns Hebrew value', () {
    final he = AppLocalizations(const Locale('he'));
    expect(he.t('settings'), 'הגדרות');
  });

  test('Localization falls back to key', () {
    final en = AppLocalizations(const Locale('en'));
    expect(en.t('unknown_key'), 'unknown_key');
  });
}
