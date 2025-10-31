// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<SettingsStarted>((event, emit) => emit(SettingsInitial()));
  }
}
