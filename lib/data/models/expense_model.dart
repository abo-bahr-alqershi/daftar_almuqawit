/// نموذج المصروف
/// يحتوي على تفاصيل المصروف وتصنيفه والمرفقات

import 'base/base_model.dart';
import '../database/tables/expenses_table.dart';

/// نموذج بيانات المصروف
class ExpenseModel extends BaseModel {
  final int? id;
  final String date;
  final String time;
  final String category;
  final double amount;
  final String? description;
  final String paymentMethod;
  final int recurring; // 0: لا يتكرر، 1: يومي، 2: أسبوعي، 3: شهري
  final String? notes;
  final String? attachmentPath; // مسار المرفق أو الفاتورة

  const ExpenseModel({
    this.id,
    required this.date,
    required this.time,
    required this.category,
    required this.amount,
    this.description,
    this.paymentMethod = 'نقد',
    this.recurring = 0,
    this.notes,
    this.attachmentPath,
  });

  factory ExpenseModel.fromMap(Map<String, Object?> map) => ExpenseModel(
        id: map[ExpensesTable.cId] as int?,
        date: map[ExpensesTable.cDate] as String,
        time: map[ExpensesTable.cTime] as String,
        category: map[ExpensesTable.cCategory] as String,
        amount: (map[ExpensesTable.cAmount] as num).toDouble(),
        description: map[ExpensesTable.cDescription] as String?,
        paymentMethod: (map[ExpensesTable.cPaymentMethod] as String?) ?? 'نقد',
        recurring: (map[ExpensesTable.cRecurring] as int?) ?? 0,
        notes: map[ExpensesTable.cNotes] as String?,
      );

  @override
  Map<String, Object?> toMap() => {
        ExpensesTable.cId: id,
        ExpensesTable.cDate: date,
        ExpensesTable.cTime: time,
        ExpensesTable.cCategory: category,
        ExpensesTable.cAmount: amount,
        ExpensesTable.cDescription: description,
        ExpensesTable.cPaymentMethod: paymentMethod,
        ExpensesTable.cRecurring: recurring,
        ExpensesTable.cNotes: notes,
      };

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'time': time,
        'category': category,
        'amount': amount,
        'description': description,
        'paymentMethod': paymentMethod,
        'recurring': recurring,
        'notes': notes,
      };

  @override
  ExpenseModel copyWith({
    int? id,
    String? date,
    String? time,
    String? category,
    double? amount,
    String? description,
    String? paymentMethod,
    int? recurring,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? firebaseId,
    String? syncStatus,
  }) =>
      ExpenseModel(
        id: id ?? this.id,
        date: date ?? this.date,
        time: time ?? this.time,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        description: description ?? this.description,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        recurring: recurring ?? this.recurring,
        notes: notes ?? this.notes,
      );

  /// التحقق من أن المصروف متكرر
  bool get isRecurring => recurring > 0;

  /// الحصول على نوع التكرار
  String get recurringType {
    switch (recurring) {
      case 1:
        return 'يومي';
      case 2:
        return 'أسبوعي';
      case 3:
        return 'شهري';
      default:
        return 'لا يتكرر';
    }
  }

  /// التحقق من وجود مرفق
  bool get hasAttachment => attachmentPath != null && attachmentPath!.isNotEmpty;

  /// الحصول على تصنيفات المصاريف الشائعة
  static List<String> get commonCategories => [
        'رواتب',
        'إيجار',
        'كهرباء',
        'ماء',
        'صيانة',
        'نقل',
        'اتصالات',
        'تسويق',
        'مواد خام',
        'أخرى',
      ];

  @override
  List<Object?> get props => [
    id, date, time, category, amount, description,
    paymentMethod, recurring, notes, attachmentPath
  ];
}
