import '../base/base_usecase.dart';
import '../../entities/inventory_transaction.dart';
import '../../repositories/inventory_repository.dart';

/// حالة استخدام الحصول على حركات المخزون
class GetInventoryTransactions implements UseCase<List<InventoryTransaction>, GetInventoryTransactionsParams> {
  final InventoryRepository repository;

  const GetInventoryTransactions(this.repository);

  @override
  Future<List<InventoryTransaction>> call(GetInventoryTransactionsParams params) async {
    try {
      switch (params.filterType) {
        case TransactionFilterType.all:
          return await repository.getAllTransactions();
        
        case TransactionFilterType.byQatType:
          if (params.qatTypeId == null) {
            throw Exception('معرف نوع القات مطلوب للتصفية بنوع القات');
          }
          return await repository.getTransactionsByQatType(params.qatTypeId!);
        
        case TransactionFilterType.byType:
          if (params.transactionType == null || params.transactionType!.isEmpty) {
            throw Exception('نوع الحركة مطلوب للتصفية بنوع الحركة');
          }
          return await repository.getTransactionsByType(params.transactionType!);
        
        case TransactionFilterType.byDateRange:
          if (params.startDate == null || params.endDate == null) {
            throw Exception('تاريخ البداية والنهاية مطلوبان للتصفية بالفترة الزمنية');
          }
          return await repository.getTransactionsByDateRange(params.startDate!, params.endDate!);
      }
    } catch (e) {
      throw Exception('فشل في الحصول على حركات المخزون: $e');
    }
  }
}

/// معاملات الحصول على حركات المخزون
class GetInventoryTransactionsParams {
  final TransactionFilterType filterType;
  final int? qatTypeId;
  final String? transactionType;
  final String? startDate;
  final String? endDate;

  const GetInventoryTransactionsParams({
    this.filterType = TransactionFilterType.all,
    this.qatTypeId,
    this.transactionType,
    this.startDate,
    this.endDate,
  });

  /// إنشاء معاملات للحصول على جميع الحركات
  const GetInventoryTransactionsParams.all() : this();

  /// إنشاء معاملات للحصول على حركات نوع قات معين
  const GetInventoryTransactionsParams.byQatType(int qatTypeId) 
      : this(filterType: TransactionFilterType.byQatType, qatTypeId: qatTypeId);

  /// إنشاء معاملات للحصول على حركات نوع معين
  const GetInventoryTransactionsParams.byType(String transactionType) 
      : this(filterType: TransactionFilterType.byType, transactionType: transactionType);

  /// إنشاء معاملات للحصول على حركات في فترة زمنية
  const GetInventoryTransactionsParams.byDateRange(String startDate, String endDate) 
      : this(filterType: TransactionFilterType.byDateRange, startDate: startDate, endDate: endDate);
}

/// أنواع تصفية حركات المخزون
enum TransactionFilterType {
  all,
  byQatType,
  byType,
  byDateRange,
}

/// أنواع حركات المخزون المتاحة
class TransactionTypes {
  static const String purchase = 'شراء';
  static const String sale = 'بيع';
  static const String adjustment = 'تعديل';
  static const String transfer = 'تحويل';
  static const String damaged = 'تالف';
  static const String returned = 'مرتجع';
  static const String stockCount = 'جرد';

  static const List<String> all = [
    purchase,
    sale,
    adjustment,
    transfer,
    damaged,
    returned,
    stockCount,
  ];

  /// الحصول على لون مناسب لنوع الحركة
  static String getColorForType(String type) {
    switch (type) {
      case purchase:
      case returned:
        return 'green'; // حركات إيجابية
      case sale:
      case damaged:
        return 'red'; // حركات سلبية
      case adjustment:
      case stockCount:
        return 'blue'; // حركات تسوية
      case transfer:
        return 'orange'; // حركات تحويل
      default:
        return 'grey';
    }
  }

  /// الحصول على أيقونة مناسبة لنوع الحركة
  static String getIconForType(String type) {
    switch (type) {
      case purchase:
        return 'shopping_cart';
      case sale:
        return 'sell';
      case adjustment:
        return 'tune';
      case transfer:
        return 'swap_horiz';
      case damaged:
        return 'broken_image';
      case returned:
        return 'keyboard_return';
      case stockCount:
        return 'inventory';
      default:
        return 'history';
    }
  }
}
