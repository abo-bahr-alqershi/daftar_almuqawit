import '../base/base_usecase.dart';
import '../../repositories/purchase_repository.dart';
import '../../repositories/sales_repository.dart';

/// حالة استخدام للتحقق من توفر الكمية في المخزون قبل البيع
///
/// يتحقق من أن الكمية المطلوبة متوفرة في المخزون من نفس نوع القات والوحدة
class CheckStockAvailability implements UseCase<StockCheckResult, CheckStockParams> {
  final PurchaseRepository purchaseRepository;
  final SalesRepository salesRepository;

  const CheckStockAvailability({
    required this.purchaseRepository,
    required this.salesRepository,
  });

  @override
  Future<StockCheckResult> call(CheckStockParams params) async {
    // الحصول على جميع عمليات الشراء النشطة لهذا النوع من القات
    final purchases = await purchaseRepository.getByQatType(params.qatTypeId);
    
    // الحصول على جميع عمليات البيع النشطة لهذا النوع من القات
    final sales = await salesRepository.getByQatType(params.qatTypeId);

    // حساب الكمية المتوفرة للوحدة المحددة
    double purchasedQuantity = 0;
    double soldQuantity = 0;

    // جمع كميات الشراء للوحدة المحددة
    for (final purchase in purchases) {
      if (purchase.unit == params.unit && purchase.status == 'نشط') {
        purchasedQuantity += purchase.quantity;
      }
    }

    // جمع كميات البيع للوحدة المحددة
    for (final sale in sales) {
      if (sale.unit == params.unit && sale.status == 'نشط') {
        // إذا كنا نقوم بتعديل عملية بيع موجودة، لا نحسب كميتها الحالية
        if (params.excludeSaleId == null || sale.id != params.excludeSaleId) {
          soldQuantity += sale.quantity;
        }
      }
    }

    // حساب الكمية المتاحة
    final availableQuantity = purchasedQuantity - soldQuantity;

    // التحقق من توفر الكمية المطلوبة
    final isAvailable = availableQuantity >= params.requestedQuantity;

    return StockCheckResult(
      isAvailable: isAvailable,
      availableQuantity: availableQuantity,
      requestedQuantity: params.requestedQuantity,
      unit: params.unit,
      purchasedQuantity: purchasedQuantity,
      soldQuantity: soldQuantity,
    );
  }
}

/// معاملات التحقق من المخزون
class CheckStockParams {
  final int qatTypeId;
  final String unit;
  final double requestedQuantity;
  final int? excludeSaleId; // لاستبعاد عملية بيع موجودة عند التعديل

  const CheckStockParams({
    required this.qatTypeId,
    required this.unit,
    required this.requestedQuantity,
    this.excludeSaleId,
  });
}

/// نتيجة التحقق من المخزون
class StockCheckResult {
  final bool isAvailable;
  final double availableQuantity;
  final double requestedQuantity;
  final String unit;
  final double purchasedQuantity;
  final double soldQuantity;

  const StockCheckResult({
    required this.isAvailable,
    required this.availableQuantity,
    required this.requestedQuantity,
    required this.unit,
    required this.purchasedQuantity,
    required this.soldQuantity,
  });

  double get shortage => requestedQuantity - availableQuantity;

  String get message {
    if (isAvailable) {
      return 'الكمية متوفرة في المخزون';
    } else {
      return 'الكمية المتاحة ($availableQuantity $unit) غير كافية. النقص: ${shortage.toStringAsFixed(2)} $unit';
    }
  }

  Map<String, dynamic> toJson() => {
    'isAvailable': isAvailable,
    'availableQuantity': availableQuantity,
    'requestedQuantity': requestedQuantity,
    'unit': unit,
    'purchasedQuantity': purchasedQuantity,
    'soldQuantity': soldQuantity,
    'shortage': shortage,
  };
}
