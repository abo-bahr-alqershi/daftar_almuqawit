/// Bloc إدارة النسخ الاحتياطي
/// يدير عمليات النسخ الاحتياطي والاستعادة

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/usecases/backup/create_backup.dart';
import '../../../domain/usecases/backup/restore_backup.dart';
import '../../../domain/usecases/backup/export_to_excel.dart';
import '../../../domain/usecases/backup/schedule_auto_backup.dart';
import '../../../core/services/logger_service.dart';

// Events
abstract class BackupEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateBackupEvent extends BackupEvent {}

class RestoreBackupEvent extends BackupEvent {
  final String backupPath;
  
  RestoreBackupEvent(this.backupPath);
  
  @override
  List<Object?> get props => [backupPath];
}

class ExportToExcelEvent extends BackupEvent {
  final String dateRange;
  
  ExportToExcelEvent(this.dateRange);
  
  @override
  List<Object?> get props => [dateRange];
}

class ScheduleAutoBackupEvent extends BackupEvent {}

// States
abstract class BackupState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BackupInitial extends BackupState {}

class BackupInProgress extends BackupState {
  final String message;
  
  BackupInProgress(this.message);
  
  @override
  List<Object?> get props => [message];
}

class BackupSuccess extends BackupState {
  final String message;
  final String? filePath;
  
  BackupSuccess(this.message, {this.filePath});
  
  @override
  List<Object?> get props => [message, filePath];
}

class BackupError extends BackupState {
  final String message;
  
  BackupError(this.message);
  
  @override
  List<Object?> get props => [message];
}

/// Bloc النسخ الاحتياطي
class BackupBloc extends Bloc<BackupEvent, BackupState> {
  final CreateBackup _createBackup;
  final RestoreBackup _restoreBackup;
  final ExportToExcel _exportToExcel;
  final ScheduleAutoBackup _scheduleAutoBackup;
  final LoggerService _logger;
  
  BackupBloc({
    required CreateBackup createBackup,
    required RestoreBackup restoreBackup,
    required ExportToExcel exportToExcel,
    required ScheduleAutoBackup scheduleAutoBackup,
    required LoggerService logger,
  })  : _createBackup = createBackup,
        _restoreBackup = restoreBackup,
        _exportToExcel = exportToExcel,
        _scheduleAutoBackup = scheduleAutoBackup,
        _logger = logger,
        super(BackupInitial()) {
    on<CreateBackupEvent>(_onCreateBackup);
    on<RestoreBackupEvent>(_onRestoreBackup);
    on<ExportToExcelEvent>(_onExportToExcel);
    on<ScheduleAutoBackupEvent>(_onScheduleAutoBackup);
  }
  
  Future<void> _onCreateBackup(
    CreateBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    try {
      emit(BackupInProgress('جاري إنشاء النسخة الاحتياطية...'));
      _logger.info('بدء إنشاء نسخة احتياطية');
      
      final backupPath = await _createBackup(null);
      
      emit(BackupSuccess('تم إنشاء النسخة الاحتياطية بنجاح', filePath: backupPath));
      _logger.info('تم إنشاء النسخة الاحتياطية: $backupPath');
    } catch (e, s) {
      _logger.error('فشل إنشاء النسخة الاحتياطية', error: e, stackTrace: s);
      emit(BackupError('فشل إنشاء النسخة الاحتياطية: ${e.toString()}'));
    }
  }
  
  Future<void> _onRestoreBackup(
    RestoreBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    try {
      emit(BackupInProgress('جاري استعادة النسخة الاحتياطية...'));
      _logger.info('بدء استعادة النسخة الاحتياطية من: ${event.backupPath}');
      
      await _restoreBackup(event.backupPath);
      
      emit(BackupSuccess('تم استعادة النسخة الاحتياطية بنجاح'));
      _logger.info('تم استعادة النسخة الاحتياطية بنجاح');
    } catch (e, s) {
      _logger.error('فشل استعادة النسخة الاحتياطية', error: e, stackTrace: s);
      emit(BackupError('فشل استعادة النسخة الاحتياطية: ${e.toString()}'));
    }
  }
  
  Future<void> _onExportToExcel(
    ExportToExcelEvent event,
    Emitter<BackupState> emit,
  ) async {
    try {
      emit(BackupInProgress('جاري التصدير إلى Excel...'));
      _logger.info('بدء التصدير إلى Excel');
      
      final filePath = await _exportToExcel(event.dateRange);
      
      emit(BackupSuccess('تم التصدير بنجاح', filePath: filePath));
      _logger.info('تم التصدير إلى: $filePath');
    } catch (e, s) {
      _logger.error('فشل التصدير إلى Excel', error: e, stackTrace: s);
      emit(BackupError('فشل التصدير: ${e.toString()}'));
    }
  }
  
  Future<void> _onScheduleAutoBackup(
    ScheduleAutoBackupEvent event,
    Emitter<BackupState> emit,
  ) async {
    try {
      _logger.info('جدولة النسخ الاحتياطي التلقائي');
      
      await _scheduleAutoBackup(null);
      
      emit(BackupSuccess('تم تفعيل النسخ الاحتياطي التلقائي'));
      _logger.info('تم تفعيل النسخ الاحتياطي التلقائي');
    } catch (e, s) {
      _logger.error('فشل جدولة النسخ الاحتياطي التلقائي', error: e, stackTrace: s);
      emit(BackupError('فشل تفعيل النسخ الاحتياطي التلقائي: ${e.toString()}'));
    }
  }
}
