import 'package:dio/dio.dart';

import 'local_storage_service.dart';

class TokenInterceptor extends Interceptor {
  final LocalStorageService _localStorageService;

  TokenInterceptor(this._localStorageService);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _localStorageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle response if needed
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle errors if needed
    super.onError(err, handler);
  }
}
