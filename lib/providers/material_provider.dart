import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/material_model.dart';
import '../services/material_service.dart';
import 'api_provider.dart';

final materialServiceProvider = Provider<MaterialService>((ref) {
  final api = ref.read(apiServiceProvider);
  return MaterialService(api);
});

final materialProvider = StateNotifierProvider<MaterialNotifier, List<MaterialModel>>((ref) {
  final service = ref.read(materialServiceProvider);
  return MaterialNotifier(ref, service);
});

class MaterialNotifier extends StateNotifier<List<MaterialModel>> {
  final Ref ref;
  final MaterialService service;

  MaterialNotifier(this.ref, this.service) : super([]);

  Future<void> fetchMaterials() async {
    try {
      final data = await service.fetchMaterials();
      state = data;
    } catch (e) {
      print('Error fetching materials: $e');
    }
  }

  Future<void> addMaterial(MaterialModel material) async {
    try {
      await service.createMaterial(material);
      await fetchMaterials();
    } catch (e) {
      print('Error adding material: $e');
    }
  }

  Future<void> updateMaterial(int id, MaterialModel material) async {
    try {
      await service.updateMaterial(id, material);
      await fetchMaterials();
    } catch (e) {
      print('Error updating material: $e');
    }
  }

  Future<void> deleteMaterial(int id) async {
    try {
      await service.deleteMaterial(id);
      state = state.where((m) => m.id != id).toList();
    } catch (e) {
      print('Error deleting material: $e');
    }
  }
}
