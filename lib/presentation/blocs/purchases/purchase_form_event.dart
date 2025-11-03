/// أحداث Bloc نموذج المشتريات
abstract class PurchaseFormEvent {}

class LoadPurchaseForEdit extends PurchaseFormEvent {
  final String purchaseId;
  LoadPurchaseForEdit(this.purchaseId);
}

class PurchaseSupplierChanged extends PurchaseFormEvent {
  final String supplierId;
  PurchaseSupplierChanged(this.supplierId);
}

class PurchaseAmountChanged extends PurchaseFormEvent {
  final double amount;
  PurchaseAmountChanged(this.amount);
}

class SavePurchase extends PurchaseFormEvent {}
