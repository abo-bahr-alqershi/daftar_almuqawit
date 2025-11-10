/// أحداث لوحة التحكم
/// تحدد الأحداث التي يمكن أن تحدث في لوحة التحكم

import 'package:equatable/equatable.dart';

/// الحدث الأساسي للوحة التحكم
abstract class DashboardEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// تحميل بيانات لوحة التحكم
class LoadDashboard extends DashboardEvent {}

/// تحديث بيانات لوحة التحكم
class RefreshDashboard extends DashboardEvent {}
