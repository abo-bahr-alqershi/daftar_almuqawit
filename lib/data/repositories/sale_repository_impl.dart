// ignore_for_file: public_member_api_docs

import '../../domain/entities/sale.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/local/sales_local_datasource.dart';
import '../models/sale_model.dart';
import '../../core/services/logger_service.dart';

class SaleRepositoryImpl implements SalesRepository {
  final SalesLocalDataSource local;
  final LoggerService _logger = LoggerService();
  
  SaleRepositoryImpl(this.local);

  Sale _fromModel(SaleModel m) => Sale(
        id: m.id,
        date: m.date,
        time: m.time,
        customerId: m.customerId,
        qatTypeId: m.qatTypeId,
        quantity: m.quantity,
        unit: m.unit,
        unitPrice: m.unitPrice,
        totalAmount: m.totalAmount,
        paymentStatus: m.paymentStatus,
        paidAmount: m.paidAmount,
        remainingAmount: m.remainingAmount,
        profit: m.profit,
        notes: m.notes,
      );

  SaleModel _toModel(Sale e) => SaleModel(
        id: e.id,
        date: e.date,
        time: e.time,
        customerId: e.customerId,
        qatTypeId: e.qatTypeId,
        quantity: e.quantity,
        unit: e.unit,
        unitPrice: e.unitPrice,
        totalAmount: e.totalAmount,
        paymentStatus: e.paymentStatus,
        paidAmount: e.paidAmount,
        remainingAmount: e.remainingAmount,
        profit: e.profit,
        notes: e.notes,
      );

  @override
  Future<int> add(Sale entity) async {
    try {
      final id = await local.insert(_toModel(entity));
      _logger.info('تمت إضافة بيع جديد', data: {'id': id, 'amount': entity.totalAmount});
      return id;
    } catch (e, s) {
      _logger.error('فشل إضافة البيع', error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await local.delete(id);
      _logger.info('تم حذف البيع', data: {'id': id});
    } catch (e, s) {
      _logger.error('فشل حذف البيع', error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<List<Sale>> getAll() async {
    try {
      final sales = (await local.getAll()).map(_fromModel).toList();
      _logger.d('تم جلب جميع المبيعات', data: {'count': sales.length});
      return sales;
    } catch (e, s) {
      _logger.error('فشل جلب المبيعات', error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<Sale?> getById(int id) async {
    try {
      final m = await local.getById(id);
      if (m == null) {
        _logger.debug('البيع غير موجود', data: {'id': id});
        return null;
      }
      return _fromModel(m);
    } catch (e, s) {
      _logger.error('فشل جلب البيع', error: e, stackTrace: s);
      rethrow;
    }
  }

  @override
  Future<List<Sale>> getByCustomer(int customerId) async {
    final models = await local.getByCustomer(customerId);
    return models.map(_fromModel).toList();
  }

  @override
  Future<List<Sale>> getByDate(String date) async {
    final models = await local.getByDate(date);
    return models.map(_fromModel).toList();
  }

  @override
  Future<List<Sale>> getTodaySales(String date) async {
    final models = await local.getToday(date);
    return models.map(_fromModel).toList();
  }

  @override
  Future<void> update(Sale entity) => local.update(_toModel(entity));
}
