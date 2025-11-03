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

  /// إغلاق الخدمة
  Future<void> dispose() async {
    await _subscription?.cancel();
    await _connectionController.close();
  }
}
