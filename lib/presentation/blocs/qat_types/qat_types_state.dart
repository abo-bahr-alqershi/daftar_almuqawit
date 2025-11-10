/// حالات Bloc أنواع القات
/// تحتوي على جميع الحالات الممكنة لإدارة أنواع القات

import 'package:equatable/equatable.dart';
import '../../../domain/entities/qat_type.dart';

/// الحالة الأساسية لأنواع القات
abstract class QatTypesState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class QatTypesInitial extends QatTypesState {}

/// حالة التحميل
class QatTypesLoading extends QatTypesState {}

/// حالة تحميل أنواع القات بنجاح
class QatTypesLoaded extends QatTypesState {
  final List<QatType> qatTypes;
  QatTypesLoaded(this.qatTypes);
  
  @override
  List<Object?> get props => [qatTypes];
}

/// حالة تحميل نوع قات واحد بنجاح
class QatTypeDetailsLoaded extends QatTypesState {
  final QatType qatType;
  QatTypeDetailsLoaded(this.qatType);
  
  @override
  List<Object?> get props => [qatType];
}

/// حالة حدوث خطأ
class QatTypesError extends QatTypesState {
  final String message;
  QatTypesError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// حالة نجاح العملية
class QatTypeOperationSuccess extends QatTypesState {
  final String message;
  QatTypeOperationSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// حالة البحث
class QatTypesSearchResults extends QatTypesState {
  final List<QatType> results;
  final String query;
  QatTypesSearchResults(this.results, this.query);
  
  @override
  List<Object?> get props => [results, query];
}
