/// حالات Bloc الديون
/// تحتوي على جميع الحالات الممكنة لإدارة الديون

import 'package:equatable/equatable.dart';
import '../../../domain/entities/debt.dart';

/// الحالة الأساسية للديون
abstract class DebtsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class DebtsInitial extends DebtsState {}

/// حالة التحميل
class DebtsLoading extends DebtsState {}

/// حالة تحميل الديون بنجاح
class DebtsLoaded extends DebtsState {
  final List<Debt> debts;
  DebtsLoaded(this.debts);
  
  @override
  List<Object?> get props => [debts];
}

/// حالة حدوث خطأ
class DebtsError extends DebtsState {
  final String message;
  DebtsError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// حالة نجاح العملية
class DebtOperationSuccess extends DebtsState {
  final String message;
  DebtOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}
