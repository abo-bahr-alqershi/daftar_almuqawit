/// أحداث Bloc نموذج المورد
/// تحتوي على جميع الأحداث المتعلقة بنموذج المورد

/// الحدث الأساسي لنموذج المورد
abstract class SupplierFormEvent {}

/// حدث تحميل بيانات المورد للتعديل
class LoadSupplierForEdit extends SupplierFormEvent {
  final String supplierId;
  LoadSupplierForEdit(this.supplierId);
}

/// حدث تغيير اسم المورد
class SupplierNameChanged extends SupplierFormEvent {
  final String name;
  SupplierNameChanged(this.name);
}

/// حدث تغيير رقم الهاتف
class SupplierPhoneChanged extends SupplierFormEvent {
  final String phone;
  SupplierPhoneChanged(this.phone);
}

/// حدث تغيير العنوان
class SupplierAddressChanged extends SupplierFormEvent {
  final String address;
  SupplierAddressChanged(this.address);
}

/// حدث حفظ المورد
class SaveSupplier extends SupplierFormEvent {}

/// حدث إعادة تعيين النموذج
class ResetSupplierForm extends SupplierFormEvent {}
