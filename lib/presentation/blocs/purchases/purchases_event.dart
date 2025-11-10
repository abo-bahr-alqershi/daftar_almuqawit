/// أحداث Bloc المشتريات
/// تحتوي على جميع الأحداث المتعلقة بإدارة المشتريات

import '../../../domain/entities/purchase.dart';

/// الحدث الأساسي للمشتريات
abstract class PurchasesEvent {}

/// حدث تحميل جميع المشتريات
class LoadPurchases extends PurchasesEvent {}

/// حدث تحميل مشتريات اليوم
class LoadTodayPurchases extends PurchasesEvent {
  final String date;
  LoadTodayPurchases(this.date);
}

/// حدث تحميل مشتريات مورد معين
class LoadPurchasesBySupplier extends PurchasesEvent {
  final int supplierId;
  LoadPurchasesBySupplier(this.supplierId);
}

/// حدث إضافة مشترى جديد
class AddPurchaseEvent extends PurchasesEvent {
  final Purchase purchase;
  AddPurchaseEvent(this.purchase);
}

/// حدث تحديث مشترى
class UpdatePurchaseEvent extends PurchasesEvent {
  final Purchase purchase;
  UpdatePurchaseEvent(this.purchase);
}

/// حدث حذف مشترى
class DeletePurchaseEvent extends PurchasesEvent {
  final int id;
  DeletePurchaseEvent(this.id);
}

/// حدث إلغاء مشترى
class CancelPurchaseEvent extends PurchasesEvent {
  final int id;
  CancelPurchaseEvent(this.id);
}

/// حدث تحميل مشترى بواسطة المعرف
class LoadPurchaseById extends PurchasesEvent {
  final String purchaseId;
  LoadPurchaseById(this.purchaseId);
}
