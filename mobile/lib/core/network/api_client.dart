import 'package:dio/dio.dart';

import 'api_config.dart';
import 'auth_token_storage.dart';

class ApiClient {
  ApiClient({Dio? dio, AuthTokenStorage? tokenStorage})
    : tokenStorage = tokenStorage ?? AuthTokenStorage(),
      dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
              contentType: Headers.jsonContentType,
              responseType: ResponseType.json,
            ),
          ) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await this.tokenStorage.readToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await this.tokenStorage.clearToken();
          }

          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;
  final AuthTokenStorage tokenStorage;
}
