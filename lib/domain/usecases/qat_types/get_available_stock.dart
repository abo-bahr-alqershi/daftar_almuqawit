/// حالة استخدام الحصول على المخزون المتاح لنوع القات
/// يحسب الكمية المتاحة بناءً على عمليات الشراء والبيع

import '../base/base_usecase.dart';
import '../../repositories/purchase_repository.dart';
import '../../repositories/sales_repository.dart';

/// حالة استخدام المخزون المتاح
class GetAvailableStock implements UseCase<Map<String, double>, GetAvailableStockParams> {
  final PurchaseRepository purchaseRepository;
  final SalesRepository salesRepository;

  const GetAvailableStock({
    required this.purchaseRepository,
    required this.salesRepository,
  });

  @override
  Future<Map<String, double>> call(GetAvailableStockParams params) async {
    // الحصول على جميع عمليات الشراء لهذا النوع
    final purchases = await purchaseRepository.getByQatType(params.qatTypeId);
    
    // الحصول على جميع عمليات البيع لهذا النوع
    final sales = await salesRepository.getByQatType(params.qatTypeId);

    // حساب الكمية المتاحة لكل وحدة
    final Map<String, double> availableStock = {};

    // جمع كميات الشراء
    for (final purchase in purchases) {
      if (purchase.status == 'نشط') {
        final unit = purchase.unit;
        availableStock[unit] = (availableStock[unit] ?? 0) + purchase.quantity;
      }
    }

    // طرح كميات البيع
    for (final sale in sales) {
      if (sale.status == 'نشط') {
        final unit = sale.unit;
        availableStock[unit] = (availableStock[unit] ?? 0) - sale.quantity;
      }
    }

    return availableStock;
  }
}

/// معاملات المخزون المتاح
class GetAvailableStockParams {
  final int qatTypeId;

  const GetAvailableStockParams({
    required this.qatTypeId,
  });
}
