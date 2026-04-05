import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocaleState {
  const LocaleState(this.locale);

  final Locale locale;
}

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(const LocaleState(Locale('en')));

  void setLocale(Locale locale) {
    emit(LocaleState(locale));
  }
}
