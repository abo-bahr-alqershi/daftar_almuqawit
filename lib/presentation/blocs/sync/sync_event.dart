/// أحداث Bloc المزامنة
/// تحتوي على جميع الأحداث المتعلقة بمزامنة البيانات

/// الحدث الأساسي للمزامنة
abstract class SyncEvent {}

/// حدث بدء المزامنة اليدوية
class StartSync extends SyncEvent {
  final bool fullSync;
  
  StartSync({this.fullSync = false});
}

/// حدث بدء المزامنة (اسم بديل)
class SyncStarted extends SyncEvent {
  final bool fullSync;
  
  SyncStarted({this.fullSync = false});
}

/// حدث مزامنة المبيعات
class SyncSales extends SyncEvent {}

/// حدث مزامنة المشتريات
class SyncPurchases extends SyncEvent {}

/// حدث مزامنة العملاء
class SyncCustomers extends SyncEvent {}

/// حدث إيقاف المزامنة
class StopSync extends SyncEvent {}

/// حدث جدولة المزامنة التلقائية
class ScheduleAutoSync extends SyncEvent {
  final Duration interval;
  
  ScheduleAutoSync(this.interval);
}

/// حدث إلغاء جدولة المزامنة التلقائية
class CancelAutoSync extends SyncEvent {}
