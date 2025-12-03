import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_template_model.dart';
import '../services/event_template_service.dart';
import 'api_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/repositories/template_repository.dart';

final templateServiceProvider = Provider<EventTemplateService>((ref) {
  final api = ref.read(apiServiceProvider);
  return EventTemplateService(api);
});

final templateProvider =
    StateNotifierProvider<TemplateNotifier, List<EventTemplateModel>>((ref) {
  final service = ref.read(templateServiceProvider);
  final repo = TemplateRepository(
    service: service,
    connectivity: Connectivity(),
    offline: ref.read(offlineCacheProvider),
  );
  return TemplateNotifier(ref, service, repo);
});

// Loading state provider for templates
final templateLoadingProvider = StateProvider<bool>((ref) => false);

class TemplateNotifier extends StateNotifier<List<EventTemplateModel>> {
  final Ref ref;
  final EventTemplateService service;
  final TemplateRepository repo;

  TemplateNotifier(this.ref, this.service, this.repo) : super([]);

  Future<void> fetchTemplates() async {
    try {
      ref.read(templateLoadingProvider.notifier).state = true;

      final templates = await repo.fetchTemplates();
      print(
          'TemplateProvider: Successfully fetched ${templates.length} templates');

      // Log each template for debugging
      for (var template in templates) {
        print(
            'TemplateProvider: Template - ${template.name} (ID: ${template.id})');
      }

      state = templates;
    } catch (e) {
      // Keep the current state on error, don't clear it
    } finally {
      ref.read(templateLoadingProvider.notifier).state = false;
    }
  }

  Future<void> addTemplate(EventTemplateModel template) async {
    try {
      await service.addTemplate(template);
      await fetchTemplates();
    } catch (e) {}
  }

  Future<void> updateTemplate(int id, EventTemplateModel template) async {
    try {
      await service.updateTemplate(id, template);
      await fetchTemplates();
    } catch (e) {}
  }

  Future<void> deleteTemplate(int id) async {
    try {
      await service.deleteTemplate(id);
      await fetchTemplates();
    } catch (e) {}
  }
}
