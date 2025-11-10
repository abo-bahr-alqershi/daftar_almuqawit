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

/// حالة تحميل تفاصيل دين بنجاح
class DebtDetailsLoaded extends DebtsState {
  final Debt debt;
  DebtDetailsLoaded(this.debt);
  
  @override
  List<Object?> get props => [debt];
}

/// حالة تحميل الديون المتأخرة بنجاح
class OverdueDebtsLoaded extends DebtsState {
  final List<Debt> overdueDebts;
  OverdueDebtsLoaded(this.overdueDebts);
  
  @override
  List<Object?> get props => [overdueDebts];
}

/// حالة إضافة دفعة بنجاح
class DebtPaymentAdded extends DebtsState {
  final String message;
  DebtPaymentAdded(this.message);
  
  @override
  List<Object?> get props => [message];
}
