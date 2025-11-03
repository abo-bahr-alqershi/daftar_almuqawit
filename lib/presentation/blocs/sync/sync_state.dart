/// حالات Bloc المزامنة
/// تحتوي على جميع الحالات الممكنة لمزامنة البيانات

import 'package:equatable/equatable.dart';

/// الحالة الأساسية للمزامنة
abstract class SyncState extends Equatable {
  @override
  List<Object?> get props => [];
}

/// الحالة الأولية
class SyncInitial extends SyncState {}

/// حالة جاري المزامنة
class SyncInProgress extends SyncState {
  final String message;
  final double progress;
  
  SyncInProgress(this.message, this.progress);
  
  @override
  List<Object?> get props => [message, progress];
}

/// حالة اكتمال المزامنة بنجاح
class SyncSuccess extends SyncState {
  final String message;
  SyncSuccess(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// حالة فشل المزامنة
class SyncFailure extends SyncState {
  final String error;
  
  SyncFailure(this.error);
  
  @override
  List<Object?> get props => [error];
}

/// حالة جدولة المزامنة التلقائية
class SyncAutoScheduled extends SyncState {
  final Duration interval;
  
  SyncAutoScheduled(this.interval);
  
  @override
  List<Object?> get props => [interval];
}
