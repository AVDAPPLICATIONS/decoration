import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/year_model.dart';
import '../services/year_service.dart';
import 'api_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/repositories/year_repository.dart';

final yearServiceProvider = Provider<YearService>((ref) {
  final api = ref.read(apiServiceProvider);
  return YearService(api);
});

final yearProvider =
    StateNotifierProvider<YearNotifier, List<YearModel>>((ref) {
  final service = ref.read(yearServiceProvider);
  final repo = YearRepository(
    service: service,
    connectivity: Connectivity(),
    offline: ref.read(offlineCacheProvider),
  );
  return YearNotifier(ref, service, repo);
});

class YearNotifier extends StateNotifier<List<YearModel>> {
  final Ref ref;
  final YearService service;
  final YearRepository repo;

  YearNotifier(this.ref, this.service, this.repo) : super([]);

  Future<void> fetchYears({int? templateId}) async {
    try {
      final years = await repo.fetchYears(templateId: templateId);

      state = years;

      // Force a rebuild by setting state again
      if (mounted) {
        state = [...years];
      }
    } catch (e) {
      state = []; // Set empty state on error
    }
  }

  Future<YearModel?> addYear(YearModel year) async {
    try {
      final createdYear = await repo.createYear(year);
      await fetchYears(templateId: year.templateId);
      return createdYear;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteYear(int id) async {
    try {
      await repo.deleteYear(id);

      // State will be updated by removeYearFromState in the UI
    } catch (e) {
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
