  import 'package:avd_decoration_application/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'dart:typed_data';
import 'inventory_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/event_provider.dart';
import '../../utils/snackbar_manager.dart';
import 'issue_inventory_screen.dart';
import 'item_issue_history_screen.dart';
import 'edit_inventory_screen.dart';
import '../custom_widget/custom_appbar.dart';

class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});

  @override
  ConsumerState<InventoryListScreen> createState() =>
      _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> {
  String _selectedCategory = 'All';
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Get unique categories from inventory items
  List<String> _getCategories(List<InventoryItem> items) {
    final categories = items.map((item) => item.categoryName).toSet().toList();
    categories.sort();
    print('🔍 Debug: Available categories for filtering: $categories');
    for (var item in items) {
      print('🔍 Debug: Item "${item.name}" has categoryName: "${item.categoryName}"');
    }
    return ['All', ...categories];
  }

  // Get filtered inventory items based on selected category and search query
  List<InventoryItem> _getFilteredItems(List<InventoryItem> items) {
    List<InventoryItem> filteredItems = items;
    
    // Filter by category
    if (_selectedCategory != 'All') {
      print('🔍 Debug: Filtering by category: "$_selectedCategory"');
      filteredItems = filteredItems
          .where((item) {
            final matches = item.categoryName == _selectedCategory;
            print('🔍 Debug: Item "${item.name}" categoryName: "${item.categoryName}" matches "$_selectedCategory": $matches');
            return matches;
          })
          .toList();
      print('🔍 Debug: After category filtering: ${filteredItems.length} items');
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredItems = filteredItems
          .where((item) => 
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.categoryName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (item.material?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              item.storageLocation.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (item.dimensions?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (item.color?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (item.size?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (item.fabricType?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (item.pattern?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (item.frameType?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (item.setNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
              (item.thermocolType?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false))
          .toList();
    }
    
    return filteredItems;
  }
  @override
  Widget build(BuildContext context) {
    final inventoryItems = ref.watch(inventoryProvider);
    final inventoryNotifier = ref.watch(inventoryProvider.notifier);
    final currentUser = ref.watch(authProvider);
    final isAdmin = currentUser?.role == 'admin';
    final colorScheme = Theme.of(context).colorScheme;

    // Add ONLY this method to your existing _InventoryListScreenState class
    void _showFilterBottomSheet(BuildContext context, List<InventoryItem> inventoryItems) {
      final colorScheme = Theme.of(context).colorScheme;

      showModalBottomSheet(


        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.6, // 60% of screen

          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Title
                Text(
                  'Filter by Category',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),

                // Filter chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _getCategories(inventoryItems).map((category) {
                    final isSelected = _selectedCategory == category;
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
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
                          });
                          Navigator.pop(context);
                        },
                        backgroundColor: colorScheme.surface,
                        selectedColor: colorScheme.primary,
                        checkmarkColor: colorScheme.onPrimary,
                        side: BorderSide(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Clear filter button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'All';
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('Clear Filter'),
                  ),
                ),

                // Bottom padding
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Inventory Overview',
        showBackButton: false,
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.search_off : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              final inventoryItems = ref.watch(inventoryProvider); // This is already a List<InventoryItem>
              _showFilterBottomSheet(context, inventoryItems);
            },
          ),
        ],
      ),
      backgroundColor: colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.background,
            ],
            stops: const [0.0, 0.25],
          ),
        ),
        child: Container(
          margin: EdgeInsets.only(
            top: context.responsive(
              mobile: 15.0,
              tablet: 18.0,
              desktop: 24.0,
            ),
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                context.responsive(
                  mobile: 28.0,
                  tablet: 28.0,
                  desktop: 28.0,
                ),
              ),
            ),
          ),
          padding: const EdgeInsets.only(
              bottom: 100), // Add bottom padding to avoid nav bar
          child: Column(
            children: [
              // Search Bar
              if (_isSearchVisible) _buildSearchBar(),
              // Main Body
              Expanded(
                child: _buildBody(inventoryItems, inventoryNotifier, isAdmin),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: isAdmin
          ? Container(
              margin: const EdgeInsets.only(
                  bottom: 100), // Space above bottom nav bar
              child: FloatingActionButton(
                heroTag: "inventory_add_button",
                onPressed: () async {
                  final result = await PersistentNavBarNavigator.pushNewScreen(
                    context,
                    screen: const InventoryFormPage(),
                    withNavBar: false,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );

                  // Handle the result from form submission and refresh data
                  if (result != null && result is Map && result['success'] == true) {
                    // Refresh inventory data to show the new item
                    try {
                      await ref.read(inventoryProvider.notifier).refreshInventoryData();
                      print('✅ Inventory data refreshed after adding new item');
                    } catch (e) {
                      print('⚠️ Warning: Could not refresh inventory data: $e');
                    }
                  }
                  print('Form result received: $result');
                  if (result != null && result is Map<String, dynamic>) {
                    print('Result is valid map, adding to inventory');

                    // Create new inventory item
                    final newItem = InventoryItem(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: result['name'] ?? 'New Item',
                      category: '1', // Default category ID
                      categoryName: result['category'] ?? 'Unknown',
                      unit: 'piece', // Default unit
                      storageLocation: result['location'] ?? 'Unknown',
                      notes: result['notes'] ?? '',
                      availableQuantity: (result['quantity'] ?? 1).toDouble(),
                      totalStock: (result['quantity'] ?? 1).toDouble(),
                      material: result['material'] ?? 'Unknown',
                      createdAt: DateTime.now().toIso8601String(),
                      status: (result['quantity'] ?? 0) > 5
                          ? 'In Stock'
                          : 'Low Stock',
                      imageBytes: result['imageBytes'] != null
                          ? Uint8List.fromList(result['imageBytes'])
                          : null,
                      imageName: result['imageName'],
                    );

                    print('New item created: ${newItem.toMap()}');

                    // Add to provider
                    ref
                        .read(inventoryProvider.notifier)
                        .addItem(newItem.toMap());
                    print('Inventory items count: ${inventoryItems.length}');

                    SnackBarManager.showSuccess(
                      context: context,
                      message: '${result['name']} added to inventory successfully!',
                    );
                  } else {
                    print('Result is null or not a map: $result');
                  }
                },
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.surface,
                child: const Icon(Icons.add),
                elevation: 12,
                tooltip: 'Add new inventory item',
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search items, categories, materials, dimensions...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              child: Icon(
                Icons.clear,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(List<InventoryItem> inventoryItems,
      InventoryNotifier inventoryNotifier, bool isAdmin) {
    final colorScheme = Theme.of(context).colorScheme;

    if (inventoryNotifier.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      );
    }

    if (inventoryNotifier.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading inventory',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${inventoryNotifier.error!}\n\nPull down to refresh',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => inventoryNotifier.refreshInventoryData(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header Section with Stats
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.04),
                spreadRadius: 0,
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Items',
                      value: inventoryNotifier.totalItemsCount.toString(),
                      icon: Icons.inventory,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Categories',
                      value: inventoryNotifier.totalCategoriesCount.toString(),
                      icon: Icons.category,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Total Stock',
                      value: inventoryNotifier.totalStockCount.toStringAsFixed(0),
                      icon: Icons.storage,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Low Stock',
                      value: inventoryNotifier.lowStockCount.toString(),
                      icon: Icons.warning,
                      color: colorScheme.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // User access message for non-admin users
        if (!isAdmin) ...[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You have read-only access to inventory. Contact an administrator to add, edit, or delete items.',
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Inventory List
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await inventoryNotifier.loadInventoryData();
            },
            child: () {
              final filteredItems = _getFilteredItems(inventoryItems);
              return filteredItems.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        padding: const EdgeInsets.only(
                            bottom: 80), // Added bottom padding for FAB
                        child: _buildNoInventoryCard(),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          10, 10, 10, 60), // Added bottom padding for FAB
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _buildInventoryCard(item, isAdmin);
                      },
                    );
            }(),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              color: color,
              size: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper method to get formatted dimensions display
  String _getDimensionsDisplay(InventoryItem item) {
    List<String> dimensionParts = [];
    
    // Add general dimensions if available
    if (item.dimensions != null && item.dimensions!.isNotEmpty) {
      dimensionParts.add(item.dimensions!);
    }
    
    // Add width and length if available
    if (item.width != null && item.length != null) {
      dimensionParts.add('${item.width} × ${item.length}');
    } else if (item.width != null) {
      dimensionParts.add('W: ${item.width}');
    } else if (item.length != null) {
      dimensionParts.add('L: ${item.length}');
    }
    
    // Add size if available
    if (item.size != null && item.size!.isNotEmpty) {
      dimensionParts.add('Size: ${item.size}');
    }
    
    // Add color if available
    if (item.color != null && item.color!.isNotEmpty) {
      dimensionParts.add('Color: ${item.color}');
    }
    
    // Add category-specific dimensions
    switch (item.categoryName) {
      case 'Fabric':
        if (item.fabricType != null && item.fabricType!.isNotEmpty) {
          dimensionParts.add('Type: ${item.fabricType}');
        }
        if (item.pattern != null && item.pattern!.isNotEmpty) {
          dimensionParts.add('Pattern: ${item.pattern}');
        }
        break;
      case 'Carpet':
        // Carpet type field removed - no longer displayed
        break;
      case 'Frame Structure':
        if (item.frameType != null && item.frameType!.isNotEmpty) {
          dimensionParts.add('Frame: ${item.frameType}');
        }
        break;
      case 'Murti Set':
        if (item.setNumber != null && item.setNumber!.isNotEmpty) {
          dimensionParts.add('Set: ${item.setNumber}');
        }
        break;
      case 'Thermocol Material':
        if (item.thermocolType != null && item.thermocolType!.isNotEmpty) {
          dimensionParts.add('Type: ${item.thermocolType}');
        }
        if (item.density != null) {
          dimensionParts.add('Density: ${item.density}');
        }
        break;
    }
    
    return dimensionParts.isNotEmpty ? dimensionParts.join(' • ') : 'No dimensions';
  }

  Widget _buildInventoryCard(InventoryItem item, bool isAdmin) {
    return Opacity(
      opacity: isAdmin ? 1.0 : 0.7,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
              spreadRadius: 0,
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(20),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: item.itemImage != null && item.itemImage!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      ref
                          .read(inventoryServiceProvider)
                          .getImageUrl(item.itemImage),
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _getCategoryIcon(item.categoryName),
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        );
                      },
                    ),
                  )
                : Icon(
                    _getCategoryIcon(item.categoryName),
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
          ),
          title: Text(
            item.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                '${item.categoryName} • ${item.unit}',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              // Dimensions display
              Row(
                children: [
                  Icon(
                    Icons.straighten,
                    size: 16,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getDimensionsDisplay(item),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.tertiary,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      item.storageLocation,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(_getItemStatus(item)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _getStatusColor(_getItemStatus(item)),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getItemStatus(item),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(_getItemStatus(item)),
                  ),
                ),
              ),
              const SizedBox(height: 3),

              Text(
                'Available: ${item.availableQuantity.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                'Total: ${item.totalStock.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          onTap: isAdmin
              ? () {
                  _showItemOptions(context, item.toMap());
                }
              : null,
        ),
      ),
    );
  }

  // Helper method to get item status based on quantity
  String _getItemStatus(InventoryItem item) {
    final quantity = item.availableQuantity;
    if (quantity <= 0) {
      return 'Out of Stock';
    } else if (quantity <= 5) {
      return 'Low Stock';
    } else {
      return 'In Stock';
    }
  }

  void _showItemOptions(BuildContext context, Map<String, dynamic> item) {
    final currentUser = ref.read(authProvider);
    final isAdmin = currentUser?.role == 'admin';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.26),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Item Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Options - Use Expanded instead of Flexible
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Admin-only actions
                    if (isAdmin) ...[
                      _buildOptionTile(
                        icon: Icons.edit,
                        iconColor: Theme.of(context).colorScheme.primary,
                        title: 'Edit ${item['name']}',
                        onTap: () {
                          Navigator.pop(context);
                          _editItem(item);
                        },
                      ),
                      _buildOptionTile(
                        icon: Icons.delete_outline,
                        iconColor: Theme.of(context).colorScheme.error,
                        title: 'Delete ${item['name']}',
                        onTap: () {
                          Navigator.pop(context);
                          _deleteItem(item);
                        },
                      ),
                    ],
                    // Both admin and user can issue to events
                    _buildOptionTile(
                      icon: Icons.event_note,
                      iconColor: Theme.of(context).colorScheme.tertiary,
                      title: 'Issue to Event',
                      onTap: () {
                        Navigator.pop(context);
                        _issueToEvent(item);
                      },
                    ),
                    _buildOptionTile(
                      icon: Icons.history,
                      iconColor: Theme.of(context).colorScheme.tertiary,
                      title: 'View Issue History',
                      onTap: () {
                        Navigator.pop(context);
                        PersistentNavBarNavigator.pushNewScreen(
                          context,
                          screen: ItemIssueHistoryPage(
                            itemId: item['id'],
                            itemName: item['name'],
                          ),
                          withNavBar: false,
                          pageTransitionAnimation:
                              PageTransitionAnimation.cupertino,
                        );
                      },
                    ),

                    // Extra bottom padding to ensure last item is fully visible
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }

  void _editItem(Map<String, dynamic> item) {
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: EditInventoryPage(itemId: item['id']),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  void _deleteItem(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${item['name']}?'),
        content: Text(
            'Are you sure you want to delete this item? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog first

              // Get the navigator context before showing loading dialog
              final navigatorContext = Navigator.of(context, rootNavigator: true).context;

              // Show loading indicator
              showDialog(
                context: navigatorContext,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              try {
                await ref.read(inventoryProvider.notifier).deleteInventoryItem(
                      id: int.parse(item['id'].toString()),
                    );

                // Close loading dialog safely
                if (mounted && Navigator.of(navigatorContext).canPop()) {
                  Navigator.pop(navigatorContext);
                }

                // Show success message
                if (mounted) {
                  SnackBarManager.showSuccess(
                    context: context,
                    message: '${item['name']} deleted successfully!',
                  );
                }
              } catch (e) {
                // Close loading dialog safely
                if (mounted && Navigator.of(navigatorContext).canPop()) {
                  Navigator.pop(navigatorContext);
                }

                // Show error message
                if (mounted) {
                  SnackBarManager.showError(
                    context: context,
                    message: 'Failed to delete ${item['name']}: ${e.toString()}',
                  );
                }
              }
            },
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _issueToEvent(Map<String, dynamic> item) {
    print('Opening issue screen for item: ${item['name']}');
    PersistentNavBarNavigator.pushNewScreen(
      context,
      screen: IssueInventoryPage(inventoryItem: item),
      withNavBar: false,
      pageTransitionAnimation: PageTransitionAnimation.cupertino,
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Furniture':
        return Icons.chair;
      case 'Fabric':
        return Icons.texture;
      case 'Frame Structure':
        return Icons.photo_library;
      case 'Carpet':
        return Icons.style;
      case 'Thermocol Material':
        return Icons.inbox;
      case 'Stationery':
        return Icons.edit;
      case 'Murti Set':
        return Icons.auto_awesome;
      default:
        return Icons.inventory;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Stock':
        return Theme.of(context).colorScheme.primary;
      case 'Low Stock':
        return Theme.of(context).colorScheme.tertiary;
      case 'Out of Stock':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  Widget _buildNoInventoryCard() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Empty inventory icon in a circle
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // "No Inventory Available" text
          Text(
            'No Inventory Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Descriptive text
          Text(
            'There are no inventory items to display.\nAdd some items to get started.',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Add Inventory button
          ElevatedButton.icon(
            onPressed: () async {
              // Navigate to add inventory screen
              final result = await PersistentNavBarNavigator.pushNewScreen(
                context,
                screen: const InventoryFormPage(),
                withNavBar: false,
                pageTransitionAnimation: PageTransitionAnimation.cupertino,
              );

              // Handle the result from form submission and refresh data
              if (result != null && result is Map && result['success'] == true) {
                // Refresh inventory data to show the new item
                try {
                  await ref.read(inventoryProvider.notifier).refreshInventoryData();
                  print('✅ Inventory data refreshed after adding new item');
                } catch (e) {
                  print('⚠️ Warning: Could not refresh inventory data: $e');
                }
              }
            },
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 20,
            ),
            label: Text(
              'Add Inventory',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}




// Issued Items List Screen
class IssuedItemsListScreen extends ConsumerStatefulWidget {
  const IssuedItemsListScreen({super.key});

  @override
  ConsumerState<IssuedItemsListScreen> createState() =>
      _IssuedItemsListScreenState();
}

class _IssuedItemsListScreenState extends ConsumerState<IssuedItemsListScreen> {
  @override
  Widget build(BuildContext context) {
    final issuedItems = ref.watch(inventoryProvider.notifier).issuedItems;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(
        title: 'Issued Items to Events',
        showBackButton: true,
        curvedBottom: true,
        borderRadius: 20.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.background,
            ],
            stops: const [0.0, 0.25],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28.0),
            ),
          ),
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
        children: [
          // Header Section with Stats
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.history_edu,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Issued Items Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'Total Issues',
                        value: issuedItems.length.toString(),
                        icon: Icons.inventory,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Unique Items',
                        value: issuedItems
                            .map((item) => item['itemId'])
                            .toSet()
                            .length
                            .toString(),
                        icon: Icons.category,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'Events',
                        value: issuedItems
                            .map((item) => item['eventName'])
                            .toSet()
                            .length
                            .toString(),
                        icon: Icons.event,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Issued Items List
          Expanded(
            child: issuedItems.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      await ref
                          .read(inventoryProvider.notifier)
                          .loadInventoryData();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(24),
                      itemCount: issuedItems.length,
                      itemBuilder: (context, index) {
                        final item = issuedItems[index];
                        return _buildIssuedItemCard(item);
                      },
                    ),
                  ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.06),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_edu,
              size: 80,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No items issued yet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'When you issue inventory items to events, they will appear here',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back to Inventory'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.surface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIssuedItemCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.event_note,
            color: Theme.of(context).colorScheme.tertiary,
            size: 24,
          ),
        ),
        title: Text(
          '${item['quantity']} × ${item['itemName']}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.event,
                  size: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Event: ${item['eventName']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Issued: ${item['issueDate']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.inventory,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Remaining: ${item['remainingQuantity']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.tertiary,
              width: 1,
            ),
          ),
          child: Text(
            'Issued',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.tertiary,
            ),
          ),
        ),
      ),
    );
  }

}

// Inventory Issue Screen
class InventoryIssueScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> inventoryItem;

  const InventoryIssueScreen({super.key, required this.inventoryItem});

  @override
  ConsumerState<InventoryIssueScreen> createState() =>
      _InventoryIssueScreenState();
}

class _InventoryIssueScreenState extends ConsumerState<InventoryIssueScreen> {
  // Get real events from the event provider
  List<Map<String, dynamic>> get currentEvents {
    final events = ref.watch(eventProvider);
    return events
        .map((e) => {
              'id': e.id.toString(),
              'name': e.name ?? '',
              'date': e.date?.toIso8601String() ?? '',
              'location': e.location ?? '',
              'status': e.status ?? '',
            })
        .toList();
  }

  Map<String, dynamic>? selectedEvent;
  int issueQuantity = 1;

  @override
  void initState() {
    super.initState();
    // Debug: Print events to console
    print('Current Events: ${currentEvents.length}');
    for (var event in currentEvents) {
      print('Event: ${event['name']} - ${event['date']}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: CustomAppBar(
        title: 'Issue ${widget.inventoryItem['name']}',
        showBackButton: true,
        curvedBottom: true,
        borderRadius: 20.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.background,
            ],
            stops: const [0.0, 0.25],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(28.0),
            ),
          ),
          padding: const EdgeInsets.only(bottom: 100),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Inventory Item Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Item Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Item Image or Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: widget.inventoryItem['imageBytes'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.memory(
                                  widget.inventoryItem['imageBytes'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      _getCategoryIcon(
                                          widget.inventoryItem['category']),
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 32,
                                    );
                                  },
                                ),
                              )
                            : Icon(
                                _getCategoryIcon(
                                    widget.inventoryItem['category']),
                                color: Theme.of(context).colorScheme.primary,
                                size: 32,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.inventoryItem['name'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.inventoryItem['category'],
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.style,
                                  size: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.inventoryItem['material'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.inventoryItem['location'] ??
                                      'No location',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inventory,
                                    size: 16,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Available: ${widget.inventoryItem['quantity']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Quantity Selection
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.numbers,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Issue Quantity',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: issueQuantity > 1
                              ? () => setState(() => issueQuantity--)
                              : null,
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: issueQuantity > 1
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.2),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                issueQuantity.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'units',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed:
                              issueQuantity < widget.inventoryItem['quantity']
                                  ? () => setState(() => issueQuantity++)
                                  : null,
                          icon: Icon(
                            Icons.add_circle_outline,
                            color:
                                issueQuantity < widget.inventoryItem['quantity']
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available: ${ref.watch(inventoryProvider).firstWhere((item) => item.id == widget.inventoryItem['id'], orElse: () => InventoryItem(id: '', name: '', category: '', categoryName: '', unit: '', storageLocation: '', notes: '', availableQuantity: 0.0, totalStock: 0.0)).availableQuantity}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'Remaining: ${(ref.watch(inventoryProvider).firstWhere((item) => item.id == widget.inventoryItem['id'], orElse: () => InventoryItem(id: '', name: '', category: '', categoryName: '', unit: '', storageLocation: '', notes: '', availableQuantity: 0.0, totalStock: 0.0)).availableQuantity) - issueQuantity}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ((ref
                                          .watch(inventoryProvider)
                                          .firstWhere(
                                              (item) =>
                                                  item.id ==
                                                  widget.inventoryItem['id'],
                                              orElse: () => InventoryItem(
                                                  id: '',
                                                  name: '',
                                                  category: '',
                                                  categoryName: '',
                                                  unit: '',
                                                  storageLocation: '',
                                                  notes: '',
                                                  availableQuantity: 0.0,
                                                  totalStock: 0.0))
                                          .availableQuantity) -
                                      issueQuantity) <
                                  5
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Event Selection
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        color: Theme.of(context).colorScheme.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Select Event (${currentEvents.length} available)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (currentEvents.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 48,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events available',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create some events first to issue inventory',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Navigate to events tab
                              // This will be handled by the parent navigation
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Create Event'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...currentEvents.map((event) => _buildEventCard(event)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // This Item's Issue History Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history_edu,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Issue History for ${widget.inventoryItem['name']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildItemIssueHistory(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Recently Issued Items Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.history,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recently Issued Items',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildIssuedItemsList(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Issue Button
            Container(
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: selectedEvent != null
                      ? [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.primary.withOpacity(0.8)
                        ]
                      : [
                          Theme.of(context).colorScheme.onSurfaceVariant,
                          Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.8)
                        ],
                ),
                boxShadow: selectedEvent != null
                    ? [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed:
                    selectedEvent != null ? () => _issueInventory() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedEvent != null
                          ? 'Issue to ${selectedEvent!['name']}'
                          : 'Select an Event First',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final isSelected = selectedEvent?['id'] == event['id'];

    return GestureDetector(
      onTap: () => setState(() => selectedEvent = event),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.event,
                color: isSelected
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['name'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Event ID: ${event['id']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Created: ${event['date'] ?? 'N/A'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _issueInventory() {
    if (selectedEvent != null) {
      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Issue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to issue:'),
              const SizedBox(height: 8),
              Text(
                '${issueQuantity} × ${widget.inventoryItem['name']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('to event: ${selectedEvent!['name']}?'),
              const SizedBox(height: 8),
              Text(
                'Available after issue: ${widget.inventoryItem['quantity'] - issueQuantity}',
                style: TextStyle(
                  color: (widget.inventoryItem['quantity'] - issueQuantity) < 5
                      ? Theme.of(context).colorScheme.tertiary
                      : Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close confirmation dialog
                _confirmIssue();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.surface,
              ),
              child: const Text('Confirm Issue'),
            ),
          ],
        ),
      );
    }
  }

  void _confirmIssue() {
    // Update inventory quantity using the provider
    ref.read(inventoryProvider.notifier).issueInventory(
          widget.inventoryItem['id'],
          issueQuantity,
          selectedEvent!['name'],
        );

    // Show success message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle,
                color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(width: 8),
            const Text('Success!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${issueQuantity} × ${widget.inventoryItem['name']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('has been issued to ${selectedEvent!['name']}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory,
                      color: Theme.of(context).colorScheme.primary, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Remaining: ${widget.inventoryItem['quantity'] - issueQuantity}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Inventory quantity has been updated. The change will be reflected across all screens.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to inventory list
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.surface,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Furniture':
        return Icons.chair;
      case 'Fabric':
        return Icons.texture;
      case 'Frame Structure':
        return Icons.photo_library;
      case 'Carpet':
        return Icons.style;
      case 'Thermocol Material':
        return Icons.inbox;
      case 'Stationery':
        return Icons.edit;
      case 'Murti Set':
        return Icons.auto_awesome;
      default:
        return Icons.inventory;
    }
  }

  Widget _buildItemIssueHistory() {
    final issuedItems = ref.read(inventoryProvider.notifier).issuedItems;

    // Filter items for this specific inventory item
    final itemIssues = issuedItems
        .where((item) => item['itemId'] == widget.inventoryItem['id'])
        .toList();

    if (itemIssues.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No issues for this item yet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When you issue this item to events, they will appear here',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: itemIssues
          .map((issue) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .tertiary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.event_note,
                        color: Theme.of(context).colorScheme.tertiary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${issue['quantity']} units issued',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Event: ${issue['eventName']}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Date: ${issue['issueDate']} • Remaining: ${issue['remainingQuantity']}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildIssuedItemsList() {
    final issuedItems = ref.read(inventoryProvider.notifier).issuedItems;

    if (issuedItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No items issued yet',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Issued items will appear here',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Show last 5 issued items
    final recentItems = issuedItems.take(5).toList();

    return Column(
      children: recentItems
          .map((item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item['quantity']} × ${item['itemName']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Issued to: ${item['eventName']}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Date: ${item['issueDate']} • Remaining: ${item['remainingQuantity']}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
