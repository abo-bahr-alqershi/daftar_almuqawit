/// أحداث Bloc الديون
/// تحتوي على جميع الأحداث المتعلقة بإدارة الديون

import '../../../domain/entities/debt.dart';

/// الحدث الأساسي للديون
abstract class DebtsEvent {}

/// حدث تحميل جميع الديون
class LoadDebts extends DebtsEvent {}

/// حدث تحميل الديون المعلقة
class LoadPendingDebts extends DebtsEvent {}

/// حدث تحميل الديون المتأخرة
class LoadOverdueDebts extends DebtsEvent {}

/// حدث تحميل ديون شخص معين
class LoadDebtsByPerson extends DebtsEvent {
  final String personType;
  final int personId;
  LoadDebtsByPerson(this.personType, this.personId);
}

/// حدث إضافة دين جديد
class AddDebtEvent extends DebtsEvent {
  final Debt debt;
  AddDebtEvent(this.debt);
}

/// حدث تحديث دين
class UpdateDebtEvent extends DebtsEvent {
  final Debt debt;
  UpdateDebtEvent(this.debt);
}

/// حدث حذف دين
class DeleteDebtEvent extends DebtsEvent {
  final int id;
  DeleteDebtEvent(this.id);
}

/// حدث سداد دين
class PayDebtEvent extends DebtsEvent {
  final int id;
  final double amount;
  PayDebtEvent(this.id, this.amount);
}
