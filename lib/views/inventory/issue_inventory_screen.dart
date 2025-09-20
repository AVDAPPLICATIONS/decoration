import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/inventory_provider.dart';
import '../custom_widget/custom_appbar.dart';

class IssueInventoryPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> inventoryItem;

  const IssueInventoryPage({super.key, required this.inventoryItem});

  @override
  ConsumerState<IssueInventoryPage> createState() => _IssueInventoryPageState();
}

class _IssueInventoryPageState extends ConsumerState<IssueInventoryPage> {
  Map<String, dynamic>? selectedEvent;
  double issueQuantity = 1.0;
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  List<Map<String, dynamic>> events = [];
  bool isLoadingEvents = false;

  @override
  void initState() {
    super.initState();
    _quantityController.text = issueQuantity.toString();
    _quantityController.addListener(_onQuantityChanged);
    _loadEvents();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() {
      isLoadingEvents = true;
    });

    try {
      final eventsList =
          await ref.read(inventoryProvider.notifier).getEventsList();
      setState(() {
        events = eventsList;
        isLoadingEvents = false;
      });
    } catch (e) {
      setState(() {
        isLoadingEvents = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load events: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _onQuantityChanged() {
    final text = _quantityController.text;
    if (text.isNotEmpty) {
      final newQuantity = double.tryParse(text) ?? 1.0;
      // Use the correct field for available quantity
      final maxQuantity = (widget.inventoryItem['quantity'] ??
          widget.inventoryItem['availableQuantity'] ??
          0.0) as double;
      if (newQuantity != issueQuantity) {
        setState(() {
          // Clamp the quantity between 1 and max available
          issueQuantity = newQuantity.clamp(1, maxQuantity);
          // Update the controller if the value was clamped
          if (issueQuantity != newQuantity) {
            _quantityController.text = issueQuantity.toStringAsFixed(0);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(
        title: 'Issue ${widget.inventoryItem['name']}',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2,
                      color: colorScheme.primary,
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
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.inventoryItem['category']} • ${widget.inventoryItem['material']}',
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quantity
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
                      Icon(Icons.numbers, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Issue Quantity',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      IconButton(
                        onPressed: issueQuantity > 1
                            ? () => setState(() => issueQuantity--)
                            : null,
                        icon: Icon(Icons.remove_circle_outline,
                            color: issueQuantity > 1
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            issueQuantity.toString(),
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: issueQuantity <
                                (widget.inventoryItem['quantity'] ??
                                    widget.inventoryItem['availableQuantity'] ??
                                    0)
                            ? () => setState(() => issueQuantity++)
                            : null,
                        icon: Icon(Icons.add_circle_outline,
                            color: issueQuantity <
                                    (widget.inventoryItem['quantity'] ??
                                        widget.inventoryItem[
                                            'availableQuantity'] ??
                                        0)
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Notes
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
                      Icon(Icons.note, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Notes (Optional)',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add any notes about this issuance...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withOpacity(0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Events
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
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
                      Icon(Icons.event, color: colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text('Select Event',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (events.isEmpty)
                    Center(
                      child: Text('No events available',
                          style:
                              TextStyle(color: colorScheme.onSurfaceVariant)),
                    )
                  else
                    ...events.map((event) {
                      final isSelected = selectedEvent?['id'] == event['id'];
                      return ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        leading: Icon(Icons.event,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant),
                        title: Text(event['name'],
                            style: TextStyle(color: colorScheme.onSurface)),
                        trailing: isSelected
                            ? Icon(Icons.check, color: colorScheme.primary)
                            : null,
                        onTap: () => setState(() => selectedEvent = event),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Issue button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: (selectedEvent == null || isLoadingEvents)
                    ? null
                    : _confirmIssue,
                icon: const Icon(Icons.send),
                label: Text(isLoadingEvents ? 'Loading...' : 'Issue to Event'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmIssue() async {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Validate inputs
    if (selectedEvent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an event'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    if (issueQuantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid quantity'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    final maxQuantity = (widget.inventoryItem['quantity'] ??
        widget.inventoryItem['availableQuantity'] ??
        0.0) as double;
    if (issueQuantity > maxQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Quantity cannot exceed available stock ($maxQuantity)'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    // Validate IDs
    final itemId = int.tryParse(widget.inventoryItem['id'].toString());
    final eventId = int.tryParse(selectedEvent!['id'].toString());

    if (itemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid item ID'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    if (eventId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid event ID'),
          backgroundColor: colorScheme.error,
        ),
      );
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Issuing item...'),
            ],
          ),
        ),
      );

      // Call the API to issue the item
      await ref.read(inventoryProvider.notifier).issueInventoryToEvent(
            itemId: itemId,
            eventId: eventId,
            quantity: issueQuantity,
            notes: _notesController.text.trim(),
          );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: colorScheme.primary),
                const SizedBox(width: 8),
                const Text('Success!'),
              ],
            ),
            content: Text(
                '${issueQuantity} × ${widget.inventoryItem['name']} issued to ${selectedEvent!['name']}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (mounted) Navigator.pop(context);

      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.error, color: colorScheme.error),
                const SizedBox(width: 8),
                const Text('Error'),
              ],
            ),
            content: Text('Failed to issue item: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
