import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../themes/app_theme.dart';
import '../../services/event_service.dart';
import '../../services/api_service.dart';
import '../../services/image_upload_service.dart';
import '../../utils/constants.dart';
import '../../utils/responsive_utils.dart';
import 'event_tabs_screen.dart';

class AddEventScreen extends ConsumerStatefulWidget {
  final int? yearId;
  final int? templateId;

  const AddEventScreen({
    Key? key,
    this.yearId,
    this.templateId,
  }) : super(key: key);

  @override
  ConsumerState<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends ConsumerState<AddEventScreen> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  DateTime? _selectedDate;
  File? _selectedImage;
  bool _isLoading = false;


Future<void> _selectDate() async {
  final DateTime now = DateTime.now();
final DateTime lastDate = DateTime(now.year + 1, 12, 31);

  final DateTime? picked = await showDatePicker(
    context: context,
    initialDate: _selectedDate ?? now,
    firstDate: now,           // today or any future date
    lastDate: lastDate,   // restrict to 1 year from now
    helpText: 'Select EvSDent Date',
    cancelText: 'Cancel',
    confirmText: 'OK',
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      );
    },
  );

  if (picked != null && picked != _selectedDate) {
    setState(() {
      _selectedDate = picked;
    });
  }
}


  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _getImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create API service and event service
        final apiService = ApiService(apiBaseUrl);
        final eventService = EventService(apiService);

        // Upload cover image if selected
        String? coverImageUrl;
        if (_selectedImage != null) {
          try {
            final imageUploadService =
                ImageUploadService('$apiBaseUrl/api/upload');
            await imageUploadService.uploadImage(_selectedImage!);
            // Note: You might need to adjust this based on your API response
            // For now, we'll assume the API returns the image URL
            coverImageUrl =
                'uploaded_image_url'; // This should be replaced with actual API response
          } catch (e) {
            print('Error uploading image: $e');
            // Continue without image if upload fails
          }
        }

        // Prepare the request data according to the API specification
        final eventData = {
          'template_id': widget.templateId ?? 1,
          'year_id': widget.yearId ?? 1,
          'date': _selectedDate?.toIso8601String().split('T')[0] ??
              DateTime.now()
                  .toIso8601String()
                  .split('T')[0], // Format as YYYY-MM-DD
          'location': _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
          'description': _descriptionController.text.trim().isNotEmpty
              ? _descriptionController.text.trim()
              : null,
          if (coverImageUrl != null) 'cover_image': coverImageUrl,
        };

        print('Creating event with data: $eventData');

        // Call the create event API
        final createdEvent = await eventService.createEventFromData(eventData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Event saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          // Prepare event data for EventTabsScreen
          final eventDataForTabs = {
            'id': createdEvent['id'] ?? widget.templateId ?? 0,
            'name': createdEvent['name'] ?? 'Event',
            'year': _selectedDate?.year.toString() ??
                DateTime.now().year.toString(),
            'createdAt':
                createdEvent['created_at'] ?? DateTime.now().toIso8601String(),
            'details': createdEvent, // Include the full API response
          };

          // Navigate to event tabs screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EventTabsScreen(
                event: eventDataForTabs,
                isAdmin: true,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating event: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context, colorScheme),
      tablet: _buildTabletLayout(context, colorScheme),
      desktop: _buildDesktopLayout(context, colorScheme),
    );
  }

  PreferredSizeWidget _buildResponsiveAppBar(ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.primary,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: context.responsive(
        mobile: 56.0,
        tablet: 64.0,
        desktop: 72.0,
      ),
      title: ResponsiveText(
        'Add Event',
        mobileFontSize: 20.0,
        tabletFontSize: 22.0,
        desktopFontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(
            context.responsive(
              mobile: 25.0,
              tablet: 28.0,
              desktop: 30.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, ColorScheme colorScheme) {
    return _buildEventForm(context, colorScheme);
  }

  Widget _buildTabletLayout(BuildContext context, ColorScheme colorScheme) {
    return _buildEventForm(context, colorScheme);
  }

  Widget _buildDesktopLayout(BuildContext context, ColorScheme colorScheme) {
    return _buildEventForm(context, colorScheme);
  }

  Widget _buildEventForm(BuildContext context, ColorScheme colorScheme) {
    return Scaffold(
      appBar: _buildResponsiveAppBar(colorScheme),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorScheme.primary, colorScheme.background],
            stops: const [0.0, 0.25],
          ),
        ),
        child: Container(
          margin: EdgeInsets.only(
            top: context.responsive(
              mobile: 20.0,
              tablet: 24.0,
              desktop: 28.0,
            ),
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                context.responsive(
                  mobile: 30.0,
                  tablet: 32.0,
                  desktop: 35.0,
                ),
              ),
            ),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(
              context.responsive(
                mobile: 24.0,
                tablet: 28.0,
                desktop: 32.0,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(
                        context.responsive(
                          mobile: 24.0,
                          tablet: 28.0,
                          desktop: 32.0,
                        ),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary.withOpacity(0.15),
                            colorScheme.primary.withOpacity(0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.2),
                            blurRadius: context.responsive(
                              mobile: 20.0,
                              tablet: 24.0,
                              desktop: 28.0,
                            ),
                            spreadRadius: 2,
                            offset: Offset(
                                0,
                                context.responsive(
                                  mobile: 8.0,
                                  tablet: 10.0,
                                  desktop: 12.0,
                                )),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.event_note,
                        size: context.responsive(
                          mobile: 45.0,
                          tablet: 50.0,
                          desktop: 55.0,
                        ),
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  SizedBox(
                      height: context.responsive(
                    mobile: 20.0,
                    tablet: 24.0,
                    desktop: 28.0,
                  )),

                  ResponsiveText(
                    'Create New Event',
                    mobileFontSize: 24.0,
                    tabletFontSize: 26.0,
                    desktopFontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                      height: context.responsive(
                    mobile: 8.0,
                    tablet: 10.0,
                    desktop: 12.0,
                  )),

                  ResponsiveText(
                    'Fill in the details below to create your event',
                    mobileFontSize: 16.0,
                    tabletFontSize: 18.0,
                    desktopFontSize: 20.0,
                    color: colorScheme.onSurfaceVariant,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                      height: context.responsive(
                    mobile: 32.0,
                    tablet: 36.0,
                    desktop: 40.0,
                  )),

                  // Location Field
                  ResponsiveContainer(
                    mobilePadding: const EdgeInsets.all(16.0),
                    tabletPadding: const EdgeInsets.all(18.0),
                    desktopPadding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        context.responsive(
                          mobile: 24.0,
                          tablet: 26.0,
                          desktop: 28.0,
                        ),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.surface,
                          colorScheme.surface.withOpacity(0.95),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.06),
                          blurRadius: context.responsive(
                            mobile: 25.0,
                            tablet: 28.0,
                            desktop: 30.0,
                          ),
                          spreadRadius: 0,
                          offset: Offset(
                              0,
                              context.responsive(
                                mobile: 10.0,
                                tablet: 12.0,
                                desktop: 14.0,
                              )),
                        ),
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.04),
                          blurRadius: context.responsive(
                            mobile: 10.0,
                            tablet: 12.0,
                            desktop: 14.0,
                          ),
                          spreadRadius: 0,
                          offset: Offset(
                              0,
                              context.responsive(
                                mobile: 4.0,
                                tablet: 5.0,
                                desktop: 6.0,
                              )),
                        ),
                      ],
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        labelStyle: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: context.responsive(
                            mobile: 16.0,
                            tablet: 18.0,
                            desktop: 20.0,
                          ),
                        ),
                        prefixIcon: Container(
                          margin: EdgeInsets.all(
                            context.responsive(
                              mobile: 10.0,
                              tablet: 12.0,
                              desktop: 14.0,
                            ),
                          ),
                          padding: EdgeInsets.all(
                            context.responsive(
                              mobile: 10.0,
                              tablet: 12.0,
                              desktop: 14.0,
                            ),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorScheme.primary.withOpacity(0.15),
                                colorScheme.primary.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(
                              context.responsive(
                                mobile: 16.0,
                                tablet: 18.0,
                                desktop: 20.0,
                              ),
                            ),
                            border: Border.all(
                              color: colorScheme.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.location_on,
                            color: colorScheme.primary,
                            size: context.responsive(
                              mobile: 26.0,
                              tablet: 28.0,
                              desktop: 30.0,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 22,
                          horizontal: 24,
                        ),
                        hintText: 'Enter event location...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Date Picker Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.grey.shade50,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 25,
                          spreadRadius: 0,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: _selectDate,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 22,
                          horizontal: 8,
                        ),
                        child: Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary.withOpacity(0.15),
                                    AppColors.primary.withOpacity(0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.calendar_today,
                                color: AppColors.primary,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : 'Select Event  xDate',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDate != null
                                    ? Colors.black87
                                    : Colors.grey.shade400,
                              ),
                            ),
                            // Icon(
                            //   Icons.arrow_drop_down,
                            //   color: AppColors.primary,
                            //   size: 28,
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.grey.shade50,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 25,
                          spreadRadius: 0,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    child: TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        prefixIcon: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primary.withOpacity(0.15),
                                AppColors.primary.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.description,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 2.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 22,
                          horizontal: 24,
                        ),
                        hintText: 'Enter event description...',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Cover Image Field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.grey.shade50,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 25,
                          spreadRadius: 0,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.shade100,
                        width: 1,
                      ),
                    ),
                    child: InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppColors.primary.withOpacity(0.15),
                                        AppColors.primary.withOpacity(0.08),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.primary.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.image,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Cover Image',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedImage != null
                                            ? 'Image selected'
                                            : 'Tap to select cover image',
                                        style: TextStyle(
                                          color: _selectedImage != null
                                              ? Colors.green
                                              : Colors.grey.shade400,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_selectedImage != null)
                                  IconButton(
                                    onPressed: _removeImage,
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                            if (_selectedImage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                height: 120,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                      height: context.responsive(
                    mobile: 40.0,
                    tablet: 44.0,
                    desktop: 48.0,
                  )),

                  // Save Button
                  Center(
                    child: Container(
                      width: context.responsive(
                        mobile: 160.0,
                        tablet: 180.0,
                        desktop: 200.0,
                      ),
                      height: context.responsive(
                        mobile: 64.0,
                        tablet: 68.0,
                        desktop: 72.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          context.responsive(
                            mobile: 24.0,
                            tablet: 26.0,
                            desktop: 28.0,
                          ),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            colorScheme.primary,
                            colorScheme.primary.withOpacity(0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.4),
                            blurRadius: context.responsive(
                              mobile: 25.0,
                              tablet: 28.0,
                              desktop: 30.0,
                            ),
                            spreadRadius: 0,
                            offset: Offset(
                                0,
                                context.responsive(
                                  mobile: 12.0,
                                  tablet: 14.0,
                                  desktop: 16.0,
                                )),
                          ),
                          BoxShadow(
                            color: colorScheme.primary.withOpacity(0.2),
                            blurRadius: context.responsive(
                              mobile: 10.0,
                              tablet: 12.0,
                              desktop: 14.0,
                            ),
                            spreadRadius: 0,
                            offset: Offset(
                                0,
                                context.responsive(
                                  mobile: 4.0,
                                  tablet: 5.0,
                                  desktop: 6.0,
                                )),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveEvent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: context.responsive(
                                      mobile: 24.0,
                                      tablet: 26.0,
                                      desktop: 28.0,
                                    ),
                                    height: context.responsive(
                                      mobile: 24.0,
                                      tablet: 26.0,
                                      desktop: 28.0,
                                    ),
                                    child: CircularProgressIndicator(
                                      color: colorScheme.onPrimary,
                                      strokeWidth: context.responsive(
                                        mobile: 2.0,
                                        tablet: 2.5,
                                        desktop: 3.0,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                      width: context.responsive(
                                    mobile: 16.0,
                                    tablet: 18.0,
                                    desktop: 20.0,
                                  )),
                                  ResponsiveText(
                                    'Creating Event...',
                                    mobileFontSize: 18.0,
                                    tabletFontSize: 20.0,
                                    desktopFontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary,
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: context.responsive(
                                    mobile: 16.0,
                                    tablet: 18.0,
                                    desktop: 20.0,
                                  )),
                                  ResponsiveText(
                                    'Save Event',
                                    mobileFontSize: 18.0,
                                    tabletFontSize: 20.0,
                                    desktopFontSize: 22.0,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
