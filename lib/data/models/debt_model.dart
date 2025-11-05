/// نموذج الدين
/// يحتوي على معلومات الدين الكاملة وسجل المدفوعات

import 'base/base_model.dart';
import '../database/tables/debts_table.dart';

/// نموذج بيانات الدين
class DebtModel extends BaseModel {
  final int? id;
  final String personType;
  final int personId;
  final String personName;
  final String? transactionType;
  final int? transactionId;
  final double originalAmount;
  final double paidAmount;
  final double remainingAmount;
  final String date;
  final String? dueDate;
  final String status;
  final String? lastPaymentDate;
  final String? notes;

  const DebtModel({
    this.id,
    required this.personType,
    required this.personId,
    required this.personName,
    this.transactionType,
    this.transactionId,
    required this.originalAmount,
    this.paidAmount = 0,
    required this.remainingAmount,
    required this.date,
    this.dueDate,
    this.status = 'غير مسدد',
    this.lastPaymentDate,
    this.notes,
  });

  factory DebtModel.fromMap(Map<String, Object?> map) => DebtModel(
        id: map[DebtsTable.cId] as int?,
        personType: map[DebtsTable.cPersonType] as String,
        personId: map[DebtsTable.cPersonId] as int,
        personName: map[DebtsTable.cPersonName] as String,
        transactionType: map[DebtsTable.cTransactionType] as String?,
        transactionId: map[DebtsTable.cTransactionId] as int?,
        originalAmount: (map[DebtsTable.cOriginalAmount] as num).toDouble(),
        paidAmount: (map[DebtsTable.cPaidAmount] as num?)?.toDouble() ?? 0,
        remainingAmount: (map[DebtsTable.cRemainingAmount] as num).toDouble(),
        date: map[DebtsTable.cDate] as String,
        dueDate: map[DebtsTable.cDueDate] as String?,
        status: (map[DebtsTable.cStatus] as String?) ?? 'غير مسدد',
        lastPaymentDate: map[DebtsTable.cLastPaymentDate] as String?,
        notes: map[DebtsTable.cNotes] as String?,
      );

  /// إنشاء نموذج من JSON
  factory DebtModel.fromJson(Map<String, dynamic> json) => DebtModel(
        id: json['id'] as int?,
        personType: json['personType'] as String,
        personId: json['personId'] as int,
        personName: json['personName'] as String,
        transactionType: json['transactionType'] as String?,
        transactionId: json['transactionId'] as int?,
        originalAmount: (json['originalAmount'] as num).toDouble(),
        paidAmount: (json['paidAmount'] as num?)?.toDouble() ?? 0,
        remainingAmount: (json['remainingAmount'] as num).toDouble(),
        date: json['date'] as String,
        dueDate: json['dueDate'] as String?,
        status: (json['status'] as String?) ?? 'غير مسدد',
        lastPaymentDate: json['lastPaymentDate'] as String?,
        notes: json['notes'] as String?,
      );

  @override
  Map<String, Object?> toMap() => {
        DebtsTable.cId: id,
        DebtsTable.cPersonType: personType,
        DebtsTable.cPersonId: personId,
        DebtsTable.cPersonName: personName,
        DebtsTable.cTransactionType: transactionType,
        DebtsTable.cTransactionId: transactionId,
        DebtsTable.cOriginalAmount: originalAmount,
        DebtsTable.cPaidAmount: paidAmount,
        DebtsTable.cRemainingAmount: remainingAmount,
        DebtsTable.cDate: date,
        DebtsTable.cDueDate: dueDate,
        DebtsTable.cStatus: status,
        DebtsTable.cLastPaymentDate: lastPaymentDate,
        DebtsTable.cNotes: notes,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'personType': personType,
        'personId': personId,
        'personName': personName,
        'transactionType': transactionType,
        'transactionId': transactionId,
        'originalAmount': originalAmount,
        'paidAmount': paidAmount,
        'remainingAmount': remainingAmount,
        'date': date,
        'dueDate': dueDate,
        'status': status,
        'lastPaymentDate': lastPaymentDate,
        'notes': notes,
      };

  @override
  DebtModel copyWith({
    int? id,
    String? personType,
    int? personId,
    String? personName,
    String? transactionType,
    int? transactionId,
    double? originalAmount,
    double? paidAmount,
    double? remainingAmount,
    String? date,
    String? dueDate,
    String? status,
    String? lastPaymentDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firebaseId,
    String? syncStatus,
  }) =>
      DebtModel(
        id: id ?? this.id,
        personType: personType ?? this.personType,
        personId: personId ?? this.personId,
        personName: personName ?? this.personName,
        transactionType: transactionType ?? this.transactionType,
        transactionId: transactionId ?? this.transactionId,
        originalAmount: originalAmount ?? this.originalAmount,
        paidAmount: paidAmount ?? this.paidAmount,
        remainingAmount: remainingAmount ?? this.remainingAmount,
        date: date ?? this.date,
        dueDate: dueDate ?? this.dueDate,
        status: status ?? this.status,
        lastPaymentDate: lastPaymentDate ?? this.lastPaymentDate,
        notes: notes ?? this.notes,
      );

  /// التحقق من تجاوز تاريخ الاستحقاق
  bool get isOverdue {
    if (dueDate == null || status == 'مسدد') return false;
    try {
      final due = DateTime.parse(dueDate!);
      return DateTime.now().isAfter(due) && remainingAmount > 0;
    } catch (e) {
      return false;
    }
  }

  /// حساب نسبة السداد
  double get paymentPercentage {
    if (originalAmount == 0) return 0;
    return (paidAmount / originalAmount) * 100;
  }

  /// التحقق من اكتمال السداد
  bool get isFullyPaid => remainingAmount <= 0 || status == 'مسدد';

  /// حساب عدد الأيام المتبقية للاستحقاق
  int? get daysUntilDue {
    if (dueDate == null) return null;
    try {
      final due = DateTime.parse(dueDate!);
      final diff = due.difference(DateTime.now());
      return diff.inDays;
    } catch (e) {
      return null;
    }
  }

  /// تسجيل دفعة جديدة
  DebtModel recordPayment(double amount, String paymentDate) {
    final newPaidAmount = paidAmount + amount;
    final newRemainingAmount = originalAmount - newPaidAmount;
    final newStatus = newRemainingAmount <= 0 ? 'مسدد' : 
                      newPaidAmount > 0 ? 'دفع جزئي' : 'غير مسدد';
    
    return copyWith(
      paidAmount: newPaidAmount,
      remainingAmount: newRemainingAmount,
      status: newStatus,
      lastPaymentDate: paymentDate,
    );
  }

  @override
  List<Object?> get props => [
    id, personType, personId, personName, transactionType, transactionId,
    originalAmount, paidAmount, remainingAmount, date, dueDate, status,
    lastPaymentDate, notes
  ];
}
