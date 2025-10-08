import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;

import '../../../providers/template_provider.dart';
import '../../../utils/top_snackbar_helper.dart' show showInfoTopSnackBar, showSuccessTopSnackBar, showErrorTopSnackBar;


Future<void> showAddTemplateDialog(BuildContext context, WidgetRef ref) async {
  final TextEditingController nameController = TextEditingController();
  String? errorText;

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Event Template'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Template Name',
                  hintText: 'Enter template name',
                  border: const OutlineInputBorder(),
                  errorText: errorText,
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();

                if (name.isEmpty) {
                  setState(() => errorText = 'Please enter a template name');
                  return;
                }

                Navigator.pop(context);

                try {
                  if (context.mounted) {
                    showInfoTopSnackBar(context, 'Creating template...');
                  }

                  final templateService = ref.read(templateServiceProvider);
                  final response = await templateService.createTemplate(name);

                  if (context.mounted) {
                    showSuccessTopSnackBar(
                      context,
                      'Template "$name" created successfully',
                    );
                  }

                  ref.read(templateProvider.notifier).fetchTemplates();
                  print('✅ Template created successfully: $response');
                } catch (e) {
                  print('❌ Error creating template: $e');
                  if (context.mounted) {
                    showErrorTopSnackBar(
                      context,
                      'Failed to create template: ${e.toString()}',
                    );
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      );
    },
  );
}
