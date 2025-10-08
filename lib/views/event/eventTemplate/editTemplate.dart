import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/event_model.dart' show EventModel;
import '../../../providers/event_provider.dart' show eventProvider;
import '../../../utils/top_snackbar_helper.dart' show showErrorTopSnackBar, showSuccessTopSnackBar;

Future<void> showEditEventDialog(
    BuildContext context,
    WidgetRef ref,
    EventModel eventData,
    ) async {
  final TextEditingController nameController =
  TextEditingController(text: eventData.name ?? '');

  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Event xdasd'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Event Name',
              border: OutlineInputBorder(),
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
            final newName = nameController.text.trim();
            if (newName.isEmpty) {
              showErrorTopSnackBar(context, 'Event name cannot be empty.');
              return;
            }
            Navigator.pop(context, {
              'id': eventData.id,
              'name': newName,
              'status': eventData.status,
            });
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (result != null && eventData.id != null) {
    try {
      final updatedEvent = EventModel(
        id: eventData.id,
        name: result['name'],
        status: result['status'],
        location: eventData.location,
        description: eventData.description,
        date: eventData.date,
        templateId: eventData.templateId,
        yearId: eventData.yearId,
        coverImage: eventData.coverImage,
        createdAt: eventData.createdAt,
      );

      await ref.read(eventProvider.notifier).updateEvent(eventData.id!, updatedEvent);

      if (context.mounted) {
        showSuccessTopSnackBar(
          context,
          'Event "${result['name']}" updated successfully!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        showErrorTopSnackBar(context, 'Error updating event: $e');
      }
    }
  }
}
