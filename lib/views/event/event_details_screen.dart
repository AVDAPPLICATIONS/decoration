import 'package:flutter/material.dart';
import 'package:avd_decoration_application/widgets/cached_network_or_file_image.dart' as cnf;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../utils/snackbar_manager.dart';
import '../../services/gallery_service.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/event_repository_provider.dart';
import 'widget/fullscreen_image_viewer.dart';
import 'widget/add_cost_dialog.dart';
import 'widget/pdf_viewer.dart';
import '../../services/cost_service.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> eventData;
  final bool isAdmin;

  const EventDetailsScreen({
    super.key,
    required this.eventData,
    required this.isAdmin,
  });

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _mainTabController;
  late TabController _subTabController;
  late TabController _inventoryTabController;

  int _selectedMainTab = 1; // Design tab is selected by default
  bool _isRefreshing = false;
  Map<String, dynamic> _currentEventData = {};
  int _inventoryRefreshKey =
      0; // Key to force refresh of inventory FutureBuilder

  @override
  void initState() {
    super.initState();
    _mainTabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _subTabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _inventoryTabController =
        TabController(length: 2, vsync: this, initialIndex: 0);
    _currentEventData = widget.eventData;

    print('EventDetailsScreen initState - eventData: $_currentEventData');
    print(
        'template_id: ${_currentEventData['template_id']} (${_currentEventData['template_id'].runtimeType})');
    print(
        'year_id: ${_currentEventData['year_id']} (${_currentEventData['year_id'].runtimeType})');

    // Hide all system UI to create true full-screen experience
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );

    _mainTabController.addListener(() {
      setState(() {
        _selectedMainTab = _mainTabController.index;
      });
    });
  }

  @override
  void dispose() {
    // Restore system UI when leaving the screen
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    _mainTabController.dispose();
    _subTabController.dispose();
    _inventoryTabController.dispose();
    super.dispose();
  }

  void _handleFabAction() {
    if (_subTabController.index == 0 && _mainTabController.index == 1) {
      _addDesignImage(); // when first tab is active
    } else if (_subTabController.index == 1 && _mainTabController.index == 1) {
      _addFinalDecorationImage(); // when second tab is active
    } else if (_mainTabController.index == 2) {
      _showAddCostDialog();
    } else if (_mainTabController.index == 0) {
      // _IssueItemDialogState();
      _showIssueItemDialog();
    }
  }

  Future<void> _refreshEventData() async {
    final colorScheme = Theme.of(context).colorScheme;
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final eventRepository = ref.read(eventRepositoryProvider);

      // Ensure template_id and year_id are integers
      final templateId = _currentEventData['template_id'] is int
          ? _currentEventData['template_id']
          : int.tryParse(_currentEventData['template_id'].toString());
      final yearId = _currentEventData['year_id'] is int
          ? _currentEventData['year_id']
          : int.tryParse(_currentEventData['year_id'].toString());

      print(
          'Refreshing event data - templateId: $templateId (${templateId.runtimeType}), yearId: $yearId (${yearId.runtimeType})');

      if (templateId != null && yearId != null) {
        final eventDetails = await eventRepository.getEventDetails(
          templateId: templateId,
          yearId: yearId,
        );

        if (eventDetails != null && eventDetails['success'] == true && eventDetails['data'] != null) {
          setState(() {
            _currentEventData = {
              'id': eventDetails['data']['event']['id'],
              'name': eventDetails['data']['event']['description'] ?? 'Event',
              'date': eventDetails['data']['event']['date'],
              'location': eventDetails['data']['event']['location'],
              'cover_image': eventDetails['data']['event']['cover_image'],
              'template_id': eventDetails['data']['event']['template_id'],
              'year_id': eventDetails['data']['event']['year_id'],
              'gallery': eventDetails['data']['gallery'],
              'cost': eventDetails['data']['cost'],
              'issuances': eventDetails['data']['issuances'],
            };
          });

          SnackBarManager.showSuccess(
            context: context,
            message: 'Event data refreshed successfully',
          );
        }
      }
    } catch (e) {
      SnackBarManager.showError(
        context: context,
        message: 'Failed to refresh: $e',
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final eventName = _currentEventData['name'] ?? 'Event';
    final eventDate = _currentEventData['date'];
    String eventYear = '2024';

    if (eventDate != null) {
      try {
        final date = DateTime.parse(eventDate);
        eventYear = date.year.toString();
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    final screenTitle = '$eventName  $eventYear';

    return WillPopScope(
      onWillPop: () async {
        // Restore system UI before popping
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
        );
        return true;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _handleFabAction,
          backgroundColor: colorScheme.primary,
          child: Icon(
            Icons.add,
            color: colorScheme.onPrimary,
          ),
        ),
        backgroundColor: colorScheme.background,
        // extendBodyBehindAppBar: true,

        appBar: AppBar(
          automaticallyImplyLeading: false, // ✅ removes back or close icon
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          centerTitle: true,
          title: Text(
            screenTitle,
            softWrap: true,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),



        body: Column(
          children: [
            // Status bar area
            // Container(
            //   height: MediaQuery.of(context).padding.top,
            //   color: colorScheme.primary,
            // ),

            // Header section
            Container(
              color: colorScheme.primary,
              child: Column(

                children: [

                  Container(
                    color: colorScheme.primary,
                    child: TabBar(
                      controller: _mainTabController,
                      indicatorColor: colorScheme.onPrimary,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: colorScheme.onPrimary,
                      unselectedLabelColor:
                          colorScheme.onPrimary.withOpacity(0.6),
                      labelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      tabs: const [
                        Tab(text: 'Inventory'),
                        Tab(text: 'Design'),
                        Tab(text: 'Cost'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: Column(
                children: [
                  // Sub-navigation tabs (only show for Design tab)
                  if (_selectedMainTab == 1)
                    Container(
                      color: colorScheme.surface,
                      child: TabBar(
                        controller: _subTabController,
                        indicatorColor: colorScheme.primary,
                        indicatorWeight: 2,
                        indicatorSize: TabBarIndicatorSize.label,
                        labelColor: colorScheme.onSurface,
                        unselectedLabelColor: colorScheme.onSurfaceVariant,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        tabs: const [
                          Tab(text: 'Design Images'),
                          Tab(text: 'Final Decoration'),
                        ],
                      ),
                    ),

                  // Main content
                  Expanded(
                    child: TabBarView(
                      controller: _mainTabController,
                      children: [
                        _buildInventoryTab(),
                        _buildDesignTab(),
                        _buildCostTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<Map<String, dynamic>>(
      key: ValueKey('inventory_$_inventoryRefreshKey'),
      future: ref.read(inventoryProvider.notifier).getIssuanceHistoryByEventId(
            eventId: _currentEventData['id'],
          ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
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
                  'Error loading inventory data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _inventoryRefreshKey++; // Refresh the future builder
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!['success'] != true) {
          return const Center(
            child: Text(
              'No inventory data available',
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        final data = snapshot.data!['data'];
        final issuancesByItem =
            data['issuances_by_item'] as List<dynamic>? ?? [];
          final issuedItems = issuancesByItem.where((itemGroup) {
          final transactions = itemGroup['transactions'] as List<dynamic>;
          for (var transaction in transactions) {
            print(
                '  Transaction: type=${transaction['transaction_type']}, quantity_issued=${transaction['quantity_issued']}, quantity=${transaction['quantity']}');
          }

          // Calculate net quantity to check for data integrity
          int totalIssued = 0;
          int totalReturned = 0;

          for (var transaction in transactions) {
            // Check for both 'quantity_issued' and 'quantity' fields
            final quantityValue =
                transaction['quantity_issued'] ?? transaction['quantity'];
            final quantity =
                double.tryParse(quantityValue?.toString() ?? '0') ?? 0;
            if (transaction['transaction_type'] == 'OUT') {
              totalIssued += quantity.toInt();
            } else if (transaction['transaction_type'] == 'IN') {
              totalReturned += quantity.toInt();
            }
          }

          final netQuantity = totalIssued - totalReturned;
          print(
              '  Net quantity: $netQuantity (issued: $totalIssued, returned: $totalReturned)');

          // Show items that have OUT transactions and are currently issued (not fully returned)
          final hasOutTransactions = transactions
              .any((transaction) => transaction['transaction_type'] == 'OUT');
          final isCurrentlyIssued =
              netQuantity > 0; // Only show items that are currently issued

          print(
              '  Has OUT transactions: $hasOutTransactions, Is currently issued: $isCurrentlyIssued');

          return hasOutTransactions && isCurrentlyIssued;
        }).toList();

        print(
            '🔍 Debug: Found ${issuedItems.length} issued items out of ${issuancesByItem.length} total items');

        // If no items found in issuances_by_item, try to get issued items from history
        List<dynamic> itemsToShow = issuedItems;
        if (itemsToShow.isEmpty) {
          final issuanceHistory =
              data['issuance_history'] as List<dynamic>? ?? [];
          // Filter history for items that are currently issued (not returned)
          final currentlyIssuedFromHistory =
              issuanceHistory.where((transaction) {
            final transactionType = transaction['transaction_type'] ?? '';
            return transactionType ==
                'OUT'; // Only show OUT transactions (issued items)
          }).toList();

          print(
              '🔍 Debug: No items in issuances_by_item, checking history for issued items');
          print(
              '🔍 Debug: Found ${currentlyIssuedFromHistory.length} issued items in history');

          // Convert history items to the expected format for display
          itemsToShow = currentlyIssuedFromHistory.map((transaction) {
            return {
              'item_info': {
                'id': transaction['item_id'],
                'name': transaction['item_name'] ?? 'Unknown Item',
                'category': transaction['category'] ?? '',
                'unit': transaction['unit'] ?? '',
              },
              'transactions': [transaction],
            };
          }).toList();
        }

        print('🔍 Debug: Showing ${itemsToShow.length} currently issued items');

        if (itemsToShow.isEmpty) {
          // Check if there's any history to show
          final issuanceHistory =
              data['issuance_history'] as List<dynamic>? ?? [];
          final hasHistory = issuanceHistory.isNotEmpty;

          // Debug: Print issuance history
          print('🔍 Debug: issuance_history length: ${issuanceHistory.length}');
          print('🔍 Debug: issuance_history: $issuanceHistory');

          return Column(
            children: [
              // Header with issue button
              _buildIssuedItemsHeader(0),

              // Show history if available, otherwise show empty state
              Expanded(
                child: hasHistory
                    ? _buildEmptyStateWithHistory(issuanceHistory, colorScheme)
                    : _buildEmptyStateWithNoHistory(colorScheme),
              ),
            ],
          );
        }

        return Column(
          children: [
            // Header with issued items count
            _buildIssuedItemsHeader(itemsToShow.length),

            // Inventory sub-tabs
            Container(
              color: colorScheme.surface,
              // color: colorScheme.secondaryContainer,
              child: TabBar(
                controller: _inventoryTabController,
                indicatorColor: colorScheme.primary,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: colorScheme.onSurface,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                tabs: const [
                  Tab(text: 'Current'),
                  Tab(text: 'History'),
                ],
              ),
            ),

            // Sub-tab content
            Expanded(
              child: TabBarView(
                controller: _inventoryTabController,
                children: [
                  // Summary tab - show issued items
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: itemsToShow.length,
                    itemBuilder: (context, index) {
                      return _buildIssuedItemCard(itemsToShow[index]);
                    },
                  ),
                  // History tab - show detailed history
                  _buildDetailedHistory(
                      data['issuance_history'] as List<dynamic>? ?? []),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDesignTab() {
    return Column(
      children: [
        // Sub-tab content
        Expanded(
          child: TabBarView(
            controller: _subTabController,
            children: [
              _buildDesignImagesTab(),
              _buildFinalDecorationTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<dynamic>>(
      future: _fetchEventCosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading cost data',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.red[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _inventoryRefreshKey++; // Refresh the future builder
                    });
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final costs = snapshot.data ?? [];
        final totalCost = costs.fold(0.0, (sum, cost) {
          if (cost is Map<String, dynamic>) {
            final amount =
                double.tryParse(cost['amount']?.toString() ?? '0') ?? 0.0;
            return sum + amount;
          }
          return sum;
        });

        return Container(
          color: colorScheme.surfaceContainer,
          child: Column(
            children: [
              const SizedBox(width: 26),

              // Total Cost Card
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Left Icon
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.calculate,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Texts
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Cost',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rs${totalCost.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Right Icon - PDF Export
                    GestureDetector(
                      onTap: () => _exportCostsToPDF(costs),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Tooltip(
                          message: 'Export costs to PDF',
                          child: Icon(
                            Icons.receipt_long,
                            color: Colors.white.withOpacity(0.9),
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Content Area
              Expanded(
                child:
                    costs.isEmpty ? _buildEmptyState() : _buildCostsList(costs),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDesignImagesTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final galleryData = _currentEventData['gallery'];
    final designImages =
        galleryData != null && galleryData is Map<String, dynamic>
            ? (galleryData['design'] as List<dynamic>? ?? [])
            : [];
    print('Design Images ${designImages.toList()}');

    return RefreshIndicator(
      onRefresh: _refreshEventData,
      child: Stack(
        children: [
          // Content area
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Design image cards
                Expanded(
                  child: designImages != null && designImages.isNotEmpty
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: designImages.length,
                          itemBuilder: (context, index) {
                            return _buildDesignImageCard(
                                designImages[index], index, tabType: 'design');
                          },
                        )
                      : SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Container(
                            height: 400,
                            child: Center(
                              child: Text(
                                'No design images available\nPull down to refresh',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),

          // Bottom add button
        ],
      ),
    );
  }

  Widget _buildFinalDecorationTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final galleryData = _currentEventData['gallery'];
    final finalImages =
        galleryData != null && galleryData is Map<String, dynamic>
            ? (galleryData['final'] as List<dynamic>? ?? [])
            : [];

    return Stack(
      children: [
        // Content area
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Final decoration image cards
              Expanded(
                child: finalImages != null && finalImages.isNotEmpty
                    ? GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: finalImages.length,
                        itemBuilder: (context, index) {
                          return _buildDesignImageCard(
                              finalImages[index], index, tabType: 'final');
                        },
                      )
                    : Center(
                        child: Text(
                          'No final decoration images available',
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesignImageCard(dynamic imageData, int index, {String tabType = 'design'}) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _showFullScreenImage(imageData),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Image thumbnail
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: _buildImageWidget(imageData),
                  ),
                ),
              ),
            ),

            // Bottom section with label and delete button
            Expanded(
              flex: 1,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (imageData['notes'] ??
                                imageData['description'] ??
                                'Design Image')
                            .toString(),
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Delete button
                    GestureDetector(
                      onTap: () => _showDeleteConfirmation(imageData, tabType),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(dynamic imageData, String tabType) {
    final imageType = tabType == 'design' ? 'design image' : 'final decoration image';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: Text('Are you sure you want to delete this $imageType?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteImage(imageData, tabType);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteImage(dynamic imageData, String tabType) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final galleryService = GalleryService(
        apiBaseUrl,
        null,
      );

      Map<String, dynamic> result;
      if (tabType == 'design') {
        result = await galleryService.deleteDesignImage(
          imageId: imageData['id'].toString(),
          eventId: _currentEventData['id'].toString(),
        );
      } else {
        result = await galleryService.deleteFinalDecorationImage(
          imageId: imageData['id'].toString(),
          eventId: _currentEventData['id'].toString(),
        );
      }

      // Close loading indicator
      Navigator.of(context, rootNavigator: true).pop();

      if (result['success'] == true) {
        // Refresh the event data to update the UI
        await _refreshEventData();
        
        SnackBarManager.showSuccessCustom(
          context: context,
          message: 'Image deleted successfully',
        );
      } else {
        SnackBarManager.showErrorCustom(
          context: context,
          message: result['message'] ?? 'Failed to delete image',
        );
      }
    } catch (e) {
      // Close loading indicator if still open
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      SnackBarManager.showErrorCustom(
        context: context,
        message: 'Error deleting image: $e',
      );
    }
  }

  void _showFullScreenImage(dynamic imageData) {
    String? fileUrl;
    String? fileTitle;
    String? fileType;

    if (imageData != null && imageData is Map<String, dynamic>) {
      // Try different possible file URL fields
      fileUrl = imageData['image_url'] ??
          imageData['image_path'] ??
          imageData['url'] ??
          imageData['file_path'] ??
          imageData['filename'] ??
          imageData['document_url'];

      // Get file title/description
      fileTitle =
          imageData['notes'] ?? imageData['description'] ?? imageData['title'];

      // Get file type
      fileType = imageData['document_type'] ?? imageData['file_type'];

      // Determine file type from URL if not provided
      if (fileType == null && fileUrl != null) {
        final lowerUrl = fileUrl.toLowerCase();
        if (lowerUrl.endsWith('.pdf')) {
          fileType = 'pdf';
        } else if (lowerUrl.endsWith('.jpg') ||
            lowerUrl.endsWith('.jpeg') ||
            lowerUrl.endsWith('.png') ||
            lowerUrl.endsWith('.gif') ||
            lowerUrl.endsWith('.bmp') ||
            lowerUrl.endsWith('.webp')) {
          fileType = 'image';
        }
      }
    }

    if (fileUrl != null && fileUrl.isNotEmpty) {
      // Convert relative URL to full URL if needed
      if (fileUrl.startsWith('/')) {
        fileUrl = '$apiBaseUrl$fileUrl';
      }

      if (fileType == 'pdf') {
        // For PDF, open in PDF viewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewer(
              pdfUrl: fileUrl!,
              title: fileTitle ?? 'PDF Document',
            ),
          ),
        );
      } else {
        // For images, show in full screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImageViewer(
              imageUrl: fileUrl!,
              title: fileTitle ?? 'Design Image',
            ),
          ),
        );
      }
    } else {
      SnackBarManager.showError(
        context: context,
        message: 'File URL not available',
      );
    }
  }

  void _addDesignImage() {
    _showImageUploadDialog();
  }

  void _showImageUploadDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _ImageUploadDialog(
          eventId: _currentEventData['id'],
          onImagesUploaded: () {
            // Refresh the event data to show new images
            _refreshEventData();
          },
        );
      },
    );
  }

  void _addFinalDecorationImage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _FinalDecorationImageUploadDialog(
          eventId: _currentEventData['id'],
          onImagesUploaded: () {
            // Refresh the event data to show new images
            _refreshEventData();
          },
        );
      },
    );
  }

  Widget _buildImageWidget(dynamic imageData) {
    String? fileUrl;
    String? fileType;

    if (imageData != null && imageData is Map<String, dynamic>) {
      // Try different possible file URL fields
      fileUrl = imageData['image_url'] ??
          imageData['image_path'] ??
          imageData['url'] ??
          imageData['file_path'] ??
          imageData['filename'] ??
          imageData['document_url'];

      // Get file type
      fileType = imageData['document_type'] ?? imageData['file_type'];

      // Determine file type from URL if not provided
      if (fileType == null && fileUrl != null) {
        final lowerUrl = fileUrl.toLowerCase();
        if (lowerUrl.endsWith('.pdf')) {
          fileType = 'pdf';
        } else if (lowerUrl.endsWith('.jpg') ||
            lowerUrl.endsWith('.jpeg') ||
            lowerUrl.endsWith('.png') ||
            lowerUrl.endsWith('.gif') ||
            lowerUrl.endsWith('.bmp') ||
            lowerUrl.endsWith('.webp')) {
          fileType = 'image';
        }
      }
    }

    if (fileUrl != null && fileUrl.isNotEmpty) {
      // Convert relative URL to full URL if needed
      if (fileUrl.startsWith('/')) {
        fileUrl = '$apiBaseUrl$fileUrl';
      }

      if (fileType == 'pdf') {
        // Show PDF icon and indicator
        return Container(
          color: Colors.red[50],
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'PDF',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // File type indicator in top-right corner
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'PDF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        // Show image with type indicator
        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              child: cnf.CachedNetworkOrFileImage(
                imageUrl: fileUrl,
                fit: BoxFit.cover,
                placeholder: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            // File type indicator in top-right corner
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'IMG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      }
    }

    // Fallback placeholder
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.image,
        size: 50,
        color: Colors.grey,
      ),
    );
  }

  // Helper methods for inventory tab
  Widget _buildIssuedItemsHeader(int itemCount) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2,
            color: colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Currently Issued Items ($itemCount)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIssuedItemCard(Map<String, dynamic> itemGroup) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemInfo = itemGroup['item_info'] as Map<String, dynamic>;
    final allTransactions = itemGroup['transactions'] as List<dynamic>;

    // Calculate total issued and returned quantities
    int totalIssuedQuantity = 0;
    int totalReturnedQuantity = 0;
    String latestNotes = '';
    int? latestIssuanceId;
    int? itemId;

    // Get item ID from item info
    itemId = itemInfo['id'];

    for (var transaction in allTransactions) {
      // Check for both 'quantity_issued' and 'quantity' fields
      final quantityValue =
          transaction['quantity_issued'] ?? transaction['quantity'];
      final quantity = double.tryParse(quantityValue?.toString() ?? '0') ?? 0;

      if (transaction['transaction_type'] == 'OUT') {
        totalIssuedQuantity += quantity.toInt();
        // Get the latest issuance ID for returning (keep the most recent one)
        if (latestIssuanceId == null ||
            (transaction['id'] != null &&
                transaction['id'] > latestIssuanceId)) {
          latestIssuanceId = transaction['id'];
        }
      } else if (transaction['transaction_type'] == 'IN') {
        totalReturnedQuantity += quantity.toInt();
      }

      // Get the latest notes
      if (transaction['notes'] != null &&
          transaction['notes'].toString().isNotEmpty) {
        latestNotes = transaction['notes'].toString();
      }
    }

    // Calculate net issued quantity (issued - returned)
    final netIssuedQuantity = totalIssuedQuantity - totalReturnedQuantity;

    // Debug logging
    print('🔍 Debug Item Card: ${itemInfo['name']}');
    print('  Total Issued: $totalIssuedQuantity');
    print('  Total Returned: $totalReturnedQuantity');
    print('  Net Issued: $netIssuedQuantity');

    // Determine status based on net quantity
    final isFullyReturned = netIssuedQuantity <= 0;
    final isPartiallyReturned =
        totalReturnedQuantity > 0 && netIssuedQuantity > 0;

    // Ensure we don't show negative quantities
    final displayQuantity = netIssuedQuantity < 0 ? 0 : netIssuedQuantity;

    return Dismissible(
      key: Key('item_${itemInfo['id']}_${latestIssuanceId}'),
      direction: isFullyReturned
          ? DismissDirection.none
          : DismissDirection
              .horizontal, // Only allow swipe if items can be returned
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        decoration: BoxDecoration(
          color: isFullyReturned ? Colors.grey : Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              isFullyReturned ? Icons.check_circle : Icons.undo,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text(
              isFullyReturned ? 'Fully Returned' : 'Return',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: isFullyReturned ? Colors.grey : Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              isFullyReturned ? 'Fully Returned' : 'Return',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isFullyReturned ? Icons.check_circle : Icons.undo,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Only allow return if there are items available to return
        if (isFullyReturned) {
          return false; // Don't allow dismissal if fully returned
        }

        // Show return dialog instead of dismissing regardless of swipe direction
        if (itemId != null) {
          _showReturnItemDialog(
            issuanceId:
                latestIssuanceId, // Can be null, will be handled in dialog
            itemId: itemId,
            itemName: itemInfo['name'] ?? 'Unknown Item',
            maxQuantity:
                displayQuantity, // Use display quantity (never negative)
          );
        } else {
          // Debug information
          print(
              'Debug: latestIssuanceId = $latestIssuanceId, itemId = $itemId');
          print('Debug: itemInfo = $itemInfo');
          print('Debug: allTransactions = $allTransactions');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Unable to return: missing item info. ItemId: $itemId'),
            ),
          );
        }
        return false; // Do not dismiss the tile
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main item content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Item icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: itemInfo['item_image'] != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: cnf.CachedNetworkOrFileImage(
                              imageUrl: '${apiBaseUrl}${itemInfo['item_image']}',
                              fit: BoxFit.cover,
                              errorWidget: Icon(
                                Icons.inventory_2,
                                color: Colors.grey[400],
                                size: 24,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.inventory_2,
                            color: Colors.grey[400],
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 16),

                  // Item details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Item name
                        Text(
                          itemInfo['name'] ?? 'Unknown Item',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Category tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            itemInfo['category_name'] ?? 'General',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quantity and status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Qty: $displayQuantity',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isFullyReturned ? Colors.grey : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFullyReturned
                              ? Colors.grey
                              : isPartiallyReturned
                                  ? Colors.orange
                                  : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isFullyReturned
                              ? 'RETURNED'
                              : isPartiallyReturned
                                  ? 'PARTIAL'
                                  : 'ISSUED',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status and notes section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status summary
                  Row(
                    children: [
                      Icon(
                        isFullyReturned
                            ? Icons.check_circle
                            : isPartiallyReturned
                                ? Icons.warning
                                : Icons.inventory_2,
                        size: 16,
                        color: isFullyReturned
                            ? Colors.grey
                            : isPartiallyReturned
                                ? Colors.orange
                                : Colors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isFullyReturned
                            ? 'All items returned ($totalReturnedQuantity/$totalIssuedQuantity)'
                            : isPartiallyReturned
                                ? 'Partially returned ($totalReturnedQuantity/$totalIssuedQuantity)'
                                : 'Fully issued ($totalIssuedQuantity)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isFullyReturned
                              ? Colors.grey
                              : isPartiallyReturned
                                  ? Colors.orange
                                  : Colors.green,
                        ),
                      ),
                    ],
                  ),

                  // Notes (if available)
                  if (latestNotes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Notes: $latestNotes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsByCategory(List<dynamic> issuancesByItem) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items Used',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...issuancesByItem
            .map((itemGroup) => _buildItemGroupCard(itemGroup))
            .toList(),
      ],
    );
  }

  Widget _buildItemGroupCard(Map<String, dynamic> itemGroup) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemInfo = itemGroup['item_info'] as Map<String, dynamic>;
    final allTransactions = itemGroup['transactions'] as List<dynamic>;
    // Filter to show only OUT transactions
    final transactions = allTransactions
        .where((transaction) => transaction['transaction_type'] == 'OUT')
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Item image
                if (itemInfo['item_image'] != null)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: cnf.CachedNetworkOrFileImage(
                        imageUrl: '${apiBaseUrl}${itemInfo['item_image']}',
                        fit: BoxFit.cover,
                        errorWidget: Icon(
                          Icons.inventory_2,
                          color: Colors.grey[400],
                          size: 24,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: Colors.grey[400],
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemInfo['name'] ?? 'Unknown Item',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${itemInfo['category_name'] ?? 'Unknown'} • ${itemInfo['unit'] ?? 'piece'}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Transactions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transactions (${transactions.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...transactions
                    .map((transaction) => _buildTransactionItem(transaction))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    // Since we're filtering to show only OUT transactions, this will always be true
    // Check for both 'quantity_issued' and 'quantity' fields
    final quantityValue =
        transaction['quantity_issued'] ?? transaction['quantity'];
    final quantity = double.tryParse(quantityValue?.toString() ?? '0') ?? 0;
    final date = DateTime.tryParse(transaction['issued_at']?.toString() ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.arrow_upward,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Issued: ${quantity.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange[700],
                  ),
                ),
                if (transaction['notes'] != null &&
                    transaction['notes'].toString().isNotEmpty)
                  Text(
                    transaction['notes'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                if (date != null)
                  Text(
                    '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWithHistory(
      List<dynamic> issuanceHistory, ColorScheme colorScheme) {
    return Column(
      children: [
        // Info message
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
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
                  'No items currently issued. Showing previous inventory history:',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        // History list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: issuanceHistory.length,
            itemBuilder: (context, index) {
              return _buildHistoryCard(issuanceHistory[index]);
            },
          ),
        ),

        // Issue button at bottom
        Container(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showIssueItemDialog(),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Issue New Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyStateWithNoHistory(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No items currently issued for this event',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No previous inventory history found',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showIssueItemDialog(),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Issue First Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedHistory(List<dynamic> issuanceHistory) {
    if (issuanceHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No history available',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: issuanceHistory.length,
      itemBuilder: (context, index) {
        return _buildHistoryCard(issuanceHistory[index]);
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> transaction) {
    // Check for both 'quantity_issued' and 'quantity' fields
    final quantityValue =
        transaction['quantity_issued'] ?? transaction['quantity'];
    final quantity = double.tryParse(quantityValue?.toString() ?? '0') ?? 0;
    final date = DateTime.tryParse(transaction['issued_at']?.toString() ?? '');
    final transactionType = transaction['transaction_type'] ?? 'OUT';
    final isReturn = transactionType == 'IN';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReturn
              ? Colors.green.withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isReturn
                  ? Colors.green.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              isReturn ? Icons.arrow_downward : Icons.arrow_upward,
              color: isReturn ? Colors.green : Colors.orange,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['item_name'] ?? 'Unknown Item',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${transaction['category_name'] ?? 'Unknown'} • ${transaction['unit'] ?? 'piece'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isReturn ? Colors.green : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isReturn ? 'RETURNED' : 'ISSUED',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${isReturn ? 'Returned' : 'Issued'}: ${quantity.toStringAsFixed(0)} ${transaction['unit'] ?? ''}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isReturn ? Colors.green[700] : Colors.orange[700],
                  ),
                ),
                if (transaction['notes'] != null &&
                    transaction['notes'].toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction['notes'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (date != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Navigate to issue item screen
  void _showIssueItemDialog() {
    Navigator.pushNamed(
      context,
      '/issue-item',
      arguments: {
        'eventId': _currentEventData['id'],
        'onItemIssued': () {
          // Refresh the inventory tab by incrementing the refresh key
          setState(() {
            _inventoryRefreshKey++;
          });
        },
        'onNavigateToMaterialTab': () {
          // Switch to material tab (index 0)
          _mainTabController.animateTo(0);
        },
      },
    );
  }

  // Show return item dialog
  void _showReturnItemDialog({
    required int? issuanceId,
    required int itemId,
    required String itemName,
    required int maxQuantity,
  }) {
    showDialog(
      context: context,
      builder: (context) => _ReturnItemDialog(
        issuanceId: issuanceId,
        itemId: itemId,
        itemName: itemName,
        maxQuantity: maxQuantity,
        eventId: _currentEventData['id'],
        onItemReturned: () {
          // Refresh the inventory tab by incrementing the refresh key
          setState(() {
            _inventoryRefreshKey++;
          });
        },
      ),
    );
  }

  // Cost tab helper methods
  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.receipt_long,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No costs added yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start adding costs to track your expenses',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Add Cost Button
            Container(
              width: 200,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showAddCostDialog(),
                  borderRadius: BorderRadius.circular(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.add,
                          color: colorScheme.primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Add Cost',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostsList(List<dynamic> costs) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: costs.length,
      itemBuilder: (context, index) {
        final cost = costs[index];
        return _buildCostCard(cost, index);
      },
    );
  }

  Widget _buildCostCard(dynamic cost, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    Map<String, dynamic> costMap;
    if (cost is Map<String, dynamic>) {
      costMap = cost;
    } else {
      costMap = {
        'id': index,
        'amount': 0.0,
        'description': 'Cost Item',
        'uploaded_at': DateTime.now().toIso8601String(),
      };
    }

    final amount = double.tryParse(costMap['amount']?.toString() ?? '0') ?? 0.0;
    final description = costMap['description'] ?? 'Cost Item';
    final date = costMap['uploaded_at'] ?? DateTime.now().toIso8601String();
    final documentUrl = costMap['document_url'];
    final documentType = costMap['document_type'];

    return Dismissible(
      key: Key('cost_${costMap['id'] ?? index}'),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit,
              color: colorScheme.onPrimary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              'Edit',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delete,
              color: colorScheme.onPrimary,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              'Delete',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Swiped from left → right (Edit)
          _editCost(costMap);
          return false; // Don't actually dismiss, just trigger edit
        } else if (direction == DismissDirection.endToStart) {
          // Swiped from right → left (Delete)
          final confirm = await _showDeleteCostDialog(costMap['id']);
          return confirm ?? false; // Dismiss only if confirmed
        }
        return false;
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.attach_money,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(date),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (documentUrl != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          documentType == 'pdf'
                              ? Icons.picture_as_pdf
                              : Icons.image,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Receipt attached',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Text(
              'Rs${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Unknown date';
    }
  }

  void _showAddCostDialog() {
    showDialog(
      context: context,
      builder: (context) => AddCostDialog(
        eventId: _currentEventData['id'],
        onCostAdded: () {
          // Refresh the event data to show new cost
          _refreshEventData();
        },
      ),
    );
  }

  Future<bool?> _showDeleteCostDialog(int costId) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Cost'),
        content: const Text('Are you sure you want to delete this cost entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context, true);
              await _deleteCost(costId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _viewCostDocument(String documentUrl, String documentType) {
    // Convert relative URL to full URL if needed
    String fullUrl = documentUrl;
    if (documentUrl.startsWith('/')) {
      fullUrl = '$apiBaseUrl$documentUrl';
    }

    if (documentType == 'pdf') {
      // For PDF, you might want to open in a web view or external app
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening PDF: $fullUrl'),
          backgroundColor: Colors.blue,
        ),
      );
      // TODO: Implement PDF viewer
    } else {
      // For images, show in full screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageViewer(
            imageUrl: fullUrl,
            title: 'Cost Receipt',
          ),
        ),
      );
    }
  }

  void _editCost(Map<String, dynamic> costData) {
    showDialog(
      context: context,
      builder: (context) => AddCostDialog(
        eventId: _currentEventData['id'],
        existingCost: costData,
        onCostAdded: () {
          // Refresh the cost list
          setState(() {});
        },
      ),
    );
  }

  Future<void> _deleteCost(int costId) async {
    try {
      final costService = CostService(apiBaseUrl);
      final result = await costService.deleteEventCostItem(costId);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Cost deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close the dialog
        setState(() {}); // Refresh the cost list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to delete cost'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting cost: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatAmount(dynamic amount) {
    if (amount == null) return '0.00';
    if (amount is String) {
      final parsed = double.tryParse(amount);
      return parsed?.toStringAsFixed(2) ?? '0.00';
    } else if (amount is num) {
      return amount.toStringAsFixed(2);
    }
    return '0.00';
  }

  Future<void> _exportCostsToPDF(List<dynamic> costs) async {
    try {
      if (costs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No costs to export'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Calculate total cost
      double totalCost = 0;
      for (var cost in costs) {
        final amount = cost['amount'];
        if (amount != null) {
          if (amount is String) {
            totalCost += double.tryParse(amount) ?? 0;
          } else if (amount is num) {
            totalCost += amount.toDouble();
          }
        }
      }

      // Create PDF document
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(20),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue800,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'Event Cost Report',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        widget.eventData['name'] ?? 'Event',
                        style: pw.TextStyle(
                          fontSize: 18,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Generated on: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.white,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Summary
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total Cost Items:',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.Text(
                        '${costs.length}',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 20),

                // Cost items table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration:
                          const pw.BoxDecoration(color: PdfColors.grey200),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Description',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Amount (Rs)',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text('Date',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        ),
                      ],
                    ),
                    // Data rows
                    ...costs
                        .map((cost) => pw.TableRow(
                              children: [
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(cost['description'] ?? ''),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                      'Rs${_formatAmount(cost['amount'])}'),
                                ),
                                pw.Padding(
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(cost['uploaded_at'] != null
                                      ? DateFormat('dd MMM yyyy').format(
                                          DateTime.parse(cost['uploaded_at']))
                                      : 'N/A'),
                                ),
                              ],
                            ))
                        .toList(),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Total
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue50,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.blue300),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Total Amount:',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                      pw.Text(
                        'Rs${totalCost.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Show PDF preview and allow printing/sharing
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name:
            'Event_Cost_Report_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<dynamic>> _fetchEventCosts() async {
    try {
      final costService = CostService(apiBaseUrl);
      final result = await costService.getEventCosts(_currentEventData['id']);

      if (result['success'] == true) {
        // Parse the JSON response
        final responseData = jsonDecode(result['data']);
        print('Cost API Response: $responseData');

        if (responseData['success'] == true && responseData['data'] != null) {
          final costItems =
              responseData['data']['cost_items'] as List<dynamic>? ?? [];
          return costItems;
        } else {
          return [];
        }
      } else {
        throw Exception(result['message'] ?? 'Failed to fetch costs');
      }
    } catch (e) {
      print('Error fetching costs: $e');
      throw e;
    }
  }
}

class _ReturnItemDialog extends ConsumerStatefulWidget {
  final int? issuanceId;
  final int itemId;
  final String itemName;
  final int maxQuantity;
  final int eventId;
  final VoidCallback onItemReturned;

  const _ReturnItemDialog({
    required this.issuanceId,
    required this.itemId,
    required this.itemName,
    required this.maxQuantity,
    required this.eventId,
    required this.onItemReturned,
  });

  @override
  ConsumerState<_ReturnItemDialog> createState() => _ReturnItemDialogState();
}

class _ReturnItemDialogState extends ConsumerState<_ReturnItemDialog> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Set max quantity as default
    _quantityController.text = widget.maxQuantity.toString();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitReturn() async {
    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid quantity')),
      );
      return;
    }

    if (quantity > widget.maxQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Quantity cannot exceed ${widget.maxQuantity}')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      Map<String, dynamic> response;

      // Try to update existing issuance if we have the issuance ID
      if (widget.issuanceId != null) {
        try {
          response =
              await ref.read(inventoryProvider.notifier).updateMaterialIssuance(
                    issuanceId: widget.issuanceId!,
                    itemId: widget.itemId,
                    transactionType: 'IN',
                    quantity: quantity,
                    eventId: widget.eventId,
                    notes: _notesController.text.trim().isEmpty
                        ? 'Returned to inventory'
                        : _notesController.text.trim(),
                  );
        } catch (e) {
          // If update fails, fall back to creating a new issuance
          print('Update issuance failed, falling back to create: $e');
          response =
              await ref.read(inventoryProvider.notifier).createMaterialIssuance(
                    itemId: widget.itemId,
                    transactionType: 'IN',
                    quantity: quantity,
                    eventId: widget.eventId,
                    notes: _notesController.text.trim().isEmpty
                        ? 'Returned to inventory'
                        : _notesController.text.trim(),
                  );
        }
      } else {
        // Create a new 'IN' issuance entry to record the return
        response =
            await ref.read(inventoryProvider.notifier).createMaterialIssuance(
                  itemId: widget.itemId,
                  transactionType: 'IN',
                  quantity: quantity,
                  eventId: widget.eventId,
                  notes: _notesController.text.trim().isEmpty
                      ? 'Returned to inventory'
                      : _notesController.text.trim(),
                );
      }

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(response['message'] ?? 'Item returned successfully')),
        );
        Navigator.of(context).pop();
        widget.onItemReturned();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(response['message'] ?? 'Failed to return item')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Return Item',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Item: ${widget.itemName}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Max quantity to return: ${widget.maxQuantity}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quantity input
                    const Text(
                      'Return Quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'Enter quantity to return',
                        suffixText: 'max: ${widget.maxQuantity}',
                      ),
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 20),

                    // Notes input
                    const Text(
                      'Notes (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter notes for this return',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReturn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Return Item'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class _ImageUploadDialog extends StatefulWidget {
  final int eventId;
  final VoidCallback onImagesUploaded;

  const _ImageUploadDialog({
    required this.eventId,
    required this.onImagesUploaded,
  });

  @override
  State<_ImageUploadDialog> createState() => _ImageUploadDialogState();
}

class _ImageUploadDialogState extends State<_ImageUploadDialog> {
  final TextEditingController _notesController = TextEditingController();
  List<File> _selectedImages = [];
  bool _isUploading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upload Design',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notes field
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Enter description for the images',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),

            // Selected files section
            if (_selectedImages.isNotEmpty) ...[
              const Text(
                'Selected Files:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    final file = _selectedImages[index];
                    final isPdf = file.path.toLowerCase().endsWith('.pdf');
                    final fileName = file.path.split('/').last;

                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey),
                              color: isPdf ? Colors.red[50] : Colors.grey[50],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: isPdf
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.picture_as_pdf,
                                          color: Colors.red,
                                          size: 32,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'PDF',
                                          style: TextStyle(
                                            color: Colors.red[700],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Image.file(
                                      file,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          // File name overlay
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.7),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                fileName.length > 12
                                    ? '${fileName.substring(0, 12)}...'
                                    : fileName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          // Remove button
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImages.removeAt(index);
                                });
                              },
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Select files button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selectImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(_selectedImages.isEmpty
                    ? 'Select Images/PDFs'
                    : 'Add More Files'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[500], size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Supported: Images (JPG, PNG) and PDFs',
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedImages.isEmpty || _isUploading
                    ? null
                    : _uploadImages,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _isUploading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Uploading...'),
                        ],
                      )
                    : const Text('Upload Files'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedImages.addAll(
            result.files.map((file) => File(file.path!)).toList(),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting files: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final galleryService = GalleryService(apiBaseUrl, null);

      final result = await galleryService.uploadDesignImages(
        eventId: widget.eventId.toString(),
        imageFiles: _selectedImages,
        notes: _notesController.text.trim(),
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Images uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
        widget.onImagesUploaded();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Upload failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}

class _FinalDecorationImageUploadDialog extends StatefulWidget {
  final int eventId;
  final VoidCallback onImagesUploaded;

  const _FinalDecorationImageUploadDialog({
    required this.eventId,
    required this.onImagesUploaded,
  });

  @override
  State<_FinalDecorationImageUploadDialog> createState() =>
      _FinalDecorationImageUploadDialogState();
}

class _FinalDecorationImageUploadDialogState
    extends State<_FinalDecorationImageUploadDialog> {
  final TextEditingController _notesController = TextEditingController();
  List<File> _selectedImages = [];
  bool _isUploading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header (fixed)
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Final Decoration',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notes field
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText:
                            'Enter description for the final decoration images',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),

                    // Selected files section
                    if (_selectedImages.isNotEmpty) ...[
                      const Text(
                        'Selected Files:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            final file = _selectedImages[index];
                            final isPdf =
                                file.path.toLowerCase().endsWith('.pdf');
                            final fileName = file.path.split('/').last;

                            return Container(
                              width: 100,
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey),
                                      color: isPdf
                                          ? Colors.red[50]
                                          : Colors.grey[50],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: isPdf
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.picture_as_pdf,
                                                  color: Colors.red,
                                                  size: 32,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'PDF',
                                                  style: TextStyle(
                                                    color: Colors.red[700],
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Image.file(
                                              file,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  // File name overlay
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.7),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                      ),
                                      child: Text(
                                        fileName.length > 12
                                            ? '${fileName.substring(0, 12)}...'
                                            : fileName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  // Remove button
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImages.removeAt(index);
                                        });
                                      },
                                      child: Container(
                                        width: 20,
                                        height: 20,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Select files button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _selectImages,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: Text(_selectedImages.isEmpty
                            ? 'Select Images/PDFs'
                            : 'Add More Files'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.grey[500], size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Supported: Images (JPG, PNG) and PDFs',
                            softWrap: true,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Fixed bottom buttons
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  // Upload button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedImages.isEmpty || _isUploading
                          ? null
                          : _uploadImages,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: _isUploading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Uploading...'),
                              ],
                            )
                          : Text(
                              'Upload ${_selectedImages.length} File${_selectedImages.length != 1 ? 's' : ''}'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImages() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _selectedImages.addAll(
            result.files.map((file) => File(file.path!)).toList(),
          );
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting files: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() {
      _isUploading = true;
    });

    try {
      final galleryService = GalleryService(
        apiBaseUrl, // Replace with your API base URL
        null, // LocalStorageService not needed for this operation
      );

      final result = await galleryService.uploadFinalDecorationImages(
        eventId: widget.eventId.toString(),
        imageFiles: _selectedImages,
        notes: _notesController.text.trim(),
      );

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Final decoration images uploaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
        widget.onImagesUploaded();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Upload failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }
}
