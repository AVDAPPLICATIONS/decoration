import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(apiBaseUrl); // 👈 Uses value from constants.dart
});
