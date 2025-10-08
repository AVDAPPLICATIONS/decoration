import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/cost_model.dart';
import '../services/cost_service.dart';
import '../utils/constants.dart';
import 'api_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/repositories/cost_repository.dart';

final costServiceProvider = Provider<CostService>(
  (ref) => CostService(apiBaseUrl),
);

final costProvider =
    StateNotifierProvider<CostNotifier, List<CostModel>>((ref) {
  return CostNotifier(ref);
});

class CostNotifier extends StateNotifier<List<CostModel>> {
  final Ref ref;
  late final CostRepository _repo;

  CostNotifier(this.ref) : super([]) {
    final service = ref.read(costServiceProvider);
    _repo = CostRepository(
      service: service,
      connectivity: Connectivity(),
      offline: ref.read(offlineCacheProvider),
    );
  }

  Future<void> fetchCosts({required int eventId}) async {
    try {
      final costs = await _repo.getEventCosts(eventId);
      state = costs;
    } catch (e) {
      state = [];
      // Handle error
    }
  }

  Future<Map<String, dynamic>> addCost({
    required int eventId,
    required String description,
    required double amount,
    File? document,
  }) async {
    try {
      final costService = ref.read(costServiceProvider);
      final response = await costService.createEventCostItem(
        eventId: eventId,
        description: description,
        amount: amount,
        document: document,
      );

      if (response['success'] == true) {
        // Refresh the costs list
        await fetchCosts(eventId: eventId);
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error adding cost: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteCost(int id) async {
    try {
      final costService = ref.read(costServiceProvider);
      final response = await costService.deleteEventCostItem(id);

      if (response['success'] == true) {
        state = state.where((c) => c.id != id).toList();
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting cost: $e',
      };
    }
  }
}
