/// أحداث Bloc أنواع القات
/// تحتوي على جميع الأحداث المتعلقة بإدارة أنواع القات

import '../../../domain/entities/qat_type.dart';

/// الحدث الأساسي لأنواع القات
abstract class QatTypesEvent {}

/// حدث تحميل جميع أنواع القات
class LoadQatTypes extends QatTypesEvent {}

/// حدث تحميل نوع قات معين
class LoadQatTypeById extends QatTypesEvent {
  final int id;
  LoadQatTypeById(this.id);
}

/// حدث إضافة نوع قات جديد
class AddQatTypeEvent extends QatTypesEvent {
  final QatType qatType;
  AddQatTypeEvent(this.qatType);
}

/// حدث تحديث نوع قات
class UpdateQatTypeEvent extends QatTypesEvent {
  final QatType qatType;
  UpdateQatTypeEvent(this.qatType);
}

/// حدث حذف نوع قات
class DeleteQatTypeEvent extends QatTypesEvent {
  final int id;
  DeleteQatTypeEvent(this.id);
}

/// حدث البحث في أنواع القات
class SearchQatTypes extends QatTypesEvent {
  final String query;
  SearchQatTypes(this.query);
}

/// حدث فلترة أنواع القات حسب الجودة
class FilterQatTypesByQuality extends QatTypesEvent {
  final String qualityGrade;
  FilterQatTypesByQuality(this.qualityGrade);
}
