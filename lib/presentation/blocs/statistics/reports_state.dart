/// حالات التقارير
/// تمثل الحالات المختلفة للتقارير

import 'package:equatable/equatable.dart';

/// الحالة الأساسية للتقارير
abstract class ReportsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية للتقارير
class ReportsInitial extends ReportsState {}

/// حالة تحميل التقرير
class ReportsLoading extends ReportsState {
  /// رسالة التحميل
  final String message;
  
  ReportsLoading(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// حالة نجاح تحميل التقرير
class ReportsLoaded extends ReportsState {
  /// بيانات التقرير
  final Map<String, dynamic> reportData;
  
  ReportsLoaded(this.reportData);
  
  @override
  List<Object?> get props => [reportData];
}

/// حالة نجاح عملية على التقرير
class ReportsSuccess extends ReportsState {
  /// رسالة النجاح
  final String message;
  
  ReportsSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// حالة خطأ في التقرير
class ReportsError extends ReportsState {
  /// رسالة الخطأ
  final String message;
  
  ReportsError(this.message);
  
  @override
  List<Object?> get props => [message];
}
