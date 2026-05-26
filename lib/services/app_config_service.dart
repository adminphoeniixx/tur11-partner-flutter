import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/app_config_models.dart';

class AppConfigService {
  static const String _baseUrl =
      'https://ai-turf11-laravel.rmsiry.easypanel.host/api/v1';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: const {
        'Accept': 'application/json',
      },
    ),
  );

  static Future<AppConfig?> checkAppConfig() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/app-config',
        queryParameters: {
          'app_type': 'owner',
          'platform': _getPlatform(),
          'app_version': await _getAppVersion(),
        },
      );

      final data = response.data;
      if (response.statusCode == 200 && data != null) {
        return AppConfig.fromJson(data);
      }
    } catch (error) {
      debugPrint('[AppConfigService] App config check failed: $error');
    }
    return null;
  }

  static String _getPlatform() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    return 'android';
  }

  static Future<String> _getAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '1.0.0';
    }
  }
}
