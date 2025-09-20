import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'dart:io';
import '../models/cost_model.dart';
import '../services/cost_service.dart';
import '../utils/constants.dart';

final costServiceProvider = Provider<CostService>(
  (ref) => CostService(apiBaseUrl),
);

final costProvider =
    StateNotifierProvider<CostNotifier, List<CostModel>>((ref) {
  return CostNotifier(ref);
});

class CostNotifier extends StateNotifier<List<CostModel>> {
  final Ref ref;

  CostNotifier(this.ref) : super([]);

  Future<void> fetchCosts({required int eventId}) async {
    try {
      final costService = ref.read(costServiceProvider);
      final response = await costService.getEventCosts(eventId);

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> costData = jsonDecode(response['data']);
        final costs = costData.map((json) => CostModel.fromJson(json)).toList();
        state = costs;
      } else {
        state = [];
      }
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
