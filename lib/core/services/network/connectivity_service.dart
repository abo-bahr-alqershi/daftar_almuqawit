// ignore_for_file: public_member_api_docs

import 'package:connectivity_plus/connectivity_plus.dart';

/// خدمة فحص الاتصال بالشبكة
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<bool> get onStatusChange async* {
    yield* _connectivity.onConnectivityChanged.map((event) => event != ConnectivityResult.none);
  }
}
