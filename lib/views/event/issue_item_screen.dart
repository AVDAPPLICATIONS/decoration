import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/inventory_service.dart';
import '../../utils/snackbar_manager.dart';
import '../../utils/constants.dart';

class IssueItemScreen extends ConsumerStatefulWidget {
  final int eventId;
  final VoidCallback onItemIssued;

  const IssueItemScreen({
    super.key,
    required this.eventId,
    required this.onItemIssued,
  });

  @override
  ConsumerState<IssueItemScreen> createState() => _IssueItemScreenState();
}

class _IssueItemScreenState extends ConsumerState<IssueItemScreen> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedMaterial = 'All';
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _availableItems = [];
  List<Map<String, dynamic>> _filteredItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableItems();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAvailableItems() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final inventoryService = InventoryService(apiBaseUrl);
      final response = await inventoryService.getAllItems();
      // Ensure we always convert to List<Map<String, dynamic>> safely
      final rawList = (response['data'] as List?) ?? const [];
      final items = rawList
          .where((e) => e is Map)
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      setState(() {
        _availableItems = items;
        _filteredItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      SnackBarManager.showError(context: context, message: 'Failed to load items: $e');
    }
  }

  // Helpers to derive normalized fields from varying API shapes
  String? _itemCategory(Map<String, dynamic> item) {
    if (item['category_name'] != null && item['category_name'].toString().isNotEmpty) {
      return item['category_name'].toString();
    }
    final cat = item['category'];
    if (cat is Map && cat['name'] != null) return cat['name'].toString();
    if (cat is String && cat.isNotEmpty) return cat;
    return null;
  }

  String? _itemMaterial(Map<String, dynamic> item) {
    if (item['material_name'] != null && item['material_name'].toString().isNotEmpty) {
      return item['material_name'].toString();
    }
    final mat = item['material'];
    if (mat is Map && mat['name'] != null) return mat['name'].toString();
    if (mat is String && mat.isNotEmpty) return mat;
    return null;
  }

  List<Map<String, dynamic>> _getFilteredItems() {
    var filtered = List<Map<String, dynamic>>.from(_availableItems);

    // Filter by search term
    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((item) {
        final name = item['name']?.toString().toLowerCase() ?? '';
        final searchTerm = _searchController.text.toLowerCase();
        return name.contains(searchTerm);
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((item) {
        final cat = _itemCategory(item);
        return cat == _selectedCategory;
      }).toList();
    }

    // Filter by material
    if (_selectedMaterial != 'All') {
      filtered = filtered.where((item) {
        final mat = _itemMaterial(item);
        return mat == _selectedMaterial;
      }).toList();
    }

    return filtered;
  }

  // Quantity helpers
  double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.trim();
      final parsed = double.tryParse(cleaned) ?? double.tryParse(cleaned.replaceAll(',', ''));
      return parsed ?? 0;
    }
    return 0;
  }

  String _formatQty(num value) {
    final doubleVal = value.toDouble();
    if (doubleVal % 1 == 0) return doubleVal.toInt().toString();
    return doubleVal.toStringAsFixed(2).replaceAll(RegExp(r'\.00$'), '');
  }

  double _availableQuantity(Map<String, dynamic> item) {
    return _toDouble(item['available_quantity'] ?? item['quantity_available']);
  }

  double _totalQuantity(Map<String, dynamic> item) {
    return _toDouble(item['total_quantity'] ?? item['total_stock'] ?? item['quantity_total']);
  }

  // Dimensions helper (best-effort from various fields)
  String _dimensions(Map<String, dynamic> item) {
    final direct = item['dimensions'] ?? item['size'] ?? item['dimension'];
    if (direct != null && direct.toString().trim().isNotEmpty) return direct.toString();
    final details = item['furniture_details'] ??
        item['fabric_details'] ??
        item['carpet_details'] ??
        item['frame_structure_details'] ??
        item['murti_set_details'] ??
        item['stationery_details'] ??
        item['thermocol_details'];
    if (details is Map) {
      final dim = details['dimensions'] ?? details['size'] ?? details['dimension'];
      if (dim != null && dim.toString().trim().isNotEmpty) return dim.toString();
      final l = details['length'];
      final w = details['width'];
      final h = details['height'];
      final parts = <String>[];
      if (l != null && l.toString().isNotEmpty) parts.add(l.toString());
      if (w != null && w.toString().isNotEmpty) parts.add(w.toString());
      if (h != null && h.toString().isNotEmpty) parts.add(h.toString());
      if (parts.isNotEmpty) return parts.join('x');
    }
    final l = item['length'];
    final w = item['width'];
    final h = item['height'];
    final parts = <String>[];
    if (l != null && l.toString().isNotEmpty) parts.add(l.toString());
    if (w != null && w.toString().isNotEmpty) parts.add(w.toString());
    if (h != null && h.toString().isNotEmpty) parts.add(h.toString());
    if (parts.isNotEmpty) return parts.join('x');
    return 'N/A';
  }

  String _location(Map<String, dynamic> item) {
    return (item['storage_location'] ?? item['location'] ?? 'Unknown').toString();
  }

  // Image helper
  Widget _buildItemImage(Map<String, dynamic> item) {
    final rawUrl = item['image_url'] ?? item['item_image'] ?? item['image'] ?? item['photo'] ?? item['cover_image'];
    if (rawUrl != null && rawUrl.toString().isNotEmpty && rawUrl.toString() != 'null') {
      String fullUrl = rawUrl.toString();
      if (fullUrl.startsWith('/')) {
        fullUrl = '$apiBaseUrl$fullUrl';
      }
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          fullUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _defaultItemIcon();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
        ),
      );
    }
    return _defaultItemIcon();
  }

  Widget _defaultItemIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Icon(
        Icons.inventory_2,
        color: Colors.grey[500],
        size: 28,
      ),
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item, ColorScheme colorScheme) {
    final categoryName = _itemCategory(item);
    final dims = _dimensions(item);
    final loc = _location(item);
    final available = _availableQuantity(item);
    final total = _totalQuantity(item);
    final isLowStock = available > 0 && available <= 5;
    final isOutOfStock = available <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isOutOfStock ? Colors.red[300]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildItemImage(item),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (item['name'] ?? 'Unknown Item').toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (categoryName != null) ...[
                        Expanded(
                          flex: 2,
                          child: Text(
                            categoryName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        flex: 3,
                        child: Row(
                          children: [
                            Icon(
                              Icons.straighten,
                              size: 12,
                              color: Colors.amber[700],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dims,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          loc,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isLowStock && !isOutOfStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber[300]!),
                    ),
                    child: Text(
                      'Low Stock',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber[800],
                      ),
                    ),
                  ),
                if (isLowStock && !isOutOfStock) const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 130),
                  child: Text(
                    total > 0
                        ? 'Available: ${_formatQty(available)} / Total: ${_formatQty(total)}'
                        : 'Qty: ${_formatQty(available)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isOutOfStock ? Colors.red[600] : Colors.grey[900],
                    ),
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: isOutOfStock ? null : () => _showIssueDialog(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOutOfStock ? Colors.grey[400] : colorScheme.primary,
                    foregroundColor: isOutOfStock ? Colors.grey[700] : colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  child: Text(isOutOfStock ? 'Out of stock' : 'Issue'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<String> _getCategories() {
    final categories = _availableItems
        .map((item) => _itemCategory(item))
        .where((name) => name != null && name!.trim().isNotEmpty)
        .map((name) => name!)
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }

  List<String> _getMaterials() {
    final materials = _availableItems
        .map((item) => _itemMaterial(item))
        .where((name) => name != null && name!.trim().isNotEmpty)
        .map((name) => name!)
        .toSet()
        .toList();
    materials.sort();
    return ['All', ...materials];
  }

  Future<void> _issueItem(Map<String, dynamic> item) async {
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      SnackBarManager.showError(context: context, message: 'Please enter a valid quantity');
      return;
    }

    if (quantity > (item['available_quantity'] ?? 0)) {
      SnackBarManager.showError(context: context, message: 'Insufficient quantity available');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final inventoryService = InventoryService(apiBaseUrl);
      await inventoryService.issueInventoryToEvent(
        itemId: item['id'],
        eventId: widget.eventId,
        quantity: quantity.toDouble(),
        notes: _notesController.text.trim(),
      );

      SnackBarManager.showSuccess(context: context, message: 'Item issued successfully');
      widget.onItemIssued();
      Navigator.pop(context);
    } catch (e) {
      SnackBarManager.showError(context: context, message: 'Failed to issue item: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Item'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search items...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filteredItems = _getFilteredItems();
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Filter Row
                Row(
                  children: [
                    // Category Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                        items: _getCategories().map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                            _filteredItems = _getFilteredItems();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Material Filter
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedMaterial,
                        decoration: InputDecoration(
                          labelText: 'Material',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: colorScheme.surface,
                        ),
                        items: _getMaterials().map((material) {
                          return DropdownMenuItem(
                            value: material,
                            child: Text(material),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedMaterial = value!;
                            _filteredItems = _getFilteredItems();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Items List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No items found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or filters',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return _buildItemCard(item, colorScheme);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _showIssueDialog(Map<String, dynamic> item) {
    _quantityController.clear();
    _notesController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Issue ${item['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                hintText: 'Enter quantity to issue',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Enter any notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isSubmitting ? null : () => _issueItem(item),
            child: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Issue'),
          ),
        ],
      ),
    );
  }
}
