// ignore_for_file: public_member_api_docs

import '../../domain/entities/purchase.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/local/purchase_local_datasource.dart';
import '../models/purchase_model.dart';

class PurchaseRepositoryImpl implements PurchaseRepository {
  final PurchaseLocalDataSource local;
  final InventoryRepository? inventoryRepository;
  
  PurchaseRepositoryImpl(this.local, {this.inventoryRepository});

  Purchase _fromModel(PurchaseModel m) => Purchase(
        id: m.id,
        date: m.date,
        time: m.time,
        supplierId: m.supplierId,
        qatTypeId: m.qatTypeId,
        quantity: m.quantity,
        unit: m.unit,
        unitPrice: m.unitPrice,
        totalAmount: m.totalAmount,
        paymentStatus: m.paymentStatus,
        paidAmount: m.paidAmount,
        remainingAmount: m.remainingAmount,
        notes: m.notes,
      );

  PurchaseModel _toModel(Purchase e) => PurchaseModel(
        id: e.id,
        date: e.date,
        time: e.time,
        supplierId: e.supplierId,
        qatTypeId: e.qatTypeId,
        quantity: e.quantity,
        unit: e.unit,
        unitPrice: e.unitPrice,
        totalAmount: e.totalAmount,
        paymentStatus: e.paymentStatus,
        paidAmount: e.paidAmount,
        remainingAmount: e.remainingAmount,
        notes: e.notes,
      );

  @override
  Future<int> add(Purchase entity) async {
    // إضافة عملية الشراء
    final purchaseId = await local.insert(_toModel(entity));
    
    // تحديث المخزون إذا كان متاحاً
    if (inventoryRepository != null && entity.quantity > 0) {
      try {
        await inventoryRepository!.updateStockFromPurchase(
          entity.qatTypeId ?? 0,
          entity.unit,
          entity.quantity,
          entity.unitPrice,
          'PUR-$purchaseId',
          purchaseId ?? 0,
        );
      } catch (e) {
        // في حالة فشل تحديث المخزون، نسجل الخطأ لكن لا نلغي العملية
        print('خطأ في تحديث المخزون من الشراء: $e');
      }
    }
    
    return purchaseId;
  }

  @override
  Future<void> delete(int id) => local.delete(id);

  @override
  Future<List<Purchase>> getAll() async => (await local.getAll()).map(_fromModel).toList();

  @override
  Future<Purchase?> getById(int id) async {
    final m = await local.getById(id);
    return m == null ? null : _fromModel(m);
  }

  @override
  Future<List<Purchase>> getBySupplier(int supplierId) async => (await local.getBySupplier(supplierId)).map(_fromModel).toList();

  @override
  Future<List<Purchase>> getByDate(String date) async => (await local.getByDate(date)).map(_fromModel).toList();

  @override
  Future<List<Purchase>> getTodayPurchases(String date) async => (await local.getToday(date)).map(_fromModel).toList();

  @override
  Future<List<Purchase>> getByQatType(int qatTypeId) async => (await local.getByQatType(qatTypeId)).map(_fromModel).toList();

  @override
  Future<void> update(Purchase entity) => local.update(_toModel(entity));
}
