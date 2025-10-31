// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'statistics_event.dart';
import 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  StatisticsBloc() : super(StatisticsInitial()) {
    on<StatisticsStarted>((event, emit) => emit(StatisticsInitial()));
  }
}
