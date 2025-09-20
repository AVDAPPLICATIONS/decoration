import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tool_model.dart';
import '../services/tool_service.dart';
import 'api_provider.dart';

final toolServiceProvider = Provider<ToolService>((ref) {
  final api = ref.read(apiServiceProvider);
  return ToolService(api);
});

final toolProvider =
StateNotifierProvider<ToolNotifier, List<ToolModel>>((ref) {
  final service = ref.read(toolServiceProvider);
  return ToolNotifier(ref, service);
});

class ToolNotifier extends StateNotifier<List<ToolModel>> {
  final Ref ref;
  final ToolService service;

  ToolNotifier(this.ref, this.service) : super([]);

  Future<void> fetchTools() async {
    try {
      final tools = await service.fetchTools();
      state = tools;
    } catch (e) {
      print('Error fetching tools: $e');
    }
  }

  Future<void> addTool(ToolModel tool) async {
    try {
      await service.createTool(tool);
      await fetchTools();
    } catch (e) {
      print('Error adding tool: $e');
    }
  }

  Future<void> updateTool(int id, ToolModel tool) async {
    try {
      await service.updateTool(id, tool);
      await fetchTools();
    } catch (e) {
      print('Error updating tool: $e');
    }
  }

  Future<void> deleteTool(int id) async {
    try {
      await service.deleteTool(id);
      state = state.where((t) => t.id != id).toList();
    } catch (e) {
      print('Error deleting tool: $e');
    }
  }
}
