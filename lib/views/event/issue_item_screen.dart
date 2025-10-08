import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/inventory_service.dart';
import '../../providers/inventory_provider.dart';
import '../../utils/snackbar_manager.dart';
import '../../utils/constants.dart';

class IssueItemScreen extends ConsumerStatefulWidget {
  final int eventId;
  final VoidCallback onItemIssued;
  final VoidCallback? onNavigateToMaterialTab;

  const IssueItemScreen({
    super.key,
    required this.eventId,
    required this.onItemIssued,
    this.onNavigateToMaterialTab,
  });

  @override
  ConsumerState<IssueItemScreen> createState() => _IssueItemScreenState();
}

class _IssueItemScreenState extends ConsumerState<IssueItemScreen> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedItemName = 'All';
  bool _isSubmitting = false;
  bool _isSearchVisible = false;
  String _searchQuery = '';
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

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((item) {
        final cat = _itemCategory(item);
        return cat == _selectedCategory;
      }).toList();
    }

    // Filter by item name (only if category is selected and item name is not 'All')
    if (_selectedCategory != 'All' && _selectedItemName != 'All') {
      filtered = filtered.where((item) {
        final name = item['name']?.toString().trim().toLowerCase() ?? '';
        return name == _selectedItemName.trim().toLowerCase();
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final name = item['name']?.toString().toLowerCase() ?? '';
        final category = _itemCategory(item)?.toLowerCase() ?? '';
        final material = _itemMaterial(item)?.toLowerCase() ?? '';
        final size = _dimensions(item).toLowerCase();
        final location = _location(item).toLowerCase();
        
        return name.contains(_searchQuery.toLowerCase()) ||
               category.contains(_searchQuery.toLowerCase()) ||
               material.contains(_searchQuery.toLowerCase()) ||
               size.contains(_searchQuery.toLowerCase()) ||
               location.contains(_searchQuery.toLowerCase());
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
    print('🔍 Debug Image URL for item ${item['name']}:');
    print('  - Raw URL: $rawUrl');
    
    if (rawUrl != null && rawUrl.toString().isNotEmpty && rawUrl.toString() != 'null') {
      // Use the proper inventory service to get the image URL
      final imageUrl = ref.read(inventoryServiceProvider).getImageUrl(rawUrl.toString());
      print('  - Processed URL: $imageUrl');
      
      if (imageUrl.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              print('❌ Image load error for $imageUrl: $error');
              return _buildCategoryIcon(item);
            },
          ),
        );
      } else {
        print('  - Image URL is empty, showing category icon');
      }
    } else {
      print('  - No valid image URL found, showing category icon');
    }
    return _buildCategoryIcon(item);
  }


  // Category-based icon helper
  Widget _buildCategoryIcon(Map<String, dynamic> item) {
    final categoryName = _itemCategory(item);
    final iconData = _getCategoryIcon(categoryName);
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Icon(
        iconData,
        color: Theme.of(context).colorScheme.primary,
        size: 32,
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null || category.isEmpty) {
      return Icons.inventory;
    }
    
    switch (category.toLowerCase()) {
      case 'furniture':
        return Icons.chair;
      case 'fabric':
        return Icons.texture;
      case 'frame structure':
        return Icons.photo_library;
      case 'carpet':
        return Icons.style;
      case 'thermocol material':
        return Icons.inbox;
      case 'stationery':
        return Icons.edit;
      case 'murti set':
        return Icons.auto_awesome;
      case 'decoration':
        return Icons.celebration;
      case 'lighting':
        return Icons.lightbulb;
      case 'electrical':
        return Icons.electrical_services;
      case 'tools':
        return Icons.build;
      case 'materials':
        return Icons.category;
      default:
        return Icons.inventory;
    }
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
       child: Card(
         elevation: 3,
         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(12),
         ),
         child: Padding(
           padding: const EdgeInsets.all(12),
           child: Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               // Fixed width image
               SizedBox(
                 width: 80,
                 child: _buildItemImage(item),
               ),
               const SizedBox(width: 12),

               // --- Item Details ---
               Expanded(
                 flex: 3,
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     // Item Name
                     Text(
                       (item['name'] ?? 'Unknown Item').toString(),
                       style: const TextStyle(
                         fontSize: 16,
                         fontWeight: FontWeight.bold,
                         color: Colors.black87,
                       ),
                       maxLines: 2,
                       overflow: TextOverflow.ellipsis,
                     ),
                     const SizedBox(height: 4),

                     // Category + Dimensions Row
                     Row(
                       children: [
                         if (categoryName != null) ...[
                           Expanded(
                             flex: 2,
                             child: Text(
                               categoryName,
                               style: TextStyle(
                                 fontSize: 10,
                                 fontWeight: FontWeight.w500,
                                 color: Colors.grey[600],
                               ),
                               overflow: TextOverflow.ellipsis,
                               maxLines: 1,
                             ),
                           ),
                           const SizedBox(width: 4),
                           Container(
                             width: 2,
                             height: 2,
                             decoration: BoxDecoration(
                               color: Colors.grey[400],
                               shape: BoxShape.circle,
                             ),
                           ),
                           const SizedBox(width: 4),
                         ],
                         Expanded(
                           flex: 3,
                           child: Row(
                             children: [
                               Icon(
                                 Icons.straighten,
                                 size: 10,
                                 color: Colors.amber[700],
                               ),
                               const SizedBox(width: 2),
                               Expanded(
                                 child: Text(
                                   dims,
                                   style: TextStyle(
                                     fontSize: 10,
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
                     const SizedBox(height: 4),

                     // Location Row
                     Row(
                       children: [
                         Icon(
                           Icons.location_on,
                           size: 12,
                           color: Colors.grey[600],
                         ),
                         const SizedBox(width: 2),
                         Expanded(
                           child: Text(
                             loc,
                             style: TextStyle(
                               fontSize: 11,
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

               const SizedBox(width: 8),

               // --- Right Side Buttons & Status ---
               Expanded(
                 flex: 2,
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.end,
                   children: [
                     if (isLowStock && !isOutOfStock)
                       Container(
                         padding: const EdgeInsets.symmetric(
                           horizontal: 6,
                           vertical: 2,
                         ),
                         decoration: BoxDecoration(
                           color: Colors.amber[100],
                           borderRadius: BorderRadius.circular(8),
                           border: Border.all(color: Colors.amber[300]!),
                         ),
                         child: Text(
                           'Low Stock',
                           style: TextStyle(
                             fontSize: 10,
                             fontWeight: FontWeight.w600,
                             color: Colors.amber[800],
                           ),
                         ),
                       ),

                     if (isLowStock && !isOutOfStock)
                       const SizedBox(height: 4),

                     // Quantity Display
                     Text(
                       total > 0
                           ? 'Avail: ${_formatQty(available)}\nTotal: ${_formatQty(total)}'
                           : 'Qty: ${_formatQty(available)}',
                       style: TextStyle(
                         fontSize: 10,
                         fontWeight: FontWeight.w700,
                         color: isOutOfStock ? Colors.red[600] : Colors.grey[900],
                       ),
                       textAlign: TextAlign.right,
                       overflow: TextOverflow.ellipsis,
                       maxLines: 2,
                     ),
                     const SizedBox(height: 6),

                     // Issue / Out of Stock Button
                     SizedBox(
                       width: double.infinity,
                       child: ElevatedButton(
                         onPressed: isOutOfStock ? null : () => _showIssueDialog(item),
                         style: ElevatedButton.styleFrom(
                           backgroundColor:
                           isOutOfStock ? Colors.grey[400] : colorScheme.primary,
                           foregroundColor:
                           isOutOfStock ? Colors.grey[700] : colorScheme.onPrimary,
                           padding: const EdgeInsets.symmetric(
                             horizontal: 8,
                             vertical: 6,
                           ),
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(6),
                           ),
                         ),
                         child: Text(
                           isOutOfStock ? 'Out of Stock' : 'Issue',
                           style: const TextStyle(fontSize: 11),
                         ),
                       ),
                     ),
                   ],
                 ),
               ),
             ],
           ),
         ),
       )
        ,

      ),
    );
  }

  List<String> _getCategories() {
    final categories = _availableItems
        .map((item) => _itemCategory(item))
        .where((name) => name != null && name.trim().isNotEmpty)
        .map((name) => name!)
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }

  // Get item names within a specific category (only items with same names that appear more than once)
  List<String> _getItemNamesInCategory(String category) {
    if (category == 'All') {
      // For 'All' category, get all item names that appear more than once across all categories
      final nameCounts = <String, int>{};
      for (final item in _availableItems) {
        final name = item['name']?.toString() ?? '';
        if (name.isNotEmpty) {
          nameCounts[name] = (nameCounts[name] ?? 0) + 1;
        }
      }
      final duplicateNames = nameCounts.entries
          .where((entry) => entry.value > 1)
          .map((entry) => entry.key)
          .toList();
      duplicateNames.sort();
      return ['All', ...duplicateNames];
    } else {
      // For specific category, get item names that appear more than once in that category
      final categoryItems = _availableItems
          .where((item) => _itemCategory(item) == category)
          .toList();

      final nameCounts = <String, int>{};
      for (final item in categoryItems) {
        final name = item['name']?.toString().trim() ?? '';
        if (name.isNotEmpty) {
          final normalizedName = name.toLowerCase();
          nameCounts[normalizedName] = (nameCounts[normalizedName] ?? 0) + 1;
        }
      }

      final duplicateNames = nameCounts.entries
          .where((entry) => entry.value > 1)
          .map((entry) => entry.key)
          .toList();
      duplicateNames.sort();

      return ['All', ...duplicateNames];
    }
  }



  Future<void> _issueItem(Map<String, dynamic> item) async {
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      SnackBarManager.showError(context: context, message: 'Please enter a valid quantity');
      return;
    }

    if (quantity > _availableQuantity(item)) {
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
      
      // Navigate back and switch to material tab
      Navigator.pop(context);
      
      // Call the callback to switch to material tab if provided
      if (widget.onNavigateToMaterialTab != null) {
        widget.onNavigateToMaterialTab!();
      }
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
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.primary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Issue Item',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
                      onPressed: () {
                        setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                          _searchController.clear();
                  _searchQuery = '';
                          _filteredItems = _getFilteredItems();
                }
                        });
                      },
            icon: Icon(
              _isSearchVisible ? Icons.search_off : Icons.search,
              color: colorScheme.onPrimary,
            ),
            tooltip: _isSearchVisible ? 'Hide Search' : 'Search',
          ),
          IconButton(
            onPressed: () {
              _showFilterBottomSheet(context);
            },
            icon: Icon(
              Icons.filter_list,
              color: colorScheme.onPrimary,
            ),
            tooltip: 'Filter',
                    ),
                  ],
                ),
      body: Column(
        children: [
          // Search Bar
          if (_isSearchVisible) _buildSearchBar(colorScheme),
          
          // Filter Status
          if (_selectedCategory != 'All' || _selectedItemName != 'All' || _searchQuery.isNotEmpty)
            _buildFilterStatus(colorScheme),

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


  Widget _buildSearchBar(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, category, material, or size...',
                    prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
                  ),
                  onChanged: (value) {
                    setState(() {
            _searchQuery = value;
                      _filteredItems = _getFilteredItems();
                    });
                  },
                ),
    );
  }

  Widget _buildFilterStatus(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              () {
                final filteredItems = _getFilteredItems();
                String status = 'Showing ${filteredItems.length} of ${_availableItems.length} items';
                if (_selectedCategory != 'All') {
                  status += ' in $_selectedCategory';
                }
                if (_selectedItemName != 'All') {
                  status += ' (filtered by "$_selectedItemName")';
                }
                if (_searchQuery.isNotEmpty) {
                  status += ' (search: "$_searchQuery")';
                }
                return status;
              }(),
              style: TextStyle(
                fontSize: 12,
                              color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
                          setState(() {
                _selectedCategory = 'All';
                _selectedItemName = 'All';
                _searchQuery = '';
                _searchController.clear();
                            _filteredItems = _getFilteredItems();
                          });
                        },
            child: Icon(
              Icons.clear,
              color: colorScheme.primary,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      useRootNavigator: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: GestureDetector(
                onTap: () {},
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter Options',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              color: colorScheme.onSurfaceVariant,
                            ),
                ),
              ],
            ),
          ),

                    // Filter content
          Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Filter Section
                            Text(
                              'Filter by Category',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _getCategories().map((category) {
                                final isSelected = _selectedCategory == category;
                                return FilterChip(
                                  label: Text(
                                    category,
                              style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedCategory = category;
                                      _selectedItemName = 'All';
                                    });
                                    setModalState(() {});
                                  },
                                  backgroundColor: colorScheme.surfaceVariant,
                                  selectedColor: colorScheme.primary,
                                  checkmarkColor: colorScheme.onPrimary,
                                  side: BorderSide(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.outline,
                                    width: 1,
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 24),

                            // Item Name Filter Section (only show if category is selected)
                            if (_selectedCategory != 'All') ...[
                              Text(
                                'Filter by Item Name (${_selectedCategory})',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Builder(
                                builder: (context) {
                                  final itemNames = _getItemNamesInCategory(_selectedCategory);

                                  if (itemNames.isEmpty) {
                                    return Container(
                                      padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                                          SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                                          ),
                                          const SizedBox(width: 12),
                  Text(
                                            'Loading item names...',
                    style: TextStyle(
                                              fontSize: 14,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  if (itemNames.length <= 1) {
                                    return Container(
                                      padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                                        'No duplicate item names found in $_selectedCategory',
                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    );
                                  }

                                  return Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: itemNames.map((itemName) {
                                      final isSelected = _selectedItemName == itemName;
                                      return FilterChip(
                                        label: Text(
                                          itemName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected
                                                ? colorScheme.onPrimary
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          setState(() {
                                            _selectedItemName = itemName;
                                          });
                                          setModalState(() {});
                                        },
                                        backgroundColor: colorScheme.surfaceVariant,
                                        selectedColor: colorScheme.primary,
                                        checkmarkColor: colorScheme.onPrimary,
                                        side: BorderSide(
                                          color: isSelected
                                              ? colorScheme.primary
                                              : colorScheme.outline,
                                          width: 1,
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedCategory = 'All';
                                  _selectedItemName = 'All';
                                });
                                setModalState(() {});
                              },
                              child: const Text('Clear All'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _filteredItems = _getFilteredItems();
                                });
                                Navigator.of(context).pop();
                              },
                              child: const Text('Apply Filters'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
            onPressed: _isSubmitting ? null : () {
              // print(item);
              _issueItem(item);
              // Navigator.pop(context);
              _loadAvailableItems();
            },
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
