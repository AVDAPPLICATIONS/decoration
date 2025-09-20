import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../services/inventory_service.dart';
import '../utils/constants.dart';
import 'inventory_provider.dart';

class CategoryNotifier extends StateNotifier<List<CategoryModel>> {
  final InventoryService _inventoryService;
  bool _isLoading = false;
  String? _error;

  CategoryNotifier(this._inventoryService) : super([]) {
    loadCategories();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load categories from API
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;

    try {
      final response = await _inventoryService.getAllCategories();

      if (response['success'] == true) {
        final categoriesData = response['data'] as List;
        final categories = categoriesData
            .map((category) => CategoryModel.fromJson(category))
            .toList();
        state = categories;
        print(
            '✅ Categories loaded successfully: ${categories.length} categories');
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch categories');
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Error loading categories: $e');
    } finally {
      _isLoading = false;
    }
  }

  // Refresh categories
  Future<void> refreshCategories() async {
    await loadCategories();
  }

  // Get category by ID
  CategoryModel? getCategoryById(int id) {
    try {
      return state.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get category by name
  CategoryModel? getCategoryByName(String name) {
    try {
      return state.firstWhere(
          (category) => category.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // Create new category
  Future<Map<String, dynamic>> createCategory(String name) async {
    _isLoading = true;
    _error = null;

    try {
      final response = await _inventoryService.createCategory(name);

      if (response['success'] == true) {
        final categoryData = response['data'];
        final newCategory = CategoryModel.fromJson(categoryData);
        
        // Add the new category to the state
        state = [...state, newCategory];
        
        print('✅ Category created successfully: ${newCategory.name}');
        return response;
      } else {
        throw Exception(response['message'] ?? 'Failed to create category');
      }
    } catch (e) {
      _error = e.toString();
      print('❌ Error creating category: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }
}

// Main category provider
final categoryProvider =
    StateNotifierProvider<CategoryNotifier, List<CategoryModel>>((ref) {
  final inventoryService = ref.read(inventoryServiceProvider);
  return CategoryNotifier(inventoryService);
});
