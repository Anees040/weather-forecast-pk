import 'package:dio/dio.dart';
import 'package:weather_forecast_pk/config/build_config.dart';
import 'package:weather_forecast_pk/network/api_interceptor.dart';

class DioClient {
  static final DioClient _dioClient = DioClient._internal();
  late Dio _dio;

  factory DioClient() {
    return _dioClient;
  }

  Dio get client => _dio;

  DioClient._internal() {
    var options = BaseOptions(
      baseUrl: BuildConfig.instance.config.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 10),
    );

    _dio = Dio(options);
    _dio.interceptors.addAll(getInterceptors());
  }
}
