import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// خدمة فحص الاتصال بالشبكة
/// 
/// تراقب حالة الاتصال بالإنترنت وتوفر إشعارات عند التغيير
class ConnectivityService {
  ConnectivityService._();
  
  static final ConnectivityService _instance = ConnectivityService._();
  static ConnectivityService get instance => _instance;

  final Connectivity _connectivity = Connectivity();
  
  final StreamController<bool> _connectionController = 
      StreamController<bool>.broadcast();
  
  ConnectivityResult? _lastResult;
  StreamSubscription<ConnectivityResult>? _subscription;

  /// تهيئة الخدمة
  Future<void> initialize() async {
    // فحص الحالة الأولية
    final result = await _connectivity.checkConnectivity();
    _lastResult = result;
    _connectionController.add(_isConnected(result));
    
    // الاستماع للتغييرات
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      if (result != _lastResult) {
        _lastResult = result;
        _connectionController.add(_isConnected(result));
      }
    });
  }

  /// التحقق من الاتصال
  bool _isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  /// التحقق من الاتصال بالإنترنت
  Future<bool> get isOnline async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _isConnected(result);
    } catch (e) {
      return false;
    }
  }

  /// مراقبة تغييرات حالة الاتصال
  Stream<bool> get onStatusChange => _connectionController.stream;

  /// الحصول على نوع الاتصال
  Future<ConnectivityResult> get connectionType async {
    try {
      return await _connectivity.checkConnectivity();
    } catch (e) {
      return ConnectivityResult.none;
    }
  }

  /// التحقق من الاتصال بال WiFi
  Future<bool> get isWifi async {
    final type = await connectionType;
    return type == ConnectivityResult.wifi;
  }

  /// التحقق من الاتصال ببيانات الجوال
  Future<bool> get isMobile async {
    final type = await connectionType;
    return type == ConnectivityResult.mobile;
  }

  /// فحص جودة الاتصال
  Future<ConnectionQuality> checkQuality() async {
    final isConnected = await isOnline;
    if (!isConnected) return ConnectionQuality.none;
    
    final type = await connectionType;
    if (type == ConnectivityResult.wifi) {
      return ConnectionQuality.excellent;
    } else if (type == ConnectivityResult.mobile) {
      return ConnectionQuality.good;
    }
    
    return ConnectionQuality.poor;
  }

  /// الانتظار حتى يتوفر الاتصال
  Future<void> waitForConnection({Duration? timeout}) async {
    if (await isOnline) return;
    
    final completer = Completer<void>();
    StreamSubscription? subscription;
    Timer? timer;
    
    subscription = onStatusChange.listen((isConnected) {
      if (isConnected) {
        subscription?.cancel();
        timer?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    
    if (timeout != null) {
      timer = Timer(timeout, () {
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException('انتهت مهلة الانتظار للاتصال'));
        }
      });
    }
    
    return completer.future;
  }

  /// إغلاق الخدمة
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _connectionController.close();
  }
}

/// جودة الاتصال
enum ConnectionQuality {
  none,
  poor,
  good,
  excellent,
}
