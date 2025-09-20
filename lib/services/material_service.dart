import '../models/material_model.dart';
import 'api_service.dart';

class MaterialService {
  final ApiService api;

  MaterialService(this.api);

  Future<List<MaterialModel>> fetchMaterials() async {
    final response = await api.get('/materials');
    return (response as List)
        .map((json) => MaterialModel.fromJson(json))
        .toList();
  }

  Future<MaterialModel> createMaterial(MaterialModel material) async {
    final response = await api.post('/materials', body: material.toJson());
    return MaterialModel.fromJson(response);
  }

  Future<MaterialModel> updateMaterial(int id, MaterialModel material) async {
    final response = await api.put('/materials/$id', body: material.toJson());
    return MaterialModel.fromJson(response);
  }

  Future<void> deleteMaterial(int id) async {
    await api.delete('/materials/$id');
  }
}
