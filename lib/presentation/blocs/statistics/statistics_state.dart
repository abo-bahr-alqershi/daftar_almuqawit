/// حالات Bloc الإحصائيات
/// تحتوي على جميع الحالات الممكنة لإدارة الإحصائيات

import 'package:equatable/equatable.dart';
import '../../../domain/entities/daily_statistics.dart';

/// الحالة الأساسية للإحصائيات
abstract class StatisticsState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class StatisticsInitial extends StatisticsState {}

/// حالة التحميل
class StatisticsLoading extends StatisticsState {}

/// حالة تحميل الإحصائيات بنجاح
class StatisticsLoaded extends StatisticsState {
  final List<DailyStatistics> stats;
  StatisticsLoaded(this.stats);
  
  @override
  List<Object?> get props => [stats];
}

/// حالة حدوث خطأ
class StatisticsError extends StatisticsState {
  final String message;
  StatisticsError(this.message);
  
  @override
  List<Object?> get props => [message];
}
