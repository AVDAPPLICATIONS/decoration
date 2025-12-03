import 'package:avd_decoration_application/models/event_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/event_provider.dart' show eventProvider;
import '../../../utils/top_snackbar_helper.dart'
    show showSuccessTopSnackBar, showErrorTopSnackBar;

Future<void> showDeleteEventDialog(
  BuildContext context,
  WidgetRef ref,
  EventModel eventData,
) async {
  final colorScheme = Theme.of(context).colorScheme;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Event'),
      content: Text('Are you sure you want to delete "${eventData.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              if (eventData.id != null) {
                await ref
                    .read(eventProvider.notifier)
                    .deleteEvent(eventData.id!);

                Navigator.pop(context);

                if (context.mounted) {
                  showSuccessTopSnackBar(
                    context,
                    'Event "${eventData.name}" deleted successfully.',
                  );
                }
              }
            } catch (e) {
              Navigator.pop(context);

              if (context.mounted) {
                showErrorTopSnackBar(
                  context,
                  'Error deleting event: ${e.toString()}',
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
