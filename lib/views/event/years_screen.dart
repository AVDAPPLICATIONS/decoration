import 'package:avd_decoration_application/utils/responsive_utils.dart';
import 'package:avd_decoration_application/views/custom_widget/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/event_service.dart';
import '../../services/api_service.dart';
import '../../models/year_model.dart';
import '../../providers/year_provider.dart';
import '../../utils/constants.dart';
import 'event_details_screen.dart';
import 'widget/add_event_details_form.dart';

class YearsScreen extends ConsumerStatefulWidget {
  final int? templateId;
  final String? templateName;

  const YearsScreen({
    super.key,
    this.templateId,
    this.templateName,
  });

  @override
  ConsumerState<YearsScreen> createState() => _YearsScreenState();
}

class _YearsScreenState extends ConsumerState<YearsScreen> {
  final _yearController = TextEditingController();
  bool _isLoadingEventDetails = false;
  bool _isLoadingYears = false;

  @override
  void initState() {
    super.initState();
    _loadYears();
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _loadYears() async {
    setState(() {
      _isLoadingYears = true;
    });

    try {
      await ref
          .read(yearProvider.notifier)
          .fetchYears(templateId: widget.templateId);
    } catch (e) {
      print('Error loading years: $e');
    } finally {
      setState(() {
        _isLoadingYears = false;
      });
    }
  }
  PreferredSizeWidget _buildResponsiveAppBar(ColorScheme colorScheme) {
    return CustomAppBarWithLoading(
      title: widget.templateName != null
          ? '${widget.templateName} - Years'
          : 'Years Management',
      isLoading: _isLoadingEventDetails,
      backTooltip: 'Back to Events',
    );
  }

  @override
  Widget build(BuildContext context) {
    final years = ref.watch(yearProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context, years, colorScheme),
      tablet: _buildTabletLayout(context, years, colorScheme),
      desktop: _buildDesktopLayout(context, years, colorScheme),
    );
  }

  Widget _buildMobileLayout(
      BuildContext context, List<YearModel> years, ColorScheme colorScheme) {
    return _buildYearsScreen(context, years, colorScheme);
  }

  Widget _buildTabletLayout(
      BuildContext context, List<YearModel> years, ColorScheme colorScheme) {
    return _buildYearsScreen(context, years, colorScheme);
  }

  Widget _buildDesktopLayout(
      BuildContext context, List<YearModel> years, ColorScheme colorScheme) {
    return _buildYearsScreen(context, years, colorScheme);
  }

  Widget _buildYearsScreen(BuildContext context, List<YearModel> years, ColorScheme colorScheme) {
    return Scaffold(
      appBar: _buildResponsiveAppBar(colorScheme),
      backgroundColor: colorScheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.background,
            ],
            stops: const [0.0, 0.25],
          ),
        ),
        child: Container(
          margin: EdgeInsets.only(
            top: context.responsive(
              mobile: 15.0,
              tablet: 18.0,
              desktop: 24.0,
            ),
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                context.responsive(
                  mobile: 28.0,
                  tablet: 28.0,
                  desktop: 28.0,
                ),
              ),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: context.responsive(
              mobile: 100.0,
              tablet: 110.0,
              desktop: 120.0,
            ),
          ),
          child: _isLoadingYears
              ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadYears,
                  color: colorScheme.primary,
                  backgroundColor: colorScheme.surface,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      context.responsive(
                        mobile: 16.0,
                        tablet: 20.0,
                        desktop: 24.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add New Year Section
                        _buildAddYearSection(),
                        SizedBox(
                          height: context.responsive(
                            mobile: 20.0,
                            tablet: 24.0,
                            desktop: 28.0,
                          ),
                        ),

                        // Years List Section
                        _buildYearsSection(years),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }



  Widget _buildAddYearSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Add New Year',
          mobileFontSize: 20.0,
          tabletFontSize: 22.0,
          desktopFontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
        SizedBox(
          height: context.responsive(
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          ),
        ),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(
            context.responsive(
              mobile: 16.0,
              tablet: 18.0,
              desktop: 20.0,
            ),
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.08),
                spreadRadius: 0,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _yearController,
                  decoration: InputDecoration(
                    labelText: 'Year',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: colorScheme.primary),
                    ),
                    hintText: 'e.g., 2027',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _addYear,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: const Text('Add'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYearsSection(List<dynamic> years) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Years',
          mobileFontSize: 18.0,
          tabletFontSize: 20.0,
          desktopFontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
        SizedBox(
          height: context.responsive(
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          ),
        ),
        years.isEmpty
            ? Container(
                width: double.infinity,
                padding: EdgeInsets.all(
                  context.responsive(
                    mobile: 32.0,
                    tablet: 36.0,
                    desktop: 40.0,
                  ),
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.05),
                      blurRadius: 10,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.02),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: ResponsiveText(
                    'No years available',
                    mobileFontSize: 16.0,
                    tabletFontSize: 18.0,
                    desktopFontSize: 20.0,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: years.length,
                itemBuilder: (context, index) {
                  final year = years[index];
                  return _buildYearCard(year);
                },
              ),
      ],
    );
  }

  Widget _buildYearCard(dynamic year) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _getEventDetailsForYear(year),
      builder: (context, snapshot) {
        final eventDetails = snapshot.data;
        final hasEventDetails = eventDetails != null &&
            eventDetails['success'] == true &&
            eventDetails['data'] != null;

        print('🔍 Debug: FutureBuilder for year ${year.id}');
        print('  - snapshot.connectionState: ${snapshot.connectionState}');
        print('  - eventDetails: $eventDetails');
        print('  - hasEventDetails: $hasEventDetails');

        if (hasEventDetails) {
          print(
              '  - cover_image: ${eventDetails['data']['event']['cover_image']}');
        }

        return Dismissible(
          key: Key('year_${year.id}'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colorScheme.error,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.delete,
                  color: colorScheme.onError,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Delete',
                  style: TextStyle(
                    color: colorScheme.onError,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Year'),
                content: Text(
                    'Are you sure you want to delete year ${year.yearName}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          },
          onDismissed: (direction) async {
            // Immediately remove from local state to prevent the error
            ref.read(yearProvider.notifier).removeYearFromState(year.id);

            try {
              await ref.read(yearProvider.notifier).deleteYear(year.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Year ${year.yearName} deleted successfully!'),
                    backgroundColor: colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.only(
                      bottom:
                          100, // Adjust this value based on your bottom nav height
                      left: 16,
                      right: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            } catch (e) {
              // If deletion fails, re-add the year to the state
              ref.read(yearProvider.notifier).addYearBackToState(year);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting year: ${e.toString()}'),
                    backgroundColor: colorScheme.error,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.only(
                      bottom:
                          100, // Adjust this value based on your bottom nav height
                      left: 16,
                      right: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.02),
                  blurRadius: 4,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showEventDetails(year),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Year Icon or Event Cover Image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: hasEventDetails &&
                                eventDetails['data']['event']['cover_image'] !=
                                    null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(
                                  apiBaseUrl +
                                      eventDetails['data']['event']
                                          ['cover_image'],
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to calendar icon if image fails to load
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            colorScheme.primary,
                                            colorScheme.secondary,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.calendar_today,
                                        color: colorScheme.onPrimary,
                                        size: 28,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colorScheme.primary,
                                      colorScheme.secondary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.calendar_today,
                                  color: colorScheme.onPrimary,
                                  size: 28,
                                ),
                              ),
                      ),
                      const SizedBox(width: 16),

                      // Year Details
                      Expanded(
                        child: Text(
                          year.yearName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),

                      // Arrow Icon
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _getEventDetailsForYear(dynamic year) async {
    if (widget.templateId == null) {
      print('🔍 Debug: No templateId for year ${year.id}');
      return null;
    }

    try {
      final apiService = ApiService(apiBaseUrl);
      final eventService = EventService(apiService);

      print(
          '🔍 Debug: Fetching event details for year ${year.id}, templateId: ${widget.templateId}');
      final eventDetails = await eventService.getEventDetails(
        templateId: widget.templateId!,
        yearId: year.id,
      );

      print('🔍 Debug: Event details for year ${year.id}: $eventDetails');

      // Check if event has cover image
      if (eventDetails['success'] == true && eventDetails['data'] != null) {
        final coverImage = eventDetails['data']['event']['cover_image'];
        print('🔍 Debug: Cover image for year ${year.id}: $coverImage');
      }

      return eventDetails;
    } catch (e) {
      print('❌ Error fetching event details for year ${year.id}: $e');
      return null;
    }
  }

  void _addYear() async {
    final yearName = _yearController.text.trim();
    if (yearName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid year'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            bottom: 100,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (widget.templateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Template information not available'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            bottom: 100,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Check if year already exists for this template
    final years = ref.read(yearProvider);
    if (years.any((year) =>
        year.yearName == yearName && year.templateId == widget.templateId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Year already exists for this template!'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            bottom: 100,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    try {
      final newYear = YearModel(
        id: 0, // Will be set by the server
        yearName: yearName,
        templateId: widget.templateId ?? 0,
        createdAt: DateTime.now(),
        templateName: widget.templateName,
      );

      final createdYear =
          await ref.read(yearProvider.notifier).addYear(newYear);
      _yearController.clear();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Year $yearName added successfully!'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            bottom: 100,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      // Open Add Event Details Form for the newly created year
      if (createdYear != null) {
        _showAddEventDetailsForm(yearId: createdYear.id, yearName: createdYear.yearName);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding year: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            bottom: 100,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _showEventDetails(YearModel year) async {
    if (widget.templateId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Template information not available'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(
            bottom: 100,
            left: 16,
            right: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoadingEventDetails = true;
    });

    try {
      final apiService = ApiService(apiBaseUrl);
      final eventService = EventService(apiService);

      final eventDetails = await eventService.getEventDetails(
        templateId: widget.templateId!,
        yearId: year.id,
      );

      setState(() {
        _isLoadingEventDetails = false;
      });

      if (mounted) {
        // Check if event was found or not
        if (eventDetails['success'] == true && eventDetails['data'] != null) {
          // Event exists, navigate to EventDetailsScreen
          _navigateToEventDetails(eventDetails, yearId: year.id);
        } else {
          // Event not found, show Add Event Details form
          _showAddEventDetailsForm(yearId: year.id, yearName: year.yearName);
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingEventDetails = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading event details: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(
              bottom: 100,
              left: 16,
              right: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  void _navigateToEventDetails(Map<String, dynamic> eventDetails,
      {required int yearId}) {
    final eventData = eventDetails['data']['event'];
    final galleryData = eventDetails['data']['gallery'];
    final costData = eventDetails['data']['cost'];
    final issuancesData = eventDetails['data']['issuances'];

    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: EventDetailsScreen(
            eventData: {
              'id': eventData['id'],
              'name': eventData['description'] ??
                  'Event', // Using description as name
              'date': eventData['date'],
              'location': eventData['location'],
              'cover_image': eventData['cover_image'],
              'template_id': eventData['template_id'],
              'year_id': eventData['year_id'],
              'gallery': galleryData,
              'cost': costData,
              'issuances': issuancesData,
            },
            isAdmin: true, // Assuming admin access for now
          ),
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showAddEventDetailsForm({required int yearId, String? yearName}) {
    // Get year name from the year provider if not provided
    final years = ref.read(yearProvider);
    final year = years.firstWhere(
      (y) => y.id == yearId,
      orElse: () => YearModel(
        id: yearId,
        yearName: yearName ?? 'Unknown',
        templateId: widget.templateId ?? 0,
        createdAt: DateTime.now(),
      ),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddEventDetailsForm(
          templateId: widget.templateId!,
          yearId: yearId,
          yearName: year.yearName,
          onEventCreated: (eventData) {
            print(
                'Event created successfully, navigating to details: $eventData');

            // Close the form first
            Navigator.pop(context);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event created successfully!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  bottom: 100,
                  left: 16,
                  right: 16,
                ),
              ),
            );

            // Navigate to event details after creation
            Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  body: EventDetailsScreen(
                    eventData: eventData,
                    isAdmin: true,
                  ),
                ),
                fullscreenDialog: true,
              ),
            );
          },
        ),
      ),
    );
  }
}
