// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc() : super(SyncInitial()) {
    on<SyncStarted>((event, emit) => emit(SyncInitial()));
  }
}
