import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('he')];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static Locale localeResolutionCallback(
    Locale? locale,
    Iterable<Locale> supportedLocales,
  ) {
    if (locale == null) {
      return const Locale('en');
    }
    for (final supported in supportedLocales) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }
    return const Locale('en');
  }

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'No AppLocalizations found in context.');
    return localizations!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Rescue Alert',
      'loginTitle': 'Sign in',
      'email': 'Email',
      'password': 'Password',
      'login': 'Login',
      'logout': 'Logout',
      'map': 'Map',
      'dashboard': 'Dashboard',
      'messages': 'Message Queue',
      'record': 'Record',
      'stop': 'Stop',
      'settings': 'Settings',
      'send': 'Send',
      'reply': 'Reply',
      'groups': 'Groups',
      'language': 'Language',
      'hebrew': 'Hebrew',
      'english': 'English',
      'requestPermissions': 'Request Permissions',
      'messageDetails': 'Message Details',
    },
    'he': {
      'appTitle': 'התראת חילוץ',
      'loginTitle': 'התחברות',
      'email': 'אימייל',
      'password': 'סיסמה',
      'login': 'כניסה',
      'logout': 'התנתקות',
      'map': 'מפה',
      'dashboard': 'לוח בקרה',
      'messages': 'תור הודעות',
      'record': 'הקלט',
      'stop': 'עצור',
      'settings': 'הגדרות',
      'send': 'שלח',
      'reply': 'תגובה',
      'groups': 'קבוצות',
      'language': 'שפה',
      'hebrew': 'עברית',
      'english': 'אנגלית',
      'requestPermissions': 'בקש הרשאות',
      'messageDetails': 'פרטי הודעה',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']![key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'he'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}
