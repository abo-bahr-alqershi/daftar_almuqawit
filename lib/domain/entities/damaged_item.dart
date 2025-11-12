import 'base/base_entity.dart';

/// كيان البضاعة التالفة
/// 
/// يمثل عنصر تالف في المخزون
class DamagedItem extends BaseEntity {
  final String damageDate;
  final String damageTime;
  final String damageNumber;
  final int qatTypeId;
  final String qatTypeName;
  final String unit;
  final double quantity;
  final double unitCost;
  final double totalCost;
  final String damageReason;
  final String damageType; // تلف_طبيعي، تلف_بشري، تلف_خارجي، انتهاء_صلاحية
  final String severityLevel; // طفيف، متوسط، كبير، كارثي
  final String? notes;
  final String? actionTaken; // إجراء تم اتخاذه
  final bool isInsuranceCovered; // هل مشمول بالتأمين
  final double? insuranceAmount; // مبلغ التأمين
  final String? responsiblePerson; // الشخص المسؤول
  final String status; // تحت_المراجعة، مؤكد، تم_التعامل_معه
  final int warehouseId;
  final String warehouseName;
  final String? batchNumber; // رقم الدفعة
  final String? expiryDate; // تاريخ الانتهاء
  final String? discoveredBy; // من اكتشف التلف
  final String? createdBy;
  final String? createdAt;
  final String? updatedAt;
  final String? syncStatus;
  final String? firebaseId;

  const DamagedItem({
    super.id,
    required this.damageDate,
    required this.damageTime,
    required this.damageNumber,
    required this.qatTypeId,
    required this.qatTypeName,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    required this.damageReason,
    required this.damageType,
    this.severityLevel = 'متوسط',
    this.notes,
    this.actionTaken,
    this.isInsuranceCovered = false,
    this.insuranceAmount,
    this.responsiblePerson,
    this.status = 'تحت_المراجعة',
    this.warehouseId = 1,
    this.warehouseName = 'المخزن الرئيسي',
    this.batchNumber,
    this.expiryDate,
    this.discoveredBy,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.syncStatus = 'pending',
    this.firebaseId,
  });

  /// هل التلف مؤكد؟
  bool get isConfirmed => status == 'مؤكد';

  /// هل تحت المراجعة؟
  bool get isUnderReview => status == 'تحت_المراجعة';

  /// هل تم التعامل معه؟
  bool get isHandled => status == 'تم_التعامل_معه';

  /// لون مستوى الخطورة
  String get severityColor {
    switch (severityLevel) {
      case 'طفيف':
        return 'green';
      case 'متوسط':
        return 'orange';
      case 'كبير':
        return 'red';
      case 'كارثي':
        return 'purple';
      default:
        return 'grey';
    }
  }

  /// أيقونة نوع التلف
  String get damageTypeIcon {
    switch (damageType) {
      case 'تلف_طبيعي':
        return 'schedule';
      case 'تلف_بشري':
        return 'person';
      case 'تلف_خارجي':
        return 'warning';
      case 'انتهاء_صلاحية':
        return 'event_busy';
      default:
        return 'broken_image';
    }
  }

  /// نوع التلف للعرض
  String get displayDamageType {
    switch (damageType) {
      case 'تلف_طبيعي':
        return 'تلف طبيعي';
      case 'تلف_بشري':
        return 'تلف بشري';
      case 'تلف_خارجي':
        return 'تلف خارجي';
      case 'انتهاء_صلاحية':
        return 'انتهاء صلاحية';
      default:
        return damageType;
    }
  }

  /// حالة التلف للعرض
  String get displayStatus {
    switch (status) {
      case 'تحت_المراجعة':
        return 'تحت المراجعة';
      case 'مؤكد':
        return 'مؤكد';
      case 'تم_التعامل_معه':
        return 'تم التعامل معه';
      default:
        return status;
    }
  }

  /// لون الحالة
  String get statusColor {
    switch (status) {
      case 'تحت_المراجعة':
        return 'orange';
      case 'مؤكد':
        return 'red';
      case 'تم_التعامل_معه':
        return 'green';
      default:
        return 'grey';
    }
  }

  /// النسبة المئوية للتلف من التكلفة الإجمالية
  double getPercentageOfTotalCost(double totalInventoryCost) {
    if (totalInventoryCost <= 0) return 0;
    return (totalCost / totalInventoryCost) * 100;
  }

  /// هل يحتاج لإجراء عاجل؟
  bool get needsUrgentAction {
    return severityLevel == 'كبير' || 
           severityLevel == 'كارثي' || 
           damageType == 'تلف_خارجي';
  }

  DamagedItem copyWith({
    int? id,
    String? damageDate,
    String? damageTime,
    String? damageNumber,
    int? qatTypeId,
    String? qatTypeName,
    String? unit,
    double? quantity,
    double? unitCost,
    double? totalCost,
    String? damageReason,
    String? damageType,
    String? severityLevel,
    String? notes,
    String? actionTaken,
    bool? isInsuranceCovered,
    double? insuranceAmount,
    String? responsiblePerson,
    String? status,
    int? warehouseId,
    String? warehouseName,
    String? batchNumber,
    String? expiryDate,
    String? discoveredBy,
    String? createdBy,
    String? createdAt,
    String? updatedAt,
    String? syncStatus,
    String? firebaseId,
  }) {
    return DamagedItem(
      id: id ?? this.id,
      damageDate: damageDate ?? this.damageDate,
      damageTime: damageTime ?? this.damageTime,
      damageNumber: damageNumber ?? this.damageNumber,
      qatTypeId: qatTypeId ?? this.qatTypeId,
      qatTypeName: qatTypeName ?? this.qatTypeName,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      totalCost: totalCost ?? this.totalCost,
      damageReason: damageReason ?? this.damageReason,
      damageType: damageType ?? this.damageType,
      severityLevel: severityLevel ?? this.severityLevel,
      notes: notes ?? this.notes,
      actionTaken: actionTaken ?? this.actionTaken,
      isInsuranceCovered: isInsuranceCovered ?? this.isInsuranceCovered,
      insuranceAmount: insuranceAmount ?? this.insuranceAmount,
      responsiblePerson: responsiblePerson ?? this.responsiblePerson,
      status: status ?? this.status,
      warehouseId: warehouseId ?? this.warehouseId,
      warehouseName: warehouseName ?? this.warehouseName,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      discoveredBy: discoveredBy ?? this.discoveredBy,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      firebaseId: firebaseId ?? this.firebaseId,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'damageDate': damageDate,
    'damageTime': damageTime,
    'damageNumber': damageNumber,
    'qatTypeId': qatTypeId,
    'qatTypeName': qatTypeName,
    'unit': unit,
    'quantity': quantity,
    'unitCost': unitCost,
    'totalCost': totalCost,
    'damageReason': damageReason,
    'damageType': damageType,
    'severityLevel': severityLevel,
    'notes': notes,
    'actionTaken': actionTaken,
    'isInsuranceCovered': isInsuranceCovered,
    'insuranceAmount': insuranceAmount,
    'responsiblePerson': responsiblePerson,
    'status': status,
    'warehouseId': warehouseId,
    'warehouseName': warehouseName,
    'batchNumber': batchNumber,
    'expiryDate': expiryDate,
    'discoveredBy': discoveredBy,
    'createdBy': createdBy,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'syncStatus': syncStatus,
    'firebaseId': firebaseId,
  };
}

/// أسباب التلف الشائعة
class DamageReasons {
  static const List<String> naturalDamage = [
    'تلف طبيعي بمرور الوقت',
    'تغيرات في درجة الحرارة',
    'الرطوبة العالية',
    'التعرض للضوء المباشر',
    'انتهاء فترة الصلاحية',
    'تفاعلات كيميائية طبيعية',
  ];

  static const List<String> humanDamage = [
    'خطأ في المناولة',
    'سقوط أثناء النقل',
    'تخزين غير صحيح',
    'عدم اتباع التعليمات',
    'استخدام أدوات غير مناسبة',
    'إهمال في الرعاية',
  ];

  static const List<String> externalDamage = [
    'كوارث طبيعية',
    'حريق',
    'فيضان',
    'سرقة أو تخريب',
    'قطع في الكهرباء',
    'عطل في التبريد',
    'آفات أو حشرات',
  ];

  static const List<String> expiryDamage = [
    'تجاوز تاريخ الانتهاء',
    'فساد المنتج',
    'تغير في الخصائص',
    'فقدان الفعالية',
    'تكوّن البكتيريا',
  ];

  static List<String> getReasonsByType(String damageType) {
    switch (damageType) {
      case 'تلف_طبيعي':
        return naturalDamage;
      case 'تلف_بشري':
        return humanDamage;
      case 'تلف_خارجي':
        return externalDamage;
      case 'انتهاء_صلاحية':
        return expiryDamage;
      default:
        return [...naturalDamage, ...humanDamage, ...externalDamage, ...expiryDamage];
    }
  }
}

/// الإجراءات المُتخذة للتلف
class DamageActions {
  static const List<String> commonActions = [
    'إتلاف البضاعة',
    'بيع بسعر مخفض',
    'إعادة تدوير',
    'إصلاح إن أمكن',
    'مطالبة التأمين',
    'إرجاع للمورد',
    'تحويل لاستخدام آخر',
    'التبرع بها',
    'لا يوجد إجراء',
  ];
}
