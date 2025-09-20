import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/issuance_model.dart';
import '../services/issuance_service.dart';
import 'api_provider.dart';

final issuanceServiceProvider = Provider<IssuanceService>((ref) {
  final api = ref.read(apiServiceProvider);
  return IssuanceService(api);
});

final issuanceProvider =
StateNotifierProvider<IssuanceNotifier, List<IssuanceModel>>((ref) {
  final service = ref.read(issuanceServiceProvider);
  return IssuanceNotifier(ref, service);
});

class IssuanceNotifier extends StateNotifier<List<IssuanceModel>> {
  final Ref ref;
  final IssuanceService service;

  IssuanceNotifier(this.ref, this.service) : super([]);

  Future<void> fetchIssuances({int? eventId}) async {
    try {
      final data = await service.fetchIssuances(eventId: eventId);
      state = data;
    } catch (e) {
      print('Error fetching issuances: $e');
    }
  }

  Future<void> addIssuance(IssuanceModel issuance) async {
    try {
      await service.createIssuance(issuance);
      await fetchIssuances();
    } catch (e) {
      print('Error adding issuance: $e');
    }
  }

  Future<void> deleteIssuance(int id) async {
    try {
      await service.deleteIssuance(id);
      state = state.where((i) => i.id != id).toList();
    } catch (e) {
      print('Error deleting issuance: $e');
    }
  }
}
