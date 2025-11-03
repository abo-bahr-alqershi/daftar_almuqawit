/// أحداث Bloc نموذج العميل
/// تحتوي على جميع الأحداث المتعلقة بنموذج العميل

/// الحدث الأساسي لنموذج العميل
abstract class CustomerFormEvent {}

/// حدث تحميل بيانات العميل للتعديل
class LoadCustomerForEdit extends CustomerFormEvent {
  final String customerId;
  LoadCustomerForEdit(this.customerId);
}

/// حدث تغيير اسم العميل
class CustomerNameChanged extends CustomerFormEvent {
  final String name;
  CustomerNameChanged(this.name);
}

/// حدث تغيير رقم الهاتف
class CustomerPhoneChanged extends CustomerFormEvent {
  final String phone;
  CustomerPhoneChanged(this.phone);
}

/// حدث تغيير العنوان
class CustomerAddressChanged extends CustomerFormEvent {
  final String address;
  CustomerAddressChanged(this.address);
}

/// حدث حفظ العميل
class SaveCustomer extends CustomerFormEvent {}

/// حدث إعادة تعيين النموذج
class ResetCustomerForm extends CustomerFormEvent {}
