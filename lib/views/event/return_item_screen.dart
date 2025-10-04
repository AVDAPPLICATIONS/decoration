import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/inventory_service.dart';
import '../../utils/snackbar_manager.dart';

class ReturnItemScreen extends ConsumerStatefulWidget {
  final int? issuanceId;
  final int itemId;
  final String itemName;
  final int maxQuantity;
  final int eventId;
  final VoidCallback onItemReturned;

  const ReturnItemScreen({
    super.key,
    required this.issuanceId,
    required this.itemId,
    required this.itemName,
    required this.maxQuantity,
    required this.eventId,
    required this.onItemReturned,
  });

  @override
  ConsumerState<ReturnItemScreen> createState() => _ReturnItemScreenState();
}

class _ReturnItemScreenState extends ConsumerState<ReturnItemScreen> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _returnItem() async {
    final quantity = int.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      SnackbarManager.showError(context, 'Please enter a valid quantity');
      return;
    }

    if (quantity > widget.maxQuantity) {
      SnackbarManager.showError(context, 'Return quantity cannot exceed issued quantity');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await InventoryService.returnItem(
        issuanceId: widget.issuanceId,
        itemId: widget.itemId,
        quantity: quantity,
        notes: _notesController.text.trim(),
      );

      SnackbarManager.showSuccess(context, 'Item returned successfully');
      widget.onItemReturned();
      Navigator.pop(context);
    } catch (e) {
      SnackbarManager.showError(context, 'Failed to return item: $e');
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
        title: const Text('Return Item'),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2,
                          color: colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.itemName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Maximum returnable quantity: ${widget.maxQuantity}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Return Form
            Text(
              'Return Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            
            // Quantity Field
            TextField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Return Quantity *',
                hintText: 'Enter quantity to return',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Notes Field
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Enter any notes about the return',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            
            const Spacer(),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _returnItem,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Return Item'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
