/// أحداث Bloc نموذج المبيعات
/// تحتوي على جميع الأحداث المتعلقة بنموذج المبيعات

/// الحدث الأساسي لنموذج المبيعات
abstract class SaleFormEvent {}

/// حدث تحميل بيانات المبيعة للتعديل
class LoadSaleForEdit extends SaleFormEvent {
  final String saleId;
  LoadSaleForEdit(this.saleId);
}

/// حدث تغيير العميل
class SaleCustomerChanged extends SaleFormEvent {
  final String customerId;
  SaleCustomerChanged(this.customerId);
}

/// حدث تغيير المبلغ
class SaleAmountChanged extends SaleFormEvent {
  final double amount;
  SaleAmountChanged(this.amount);
}

/// حدث إضافة منتج
class AddProductToSale extends SaleFormEvent {
  final String productId;
  final int quantity;
  AddProductToSale(this.productId, this.quantity);
}

/// حدث حفظ المبيعة
class SaveSale extends SaleFormEvent {}

/// حدث إعادة تعيين النموذج
class ResetSaleForm extends SaleFormEvent {}
