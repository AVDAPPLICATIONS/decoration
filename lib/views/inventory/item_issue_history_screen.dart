import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/inventory_provider.dart';
import '../custom_widget/custom_appbar.dart';

class ItemIssueHistoryPage extends ConsumerStatefulWidget {
  final String itemId;
  final String itemName;
  const ItemIssueHistoryPage(
      {super.key, required this.itemId, required this.itemName});

  @override
  ConsumerState<ItemIssueHistoryPage> createState() =>
      _ItemIssueHistoryPageState();
}

class _ItemIssueHistoryPageState extends ConsumerState<ItemIssueHistoryPage> {
  Map<String, dynamic>? historyData;
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response =
          await ref.read(inventoryProvider.notifier).getIssuanceHistoryByItemId(
                itemId: int.parse(widget.itemId),
              );

      setState(() {
        historyData = response;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(
        title: 'Issue History: ${widget.itemName}',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 80, color: colorScheme.error),
            const SizedBox(height: 12),
            Text('Error loading history',
                style: TextStyle(color: colorScheme.error)),
            const SizedBox(height: 8),
            Text(error!,
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant, fontSize: 12)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (historyData == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 80, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text('No history data available',
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    final issuanceHistory =
        historyData!['data']['issuance_history'] as List<dynamic>;
    final itemInfo = historyData!['data']['item_info'] as Map<String, dynamic>;
    final summary = historyData!['data']['summary'] as Map<String, dynamic>;

    if (issuanceHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 80, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text('No issues for this item yet',
                style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Info Card
          _buildItemInfoCard(itemInfo),
          const SizedBox(height: 16),

          // Summary Card
          _buildSummaryCard(summary),
          const SizedBox(height: 16),

          // History List
          Text(
            'Issuance History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),

          ...issuanceHistory.map((issue) => _buildHistoryCard(issue)).toList(),
        ],
      ),
    );
  }

  Widget _buildItemInfoCard(Map<String, dynamic> itemInfo) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.inventory_2, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Item Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Name', itemInfo['name'] ?? 'N/A'),
          _buildInfoRow('Category', itemInfo['category_name'] ?? 'N/A'),
          _buildInfoRow('Unit', itemInfo['unit'] ?? 'N/A'),
          _buildInfoRow(
              'Storage Location', itemInfo['storage_location'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> summary) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Total Transactions',
                    (summary['total_transactions'] ?? 0).toString()),
              ),
              Expanded(
                child: _buildSummaryItem(
                    'Total Issued', (summary['total_issued'] ?? 0).toString()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Total Returned',
                    (summary['total_returned'] ?? 0).toString()),
              ),
              Expanded(
                child: _buildSummaryItem(
                    'Net Issued', (summary['net_issued'] ?? 0).toString()),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildSummaryItem(
              'Current Stock', (summary['current_stock'] ?? 0).toString()),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> issue) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOut = issue['transaction_type'] == 'OUT';
    final issuedAt = DateTime.parse(issue['issued_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOut
                        ? Colors.red.withOpacity(0.1)
                        : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isOut ? Colors.red : Colors.green,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    isOut ? 'ISSUED' : 'RETURNED',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isOut ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${issuedAt.day}/${issuedAt.month}/${issuedAt.year}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  isOut ? Icons.arrow_upward : Icons.arrow_downward,
                  color: isOut ? Colors.red : Colors.green,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${issue['quantity_issued']} units',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            // Event information
            if (issue['event_name'] != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Event: ${issue['event_name']}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            // Purpose information
            if (issue['purpose'] != null &&
                issue['purpose'].toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Purpose: ${issue['purpose']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            // Notes information
            if (issue['notes'] != null &&
                issue['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.note,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Notes: ${issue['notes']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (isOut) ...[
              const SizedBox(height: 12),
              // Only show return button if the item is still issued (not returned)
              Builder(
                builder: (context) {
                  final totalIssued =
                      double.parse(issue['quantity_issued'].toString());
                  final status = issue['status']?.toString() ?? 'issued';
                  final isReturned = status == 'returned';

                  if (isReturned) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle,
                              size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            'All items returned',
                            style:
                                TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    );
                  }

                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showReturnDialog(issue),
                      icon: const Icon(Icons.undo, size: 16),
                      label: Text(
                          'Return to Inventory (${totalIssued.toStringAsFixed(0)} units)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReturnDialog(Map<String, dynamic> issue) {
    final colorScheme = Theme.of(context).colorScheme;
    final TextEditingController notesController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();

    // Calculate how much can still be returned
    final totalIssued = double.parse(issue['quantity_issued'].toString());
    final status = issue['status']?.toString() ?? 'issued';
    final isReturned = status == 'returned';

    // Set initial return quantity to the total issued amount
    quantityController.text = totalIssued.toStringAsFixed(0);

    double returnQuantity = totalIssued;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Return to Inventory'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Item: ${issue['item_name']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Issued: ${totalIssued.toStringAsFixed(0)} units',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Status: ${status.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isReturned ? Colors.green : colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!isReturned) ...[
                    TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity to Return',
                        hintText: 'Enter quantity to return...',
                        border: const OutlineInputBorder(),
                        suffixText: 'units',
                      ),
                      onChanged: (value) {
                        final parsed = double.tryParse(value) ?? 0;
                        if (parsed > totalIssued) {
                          quantityController.text =
                              totalIssued.toStringAsFixed(0);
                          returnQuantity = totalIssued;
                        } else if (parsed < 0) {
                          quantityController.text = '0';
                          returnQuantity = 0;
                        } else {
                          returnQuantity = parsed;
                        }
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colorScheme.error),
                      ),
                      child: Text(
                        'No items available to return. All issued items have already been returned.',
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Return Notes (Optional)',
                      hintText: 'Enter reason for return...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                if (!isReturned)
                  ElevatedButton(
                    onPressed: returnQuantity > 0
                        ? () async {
                            await _processReturn(
                              issue: issue,
                              quantity: returnQuantity,
                              notes: notesController.text.trim(),
                            );
                            Navigator.of(context).pop();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Return'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _processReturn({
    required Map<String, dynamic> issue,
    required double quantity,
    required String notes,
  }) async {
    // Validate return quantity
    final totalIssued = double.parse(issue['quantity_issued'].toString());
    final status = issue['status']?.toString() ?? 'issued';
    final isReturned = status == 'returned';

    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Return quantity must be greater than 0'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (quantity > totalIssued) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Cannot return more than ${totalIssued.toStringAsFixed(0)} items. Only ${totalIssued.toStringAsFixed(0)} items were issued.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Processing return...'),
              ],
            ),
          );
        },
      );

      // Get event_id from the issue data
      // The issuance history API response now includes event_id
      int eventId = 0;
      if (issue['event_id'] != null) {
        eventId = int.parse(issue['event_id'].toString());
        print('🔍 Debug: Using event_id from issue data: $eventId');
      } else {
        // Fallback to 0 if event_id is somehow missing
        eventId = 0;
        print('🔍 Debug: event_id not found, using default: $eventId');
      }

      await ref.read(inventoryProvider.notifier).updateIssuance(
            id: issue['id'],
            itemId: issue['item_id'],
            transactionType: 'IN',
            quantity: quantity,
            eventId: eventId,
            notes: notes.isEmpty ? 'Returned to inventory' : notes,
          );

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item returned to inventory successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );

      // Reload history data
      await _loadHistory();
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to return item: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
