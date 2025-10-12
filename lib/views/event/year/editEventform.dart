import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/year_model.dart';
import '../../../services/api_service.dart';
import '../../../services/event_service.dart';
import '../../../services/gallery_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/top_snackbar_helper.dart';

class EditEventForm extends StatefulWidget {
  final Map<String, dynamic> eventDetails;
  final YearModel year;
  final int templateId;
  final VoidCallback onEventUpdated;

  const EditEventForm({
    required this.eventDetails,
    required this.year,
    required this.templateId,
    required this.onEventUpdated,
  });

  @override
  State<EditEventForm> createState() => _EditEventFormState();
}

class _EditEventFormState extends State<EditEventForm> {
  late TextEditingController eventNameController;
  late TextEditingController locationController;
  late TextEditingController dateController;
  File? selectedImage;
  String? currentImageUrl;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    final eventData = widget.eventDetails['data']['event'];
    String date = DateFormat('dd-MM-yyyy').format(DateTime.parse(eventData['date']));
    eventNameController = TextEditingController(text: eventData['description'] ?? '');
    locationController = TextEditingController(text: eventData['location'] ?? '');
    dateController = TextEditingController(text: date ?? '');
    currentImageUrl = eventData['cover_image'];
  }

  @override
  void dispose() {
    eventNameController.dispose();
    locationController.dispose();
    dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.edit,
                      color: colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Edit Event - ${widget.year.yearName}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
            
                // Event Name Field
                TextField(
                  controller: eventNameController,
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.event),
                  ),
                ),
                const SizedBox(height: 16),
            
                // Location Field
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16),
            
                // Date Field
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                    suffixIcon: const Icon(Icons.calendar_today_outlined),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      dateController.text = date.toIso8601String().split('T')[0];
                    }
                  },
                ),
                const SizedBox(height: 16),
            
                // Cover Image Section
                Text(
                  'Cover Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () async {
                    final image = await GalleryService.pickImageFromGallery();
                    if (image != null) {
                      setState(() {
                        selectedImage = image;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colorScheme.outline,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        selectedImage!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    )
                        : currentImageUrl != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        apiBaseUrl + currentImageUrl!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: colorScheme.surfaceContainerHighest,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 40,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to change image',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                        : Container(
                      color: colorScheme.surfaceVariant,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 40,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add cover image',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
            
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isUpdating ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: colorScheme.outline),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isUpdating ? null : _updateEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: isUpdating
                            ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Updating...'),
                          ],
                        )
                            : const Text('Update Event'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    );
  }

  void _updateEvent() async {
    setState(() {
      isUpdating = true;
    });

    try {
      // Show initial loading message (Info)
      showInfoTopSnackBar(context, 'Updating event...');

      final apiService = ApiService(apiBaseUrl);
      final eventService = EventService(apiService);
      final eventData = widget.eventDetails['data']['event'];

      // Call the update API
      final result = await eventService.updateEventDetails(
        eventId: eventData['id'],
        eventName: eventNameController.text,
        location: locationController.text,
        date: dateController.text,
        templateId: widget.templateId,
        yearId: widget.year.id,
        coverImage: selectedImage,
        existingImageUrl: currentImageUrl,
      );

      // ✅ Success case
      if (result['id'] != null && result['id'] == eventData['id']) {
        showSuccessTopSnackBar(context, 'Event updated successfully!');

        // Navigator.pop(context);
        widget.onEventUpdated();
      }
      // ❌ Explicit failure case
      else if (result['success'] == false) {
        showErrorTopSnackBar(
          context,
          result['message'] ?? 'Failed to update event. Please try again.',
        );
      }
      // ⚠️ Unexpected API format
      else {
        showErrorTopSnackBar(
          context,
          'Unexpected response from server. Please try again.',
        );
      }

    } catch (e) {
      // Determine specific error type
      String errorMessage;
      final errorStr = e.toString();

      if (errorStr.contains('SocketException') || errorStr.contains('HandshakeException')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (errorStr.contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (errorStr.contains('FormatException')) {
        errorMessage = 'Invalid data format. Please check your input.';
      } else if (errorStr.contains('404')) {
        errorMessage = 'Event not found. Please refresh and try again.';
      } else if (errorStr.contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        errorMessage = 'Error updating event: $errorStr';
      }

      // ❌ Error snackbar
      showErrorTopSnackBar(context, errorMessage);

    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }
}
