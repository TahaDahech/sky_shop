import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/live_event.dart';

/// Service responsible for making HTTP calls to the real backend using Dio.
///
/// This mirrors the shape of [MockApiService] so it can be swapped easily.
class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
      ),
    );

    _setupInterceptors();
  }

  Dio get client => _dio;

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // TODO: Add auth headers, logging, etc.
          return handler.next(options);
        },
        onError: (error, handler) {
          // TODO: Centralize error handling / logging here.
          return handler.next(error);
        },
      ),
    );
  }

  /// Example method showing how the real API would be implemented.
  ///
  /// For now, this is just a placeholder; you can wire it to your backend
  /// later while keeping the same interface used by the UI.
  Future<List<LiveEvent>> getLiveEvents() async {
    // final response = await _dio.get('/live-events');
    // final data = response.data as List<dynamic>;
    // return data.map((e) => LiveEvent.fromJson(e as Map<String, dynamic>)).toList();
    throw UnimplementedError('Real API not implemented yet.');
  }
}

