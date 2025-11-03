import 'dart:async';
import 'api_client.dart';
import 'connectivity_service.dart';

/// خدمة الشبكة الرئيسية
/// 
/// تجمع بين فحص الاتصال وعميل API
class NetworkService {
  NetworkService._();
  
  static final NetworkService _instance = NetworkService._();
  static NetworkService get instance => _instance;

  final ConnectivityService _connectivity = ConnectivityService.instance;
  final ApiClient _api = ApiClient();
  
  bool _isInitialized = false;

  /// تهيئة الخدمة
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    await _connectivity.initialize();
    _isInitialized = true;
  }

  // ========== فحص الاتصال ==========

  /// التحقق من الاتصال بالإنترنت
  Future<bool> get isOnline => _connectivity.isOnline;

  /// مراقبة حالة الاتصال
  Stream<bool> get onConnectionChange => _connectivity.onStatusChange;

  /// التحقق من الاتصال بال WiFi
  Future<bool> get isWifi => _connectivity.isWifi;

  /// التحقق من الاتصال ببيانات الجوال
  Future<bool> get isMobile => _connectivity.isMobile;

  // ========== عميل API ==========

  /// الحصول على عميل API
  ApiClient get api => _api;

  // ========== عمليات مع فحص الاتصال ==========

  /// تنفيذ عملية مع فحص الاتصال
  Future<T> executeWithConnectivity<T>({
    required Future<T> Function() onOnline,
    required T Function() onOffline,
  }) async {
    final online = await isOnline;
    if (online) {
      return await onOnline();
    } else {
      return onOffline();
    }
  }

  /// الانتظار حتى يتوفر الاتصال
  Future<void> waitForConnection({Duration? timeout}) async {
    final online = await isOnline;
    if (online) return;

    final completer = Completer<void>();
    StreamSubscription? subscription;

    subscription = onConnectionChange.listen((isConnected) {
      if (isConnected) {
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });

    if (timeout != null) {
      return completer.future.timeout(
        timeout,
        onTimeout: () {
          subscription?.cancel();
          throw TimeoutException('انتهت مهلة الانتظار للاتصال');
        },
      );
    }

    return completer.future;
  }

  /// إغلاق الخدمة
  Future<void> dispose() async {
    await _connectivity.dispose();
  }
}
