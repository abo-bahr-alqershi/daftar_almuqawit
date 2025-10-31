// ignore_for_file: public_member_api_docs

import 'package:dio/dio.dart';
import '../../constants/api_endpoints.dart';

/// عميل HTTP مبسّط باستخدام Dio
class ApiClient {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) {
    return _dio.get<T>(path, queryParameters: query);
  }

  Future<Response<T>> post<T>(String path, {Object? data}) {
    return _dio.post<T>(path, data: data);
  }
}
