import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/year_model.dart';
import '../services/year_service.dart';
import 'api_provider.dart';

final yearServiceProvider = Provider<YearService>((ref) {
  final api = ref.read(apiServiceProvider);
  return YearService(api);
});

final yearProvider =
    StateNotifierProvider<YearNotifier, List<YearModel>>((ref) {
  final service = ref.read(yearServiceProvider);
  return YearNotifier(ref, service);
});

class YearNotifier extends StateNotifier<List<YearModel>> {
  final Ref ref;
  final YearService service;

  YearNotifier(this.ref, this.service) : super([]);

  Future<void> fetchYears({int? templateId}) async {
    try {
      print('YearProvider: Starting to fetch years...');
      print('YearProvider: Template ID: $templateId');
      final years = await service.fetchYears(templateId: templateId);
      print('YearProvider: Received ${years.length} years from service');
      state = years;
      print('YearProvider: State updated with ${state.length} years');

      // Force a rebuild by setting state again
      if (mounted) {
        state = [...years];
      }
    } catch (e) {
      print('YearProvider: Error fetching years: $e');
      state = []; // Set empty state on error
    }
  }

  Future<YearModel?> addYear(YearModel year) async {
    try {
      final createdYear = await service.createYear(year);
      await fetchYears(templateId: year.templateId);
      return createdYear;
    } catch (e) {
      print('Error adding year: $e');
      return null;
    }
  }

  Future<void> deleteYear(int id) async {
    try {
      print('YearProvider: Attempting to delete year with ID: $id');
      await service.deleteYear(id);
      print('YearProvider: Successfully deleted year with ID: $id');
      // State will be updated by removeYearFromState in the UI
    } catch (e) {
      print('YearProvider: Error deleting year $id: $e');
      rethrow; // Re-throw to handle in UI
    }
  }

  void removeYearFromState(int id) {
    final newState = state.where((y) => y.id != id).toList();
    state = newState;
    print(
        'YearProvider: Removed year $id from state. Remaining years: ${state.length}');
  }

  void addYearBackToState(YearModel year) {
    state = [...state, year];
  }
}
