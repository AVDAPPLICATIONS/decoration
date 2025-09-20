import '../models/tool_model.dart';
import 'api_service.dart';

class ToolService {
  final ApiService api;

  ToolService(this.api);

  Future<List<ToolModel>> fetchTools() async {
    final response = await api.get('/tools');
    return (response as List)
        .map((json) => ToolModel.fromJson(json))
        .toList();
  }

  Future<ToolModel> createTool(ToolModel tool) async {
    final response = await api.post('/tools', body: tool.toJson());
    return ToolModel.fromJson(response);
  }

  Future<ToolModel> updateTool(int id, ToolModel tool) async {
    final response = await api.put('/tools/$id', body: tool.toJson());
    return ToolModel.fromJson(response);
  }

  Future<void> deleteTool(int id) async {
    await api.delete('/tools/$id');
  }
}
