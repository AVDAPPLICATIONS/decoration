import 'package:avd_decoration_application/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MaterialTab extends ConsumerStatefulWidget {
  final Map<String, dynamic> event;
  final bool isAdmin;

  const MaterialTab({Key? key, required this.event, required this.isAdmin})
      : super(key: key);

  @override
  ConsumerState<MaterialTab> createState() => _MaterialTabState();
}

class _MaterialTabState extends ConsumerState<MaterialTab> {
  // List to store issued inventory items for this event
  List<Map<String, dynamic>> issuedInventoryItems = [];

  // Available items for dropdown - populated from API
  List<Map<String, dynamic>> availableItems = [];
  bool isLoadingItems = false;

  @override
  void initState() {
    super.initState();
    // Load inventory items when the widget initializes
    _loadInventoryItems();
    // Load saved issued items
    _loadSavedIssuedItems();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    print(
        'Building MaterialTab with ${issuedInventoryItems.length} issued items');
    if (issuedInventoryItems.isNotEmpty) {
      print('Issued items: $issuedInventoryItems');
    }
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh both available items and issued items
          await _refreshAllData();
        },
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        strokeWidth: 3.0,
        displacement: 60.0,
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            // This ensures the RefreshIndicator works properly
            return false;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Refresh Status Indicator
                if (isLoadingItems) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary.withOpacity(0.1),
                          colorScheme.primary.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: colorScheme.primary.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                colorScheme.primary),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Refreshing Data...',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Loading inventory items and issued items',
                              style: TextStyle(
                                color: colorScheme.primary.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                // Available Inventory Items Count Only
                if (availableItems.isNotEmpty) ...[
                  // Header for available items (count only)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: colorScheme.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.inventory,
                            color: colorScheme.error, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Available Inventory Items (${availableItems.length})',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Issued Inventory Items Section
                if (issuedInventoryItems.isNotEmpty) ...[
                  // Header for issued items
                  GestureDetector(
                    onLongPress: () {
                      // Show confirmation dialog to clear items
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear All Issued Items'),
                          content: const Text(
                              'Are you sure you want to clear all issued items? This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _clearIssuedItems();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.onError,
                              ),
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: colorScheme.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.inventory_2,
                              color: colorScheme.primary, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Issued Inventory Items (${issuedInventoryItems.length})',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.info_outline,
                            color: colorScheme.primary.withOpacity(0.6),
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Issued items list
                  ...issuedInventoryItems.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return _buildSwipeableIssuedInventoryCard(item, index);
                  }),
                ],

                // Loading indicator
                if (isLoadingItems) ...[
                  Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Loading inventory items...',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // No Items Available Message (when both lists are empty and not loading)
                if (availableItems.isEmpty &&
                    issuedInventoryItems.isEmpty &&
                    !isLoadingItems) ...[
                  Container(
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: colorScheme.surfaceVariant,
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: colorScheme.primary.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No Inventory Available',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'There are no inventory items to display.\nAdd some items to get started.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (widget.isAdmin)
                          ElevatedButton.icon(
                            onPressed: () => _showAddInventoryDialog(context),
                            icon: Icon(Icons.add, color: colorScheme.onPrimary),
                            label: Text(
                              'Add Inventory',
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Contact an administrator to add inventory items.',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showAddInventoryDialog(context),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              elevation: 4,
            )
          : null,
    );
  }

  Widget _buildSwipeableIssuedInventoryCard(
      Map<String, dynamic> item, int index) {
    return Dismissible(
      key: Key('issued_item_${item['id']}_$index'),
      direction: DismissDirection.endToStart, // Swipe right to left
      background: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.orange,
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.keyboard_return,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              'Return to\nInventory',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        final shouldDismiss = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Return Item to Inventory'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to return this item to inventory?'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Item: ${item['name'] ?? 'Unknown'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Quantity: ${item['quantity'] ?? 0}'),
                      if (item['notes'] != null && item['notes'].isNotEmpty)
                        Text('Notes: ${item['notes']}'),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Return to Inventory'),
              ),
            ],
          ),
        );

        // If user confirmed, remove item immediately
        if (shouldDismiss == true) {
          _returnItemToInventory(item, index);
        }

        return shouldDismiss;
      },
      child: _buildIssuedInventoryCard(item),
    );
  }

  Widget _buildIssuedInventoryCard(Map<String, dynamic> item) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.surface, colorScheme.surfaceVariant],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 25,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Item Icon
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    _getCategoryIcon(item['category'] ?? 'General'),
                    color: colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),

                // Item Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? 'Unknown Item',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item['category'] ?? 'General',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Quantity
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Qty: ${item['quantity'] ?? 0}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border:
                            Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(
                        'ISSUED',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Notes and Stock Info section
            const SizedBox(height: 12),
            Row(
              children: [
                // Notes section
                if (item['notes'] != null && item['notes'].isNotEmpty) ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.note,
                                  size: 16, color: Colors.blue[600]),
                              const SizedBox(width: 6),
                              Text(
                                'Notes:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['notes'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                // Stock info section
                if (item['stock_info'] != null) ...[
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.inventory,
                                  size: 16, color: Colors.orange[600]),
                              const SizedBox(width: 6),
                              Text(
                                'Stock:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item['stock_info']['new_quantity']} remaining',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            'Changed: ${item['stock_info']['change']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
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

  Future<List<Map<String, dynamic>>> _fetchInventoryItems() async {
    const String apiUrl = '${apiBaseUrl}api/inventory/items/getList';

    try {
      print('Fetching inventory items from: $apiUrl');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode({}), // Empty body for POST request
      );

      print('Items API Response status code: ${response.statusCode}');
      print('Items API Response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          print('Parsed response data: $responseData');

          // Handle your specific API response structure
          if (responseData is Map &&
              responseData['success'] == true &&
              responseData['data'] != null) {
            final items = List<Map<String, dynamic>>.from(responseData['data']);
            print('Extracted items: $items');
            return items;
          } else if (responseData is List) {
            return List<Map<String, dynamic>>.from(responseData);
          } else if (responseData is Map && responseData['data'] != null) {
            return List<Map<String, dynamic>>.from(responseData['data']);
          } else if (responseData is Map && responseData['items'] != null) {
            return List<Map<String, dynamic>>.from(responseData['items']);
          } else {
            print('Unexpected response structure: $responseData');
            return [];
          }
        } catch (e) {
          print('Error parsing items response: $e');
          return [];
        }
      } else {
        print('Failed to fetch items: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Network error fetching items: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> _updateInventoryIssuance(
      Map<String, dynamic> updateData) async {
    const String apiUrl = '${apiBaseUrl}/api/inventory/issuances/update';

    try {
      print('Making API call to: $apiUrl');
      print('Request data: $updateData');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          return responseData;
        } catch (e) {
          return {
            'success': false,
            'message': 'Invalid JSON response: ${e.toString()}',
          };
        }
      } else {
        // Handle HTTP error
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['error'] ??
                errorData['message'] ??
                'HTTP Error: ${response.statusCode}',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'HTTP Error: ${response.statusCode} - ${response.body}',
          };
        }
      }
    } catch (e) {
      // Handle network or parsing errors
      print('Network error: $e');
      return {
        'success': false,
        'message': 'Network Error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> _createInventoryIssuance(
      Map<String, dynamic> transactionData) async {
    const String apiUrl = '${apiBaseUrl}/api/inventory/issuances/create';

    try {
      print('Making API call to: $apiUrl');
      print('Request data: $transactionData');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode(transactionData),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          return responseData;
        } catch (e) {
          return {
            'success': false,
            'message': 'Invalid JSON response: ${e.toString()}',
          };
        }
      } else {
        // Handle HTTP error
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['error'] ??
                errorData['message'] ??
                'HTTP Error: ${response.statusCode}',
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'HTTP Error: ${response.statusCode} - ${response.body}',
          };
        }
      }
    } catch (e) {
      // Handle network or parsing errors
      print('Network error: $e');
      return {
        'success': false,
        'message': 'Network Error: ${e.toString()}',
      };
    }
  }

  // Save issued items to local storage
  Future<void> _saveIssuedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventId = widget.event['id']?.toString() ?? 'unknown';
      final key = 'issued_items_event_$eventId';

      // Convert list to JSON string
      final itemsJson = json.encode(issuedInventoryItems);
      await prefs.setString(key, itemsJson);

      print(
          'Saved ${issuedInventoryItems.length} issued items for event $eventId');
    } catch (e) {
      print('Error saving issued items: $e');
    }
  }

  // Load issued items from local storage
  Future<void> _loadSavedIssuedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventId = widget.event['id']?.toString() ?? 'unknown';
      final key = 'issued_items_event_$eventId';

      final itemsJson = prefs.getString(key);
      if (itemsJson != null && itemsJson.isNotEmpty) {
        final List<dynamic> itemsList = json.decode(itemsJson);
        final loadedItems = itemsList.cast<Map<String, dynamic>>();

        setState(() {
          issuedInventoryItems = loadedItems;
        });

        print(
            'Loaded ${issuedInventoryItems.length} saved issued items for event $eventId');
      } else {
        print('No saved issued items found for event $eventId');
      }
    } catch (e) {
      print('Error loading saved issued items: $e');
    }
  }

  // Return item to inventory
  void _returnItemToInventory(Map<String, dynamic> item, int index) async {
    print('Returning item to inventory: $item');

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Prepare the API request data
      final returnData = {
        "id": item['issuance_id'], // The issuance ID from when item was issued
        "item_id": item['id'],
        "transaction_type": "IN", // IN means returning to inventory
        "quantity": item['quantity'],
        "event_id": widget.event['id'] ?? 0,
        "notes": "Returned to inventory: ${item['notes'] ?? 'No notes'}"
      };

      print('Making return API call with data: $returnData');

      // Make API call to update issuance
      final response = await _updateInventoryIssuance(returnData);

      // Close loading dialog
      Navigator.pop(context);

      if (response['success'] == true) {
        // Remove item from the list
        setState(() {
          issuedInventoryItems.removeAt(index);
        });

        // Save updated list to local storage
        _saveIssuedItems();

        // Show success message
        if (mounted) {
          final stockUpdate = response['data']?['stock_update'];
          final newQuantity = stockUpdate?['new_quantity'] ?? 'Unknown';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item returned to inventory successfully!',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Item: ${item['name']} (Qty: ${item['quantity']})'),
                  Text('Stock updated: $newQuantity available'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Undo',
                textColor: Colors.white,
                onPressed: () {
                  // Add item back to the list
                  setState(() {
                    issuedInventoryItems.insert(index, item);
                  });
                  _saveIssuedItems();
                },
              ),
            ),
          );
        }
      } else {
        // API call failed, but we can still remove item locally
        setState(() {
          issuedInventoryItems.removeAt(index);
        });

        _saveIssuedItems();

        // Show warning message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item returned locally (API Error)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Item: ${item['name']} (Qty: ${item['quantity']})'),
                  Text(
                      'Error: ${response['message'] ?? 'API connection failed'}'),
                ],
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('Error returning item to inventory: $e');
      final returnData = {
        "id": item['issuance_id'], // The issuance ID from when item was issued
        "item_id": item['id'],
        "transaction_type": "IN", // IN means returning to inventory
        "quantity": item['quantity'],
        "event_id": widget.event['id'] ?? 0,
        "notes": "Returned to inventory: ${item['notes'] ?? 'No notes'}"
      };
      print(returnData);
      // Close loading dialog
      Navigator.pop(context);

      // Remove item locally even if API fails
      setState(() {
        issuedInventoryItems.removeAt(index);
      });

      _saveIssuedItems();

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Item returned locally (Network Error)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Item: ${item['name']} (Qty: ${item['quantity']})'),
                Text('Error: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // Clear all issued items (for testing/reset purposes)
  Future<void> _clearIssuedItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventId = widget.event['id']?.toString() ?? 'unknown';
      final key = 'issued_items_event_$eventId';

      await prefs.remove(key);
      setState(() {
        issuedInventoryItems.clear();
      });

      print('Cleared all issued items for event $eventId');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All issued items cleared'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error clearing issued items: $e');
    }
  }

  // Refresh all data (available items and issued items)
  Future<void> _refreshAllData() async {
    print('Refreshing all data...');

    // Refresh available inventory items from API
    await _loadInventoryItems();

    // Reload issued items from local storage
    await _loadSavedIssuedItems();

    print('All data refreshed successfully');
  }

  Future<void> _loadInventoryItems() async {
    if (isLoadingItems) return;

    setState(() {
      isLoadingItems = true;
    });

    try {
      final items = await _fetchInventoryItems();
      print('Loaded ${items.length} items: $items');
      setState(() {
        availableItems = items;
        isLoadingItems = false;
      });
    } catch (e) {
      setState(() {
        isLoadingItems = false;
      });
      print('Error loading inventory items: $e');
    }
  }

  void _showAddInventoryDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    Map<String, dynamic>? selectedItem;
    List<Map<String, dynamic>> dialogItems = [];
    bool dialogLoadingItems = false;

    // Function to add item to main widget's list
    void addIssuedItem(Map<String, dynamic> item) {
      print('Adding issued item: $item');
      setState(() {
        issuedInventoryItems.add(item);
      });
      print('Total issued items: ${issuedInventoryItems.length}');

      // Save to local storage
      _saveIssuedItems();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Load items when dialog first opens
          if (dialogItems.isEmpty && !dialogLoadingItems) {
            dialogLoadingItems = true;
            _fetchInventoryItems().then((items) {
              if (context.mounted) {
                setDialogState(() {
                  dialogItems = items;
                  dialogLoadingItems = false;
                });
              }
            }).catchError((e) {
              if (context.mounted) {
                setDialogState(() {
                  dialogLoadingItems = false;
                });
              }
            });
          }

          return AlertDialog(
            title: Row(
              children: [
                // Icon(Icons.add, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                const Text('Issue Inventory Item'),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Item Selection Dropdown
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: dialogLoadingItems
                          ? const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Loading items...'),
                                ],
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<Map<String, dynamic>>(
                                value: selectedItem,
                                hint: dialogItems.isEmpty
                                    ? const Text('No items available')
                                    : const Text('Select an item'),
                                isExpanded: true,
                                items: dialogItems.map((item) {
                                  return DropdownMenuItem<Map<String, dynamic>>(
                                    value: item,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                item['name'] ??
                                                    item['item_name'] ??
                                                    'Unknown Item',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                item['category'] ??
                                                    item['item_category'] ??
                                                    'General',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          'ID: ${item['id'] ?? item['item_id'] ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: dialogItems.isEmpty
                                    ? null
                                    : (Map<String, dynamic>? newValue) {
                                        setDialogState(() {
                                          selectedItem = newValue;
                                        });
                                      },
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Selected Item Info
                    if (selectedItem != null) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: colorScheme.primary.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: colorScheme.primary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Selected: ${selectedItem!['name'] ?? selectedItem!['item_name']} (${selectedItem!['category'] ?? selectedItem!['item_category']})',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                        hintText: 'Enter quantity (e.g., 5)',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                        hintText: 'Enter notes (e.g., For event decoration)',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Validate inputs
                  if (selectedItem == null || quantityController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Please select an item and enter quantity'),
                        backgroundColor: colorScheme.error,
                      ),
                    );
                    return;
                  }

                  // Create the transaction data
                  final transactionData = {
                    "item_id": selectedItem!['id'] ?? selectedItem!['item_id'],
                    "transaction_type": "OUT",
                    "quantity": int.tryParse(quantityController.text) ?? 0,
                    "event_id": widget.event['id'] ?? 0,
                    "notes": notesController.text.isNotEmpty
                        ? notesController.text
                        : "For event decoration"
                  };

                  // Show loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    // Make API call to create issuance
                    final response =
                        await _createInventoryIssuance(transactionData);

                    // Close loading dialog
                    Navigator.pop(context);

                    if (response['success'] == true) {
                      // Add the issued item to the list with API response data
                      final issuedItem = {
                        "id": selectedItem!['id'] ?? selectedItem!['item_id'],
                        "name":
                            selectedItem!['name'] ?? selectedItem!['item_name'],
                        "category": selectedItem!['category'] ??
                            selectedItem!['item_category'],
                        "quantity": int.tryParse(quantityController.text) ?? 0,
                        "notes": notesController.text.isNotEmpty
                            ? notesController.text
                            : "For event decoration",
                        "issued_date": response['data']['issuance']
                            ['issued_at'],
                        "issuance_id": response['data']['issuance']['id'],
                        "stock_info": response['data']['stock_update'],
                      };

                      addIssuedItem(issuedItem);

                      // Close the dialog
                      Navigator.pop(context);

                      // Show success message
                      final stockUpdate = response['data']?['stock_update'];
                      final newQuantity =
                          stockUpdate?['new_quantity'] ?? 'Unknown';

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Inventory item issued successfully!',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('Item: ${selectedItem!['name']}'),
                              Text('Quantity: ${transactionData['quantity']}'),
                              Text('Stock: $newQuantity remaining'),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    } else {
                      // API call failed, but we can still add item locally for demo purposes
                      final issuedItem = {
                        "id": selectedItem!['id'] ?? selectedItem!['item_id'],
                        "name":
                            selectedItem!['name'] ?? selectedItem!['item_name'],
                        "category": selectedItem!['category'] ??
                            selectedItem!['item_category'],
                        "quantity": int.tryParse(quantityController.text) ?? 0,
                        "notes": notesController.text.isNotEmpty
                            ? notesController.text
                            : "For event decoration",
                        "issued_date": DateTime.now().toIso8601String(),
                        "issuance_id": null,
                        "stock_info": null,
                      };

                      addIssuedItem(issuedItem);

                      // Close the dialog
                      Navigator.pop(context);

                      // Show warning message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'API Error - Item added locally',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Text('Item: ${selectedItem!['name']}'),
                              Text('Quantity: ${transactionData['quantity']}'),
                              Text(
                                  'Error: ${response['message'] ?? 'API connection failed'}'),
                            ],
                          ),
                          backgroundColor: Colors.orange,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  } catch (e) {
                    // Close loading dialog
                    Navigator.pop(context);

                    // Add item locally even if API fails
                    final issuedItem = {
                      "id": selectedItem!['id'] ?? selectedItem!['item_id'],
                      "name":
                          selectedItem!['name'] ?? selectedItem!['item_name'],
                      "category": selectedItem!['category'] ??
                          selectedItem!['item_category'],
                      "quantity": int.tryParse(quantityController.text) ?? 0,
                      "notes": notesController.text.isNotEmpty
                          ? notesController.text
                          : "For event decoration",
                      "issued_date": DateTime.now().toIso8601String(),
                      "issuance_id": null,
                      "stock_info": null,
                    };

                    addIssuedItem(issuedItem);

                    // Close the dialog
                    Navigator.pop(context);

                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Item added locally (Network Error)',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('Item: ${selectedItem!['name']}'),
                            Text('Error: ${e.toString()}'),
                          ],
                        ),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: const Text('Issue'),
              ),
            ],
          );
        },
      ),
    );
  }
}
