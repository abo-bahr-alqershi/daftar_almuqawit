// ignore_for_file: public_member_api_docs

import 'api_client.dart';
import 'connectivity_service.dart';

/// خدمة شبكة عالية المستوى تجمع الاتصال وعميل HTTP
class NetworkService {
  final ConnectivityService connectivity;
  final ApiClient api;
  NetworkService(this.connectivity, this.api);

  Future<bool> get isOnline => connectivity.isOnline;
}
