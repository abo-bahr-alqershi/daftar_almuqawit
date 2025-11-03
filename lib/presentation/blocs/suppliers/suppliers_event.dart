// ignore_for_file: public_member_api_docs

import '../../../domain/entities/supplier.dart';

abstract class SuppliersEvent {}

/// بدء تحميل الموردين
class LoadSuppliers extends SuppliersEvent {}

/// إضافة مورد جديد
class AddSupplierEvent extends SuppliersEvent {
  final Supplier supplier;
  AddSupplierEvent(this.supplier);
}

/// تحديث مورد
class UpdateSupplierEvent extends SuppliersEvent {
  final Supplier supplier;
  UpdateSupplierEvent(this.supplier);
}

/// حذف مورد
class DeleteSupplierEvent extends SuppliersEvent {
  final int id;
  DeleteSupplierEvent(this.id);
}

/// البحث في الموردين
class SearchSuppliersEvent extends SuppliersEvent {
  final String query;
  SearchSuppliersEvent(this.query);
}
