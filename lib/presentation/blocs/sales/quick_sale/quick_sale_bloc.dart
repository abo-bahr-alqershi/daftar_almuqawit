// ignore_for_file: public_member_api_docs

import 'package:bloc/bloc.dart';
import 'quick_sale_event.dart';
import 'quick_sale_state.dart';

class QuickSaleBloc extends Bloc<QuickSaleEvent, QuickSaleState> {
  QuickSaleBloc() : super(QuickSaleInitial()) {
    on<QuickSaleStarted>((event, emit) => emit(QuickSaleInitial()));
  }
}
