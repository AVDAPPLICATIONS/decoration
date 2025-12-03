import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/inventory_service.dart';
import '../utils/constants.dart';

// Dashboard data models
class DashboardStats {
  final Map<String, dynamic> totals;
  final List<Map<String, dynamic>> costByYear;
  final List<Map<String, dynamic>> recentEvents;
  final List<Map<String, dynamic>> topCategories;

  DashboardStats({
    required this.totals,
    required this.costByYear,
    required this.recentEvents,
    required this.topCategories,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totals: json['totals'] ?? {},
      costByYear: List<Map<String, dynamic>>.from(json['cost_by_year'] ?? []),
      recentEvents:
          List<Map<String, dynamic>>.from(json['recent_events'] ?? []),
      topCategories:
          List<Map<String, dynamic>>.from(json['top_categories'] ?? []),
    );
  }
}

class DashboardState {
  final DashboardStats? stats;
  final bool isLoading;
  final String? error;

  DashboardState({
    this.stats,
    this.isLoading = false,
    this.error,
  });

  DashboardState copyWith({
    DashboardStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return DashboardState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final InventoryService _inventoryService;

  DashboardNotifier(this._inventoryService) : super(DashboardState());

  // Load dashboard statistics
  Future<void> loadDashboardStats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _inventoryService.getDashboardStats();

      if (response['success'] == true) {
        final stats = DashboardStats.fromJson(response['data']);

        state = state.copyWith(
          stats: stats,
          isLoading: false,
          error: null,
        );
      } else {
        throw Exception(
            response['message'] ?? 'Failed to load dashboard stats');
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Refresh dashboard data
  Future<void> refreshDashboard() async {
    try {
      await loadDashboardStats();
    } catch (e) {
      rethrow; // Re-throw to let the UI handle the error
    }
  }
}

// Provider for dashboard state
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(InventoryService(apiBaseUrl));
});
