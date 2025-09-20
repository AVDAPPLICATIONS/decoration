import 'package:flutter/material.dart';
import 'event_details_screen.dart';
import 'years_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/event_provider.dart';
import '../../providers/template_provider.dart';
import '../../models/event_model.dart';
import '../../models/event_template_model.dart';
import '../../utils/responsive_utils.dart';
import '../custom_widget/custom_appbar.dart';

/// ----------------------
/// Event Screen
/// ----------------------
class EventScreen extends ConsumerStatefulWidget {
  final bool isAdmin;
  const EventScreen({Key? key, required this.isAdmin}) : super(key: key);

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  @override
  void initState() {
    super.initState();

    // Fetch events and templates on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('EventScreen initState: Starting to fetch data...');
      ref.read(eventProvider.notifier).fetchEvents();
      ref.read(templateProvider.notifier).fetchTemplates();
      print('EventScreen initState: Fetch calls initiated');
    });
  }

  void _editEvent(EventModel eventData) async {
    final TextEditingController nameController =
        TextEditingController(text: eventData.name ?? '');

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Event'),
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
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context, {
                  'id': eventData.id,
                  'name': nameController.text.trim(),
                  'status': eventData.status,
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && eventData.id != null) {
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

      await ref
          .read(eventProvider.notifier)
          .updateEvent(eventData.id!, updatedEvent);
    }
  }

  void _deleteEvent(EventModel eventData) {
    showDialog(
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
              if (eventData.id != null) {
                await ref
                    .read(eventProvider.notifier)
                    .deleteEvent(eventData.id!);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${eventData.name} deleted successfully'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    margin:
                        const EdgeInsets.only(bottom: 100, left: 16, right: 16),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allEventsData = ref.watch(eventProvider);
    final templates = ref.watch(templateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Debug logging
    print('EventScreen build: templates count = ${templates.length}');

    return ResponsiveBuilder(
      mobile:
          _buildMobileLayout(context, allEventsData, templates, colorScheme),
      tablet:
          _buildTabletLayout(context, allEventsData, templates, colorScheme),
      desktop:
          _buildDesktopLayout(context, allEventsData, templates, colorScheme),
    );
  }

  PreferredSizeWidget _buildResponsiveAppBar(ColorScheme colorScheme) {
    return CustomAppBar(
      title: 'Events',
      showBackButton: false,
    );
  }

  Widget _buildMobileLayout(
      BuildContext context,
      List<EventModel> allEventsData,
      List<dynamic> templates,
      ColorScheme colorScheme) {
    return _buildEventScreen(context, allEventsData, templates, colorScheme);
  }

  Widget _buildTabletLayout(
      BuildContext context,
      List<EventModel> allEventsData,
      List<dynamic> templates,
      ColorScheme colorScheme) {
    return _buildEventScreen(context, allEventsData, templates, colorScheme);
  }

  Widget _buildDesktopLayout(
      BuildContext context,
      List<EventModel> allEventsData,
      List<dynamic> templates,
      ColorScheme colorScheme) {
    return _buildEventScreen(context, allEventsData, templates, colorScheme);
  }

  Widget _buildEventScreen(BuildContext context, List<EventModel> allEventsData,
      List<dynamic> templates, ColorScheme colorScheme) {
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
          child: Column(
            children: [
              // Event Templates Section
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.responsive(
                    mobile: 24.0,
                    tablet: 28.0,
                    desktop: 32.0,
                  ),
                  vertical: context.responsive(
                    mobile: 16.0,
                    tablet: 18.0,
                    desktop: 20.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ResponsiveText(
                      'Event Templates',
                      mobileFontSize: 18.0,
                      tabletFontSize: 20.0,
                      desktopFontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                    IconButton(
                      onPressed: () => _showAddTemplateDialog(context),
                      icon: Icon(
                        Icons.add,
                        color: colorScheme.primary,
                        size: context.responsive(
                          mobile: 24.0,
                          tablet: 26.0,
                          desktop: 28.0,
                        ),
                      ),
                      tooltip: 'Add Template',
                      padding: EdgeInsets.all(
                        context.responsive(
                          mobile: 8.0,
                          tablet: 10.0,
                          desktop: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: templates.isNotEmpty
                    ? RefreshIndicator(
                        onRefresh: () async {
                          print('Pull-to-refresh triggered');
                          await ref
                              .read(templateProvider.notifier)
                              .fetchTemplates();
                        },
                        color: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.responsive(
                              mobile: 20.0,
                              tablet: 24.0,
                              desktop: 28.0,
                            ),
                          ),
                          itemCount: templates.length,
                          itemBuilder: (context, index) {
                            if (index >= templates.length) {
                              return const SizedBox.shrink();
                            }
                            final template = templates[index];
                            return _buildTemplateCard(template, index);
                          },
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          print('Pull-to-refresh triggered (empty state)');
                          await ref
                              .read(templateProvider.notifier)
                              .fetchTemplates();
                        },
                        color: Theme.of(context).colorScheme.primary,
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: _buildEmptyTemplatesState(),
                          ),
                        ),
                      ),
              ),
              // Events List Section
              Container(
                height: MediaQuery.of(context).size.height *
                    0.0, // Fixed height for events list
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: allEventsData.length,
                  itemBuilder: (context, index) {
                    final eventData = allEventsData[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context)
                                .colorScheme
                                .primaryContainer
                                .withOpacity(0.1),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .shadow
                                .withOpacity(0.08),
                            blurRadius: 25,
                            spreadRadius: 0,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .shadow
                                .withOpacity(0.04),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            if (eventData.id != null) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EventDetailsScreen(
                                    eventData: {
                                      'id': eventData.id.toString(),
                                      'name': eventData.name ?? '',
                                      'date':
                                          eventData.date?.toIso8601String() ??
                                              '',
                                      'location': eventData.location ?? '',
                                      'status': eventData.status ?? '',
                                    },
                                    isAdmin: widget.isAdmin,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 0,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.event,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        eventData.name ?? 'Unnamed Event',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Event ID: ${eventData.id ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  icon: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.1),
                                          Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.more_vert,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 18,
                                    ),
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editEvent(eventData);
                                    } else if (value == 'delete') {
                                      _deleteEvent(eventData);
                                    } else if (value == 'view') {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => EventDetailsScreen(
                                            eventData: {
                                              'id': eventData.id.toString(),
                                              'name': eventData.name ?? '',
                                              'date': eventData.date
                                                      ?.toIso8601String() ??
                                                  '',
                                              'location':
                                                  eventData.location ?? '',
                                              'status': eventData.status ?? '',
                                            },
                                            isAdmin: widget.isAdmin,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'view',
                                      child: Row(
                                        children: [
                                          Icon(Icons.visibility, size: 20),
                                          SizedBox(width: 8),
                                          Text('View Details'),
                                        ],
                                      ),
                                    ),
                                    if (widget.isAdmin) ...[
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, size: 20),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete,
                                                size: 20, color: Colors.red),
                                            SizedBox(width: 8),
                                            Text('Delete',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateCard(dynamic template, int index) {
    // Add null safety checks
    if (template == null) {
      return const SizedBox.shrink();
    }

    final templateId = template.id;
    final templateName = template.name;

    if (templateId == null || templateName == null) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key('template_$templateId'),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Edit Button (Left side)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
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
            ),
            // Delete Button (Right side)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      color: colorScheme.error,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Delete',
                      style: TextStyle(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Handle swipe actions based on direction
        print('🔄 Swipe detected: $direction for template: ${template.name}');
        if (direction == DismissDirection.startToEnd) {
          // Swipe right - Open edit dialog (matches left side edit button)
          print('📝 Opening edit dialog for template: ${template.name}');
          _showEditTemplateDialog(template);
        } else if (direction == DismissDirection.endToStart) {
          // Swipe left - Open delete dialog (matches right side delete button)
          print('🗑️ Opening delete dialog for template: ${template.name}');
          _showDeleteTemplateConfirmation(template);
        }
        // Don't actually dismiss the item
        return false;
      },
      child: Container(
        margin: EdgeInsets.only(
          bottom: context.responsive(
            mobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          ),
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(
            context.responsive(
              mobile: 16.0,
              tablet: 18.0,
              desktop: 20.0,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.05),
              blurRadius: context.responsive(
                mobile: 10.0,
                tablet: 12.0,
                desktop: 14.0,
              ),
              spreadRadius: 0,
              offset: Offset(
                  0,
                  context.responsive(
                    mobile: 2.0,
                    tablet: 3.0,
                    desktop: 4.0,
                  )),
            ),
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.02),
              blurRadius: context.responsive(
                mobile: 4.0,
                tablet: 5.0,
                desktop: 6.0,
              ),
              spreadRadius: 0,
              offset: Offset(
                  0,
                  context.responsive(
                    mobile: 1.0,
                    tablet: 1.5,
                    desktop: 2.0,
                  )),
            ),
          ],
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              // Navigate to years screen with proper back navigation
              Navigator.of(context, rootNavigator: true)
                  .push(
                MaterialPageRoute(
                  builder: (_) => YearsScreen(
                    templateId: templateId,
                    templateName: templateName,
                  ),
                  settings: const RouteSettings(name: '/years'),
                ),
              )
                  .then((_) {
                // This callback is called when the Years Screen is popped
                // We can use this to ensure we're back on the Event Screen
                print('Back from Years Screen to Event Screen');
              });
            },
            child: Padding(
              padding: EdgeInsets.all(
                context.responsive(
                  mobile: 16.0,
                  tablet: 18.0,
                  desktop: 20.0,
                ),
              ),
              child: Row(
                children: [
                  // Template Icon
                  Container(
                    width: context.responsive(
                      mobile: 60.0,
                      tablet: 65.0,
                      desktop: 70.0,
                    ),
                    height: context.responsive(
                      mobile: 60.0,
                      tablet: 65.0,
                      desktop: 70.0,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(
                        context.responsive(
                          mobile: 16.0,
                          tablet: 18.0,
                          desktop: 20.0,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: context.responsive(
                            mobile: 8.0,
                            tablet: 10.0,
                            desktop: 12.0,
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
                    child: Icon(
                      Icons.description,
                      color: colorScheme.onPrimary,
                      size: context.responsive(
                        mobile: 28.0,
                        tablet: 30.0,
                        desktop: 32.0,
                      ),
                    ),
                  ),
                  SizedBox(
                      width: context.responsive(
                    mobile: 16.0,
                    tablet: 18.0,
                    desktop: 20.0,
                  )),

                  // Template Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ResponsiveText(
                          templateName,
                          mobileFontSize: 18.0,
                          tabletFontSize: 20.0,
                          desktopFontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),

                  // Arrow Icon
                  Container(
                    padding: EdgeInsets.all(
                      context.responsive(
                        mobile: 8.0,
                        tablet: 10.0,
                        desktop: 12.0,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(
                        context.responsive(
                          mobile: 8.0,
                          tablet: 10.0,
                          desktop: 12.0,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: colorScheme.primary,
                      size: context.responsive(
                        mobile: 20.0,
                        tablet: 22.0,
                        desktop: 24.0,
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

  void _showAddTemplateDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Event Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Template Name',
                hintText: 'Enter template name',
                border: OutlineInputBorder(),
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
              if (name.isNotEmpty) {
                Navigator.pop(context);
                await _createTemplate(name);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a template name'),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.only(bottom: 100, left: 16, right: 16),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _createTemplate(String name) async {
    try {
      // Show loading message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Creating template...'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
          ),
        );
      }

      // Create template using the service
      final templateService = ref.read(templateServiceProvider);
      final response = await templateService.createTemplate(name);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Template "$name" created successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
          ),
        );
      }

      // Refresh templates list
      ref.read(templateProvider.notifier).fetchTemplates();

      print('✅ Template created successfully: $response');
    } catch (e) {
      print('❌ Error creating template: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create template: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 100, left: 16, right: 16),
          ),
        );
      }
    }
  }

  Widget _buildEmptyTemplatesState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(
          context.responsive(
            mobile: 32.0,
            tablet: 36.0,
            desktop: 40.0,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty state icon
              Container(
                width: context.responsive(
                  mobile: 120.0,
                  tablet: 130.0,
                  desktop: 140.0,
                ),
                height: context.responsive(
                  mobile: 120.0,
                  tablet: 130.0,
                  desktop: 140.0,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.3),
                    width: context.responsive(
                      mobile: 2.0,
                      tablet: 2.5,
                      desktop: 3.0,
                    ),
                  ),
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: context.responsive(
                    mobile: 60.0,
                    tablet: 65.0,
                    desktop: 70.0,
                  ),
                  color: colorScheme.primary.withOpacity(0.6),
                ),
              ),
              SizedBox(
                  height: context.responsive(
                mobile: 24.0,
                tablet: 28.0,
                desktop: 32.0,
              )),
          
              // Empty state title
              ResponsiveText(
                'No Event Templates',
                mobileFontSize: 24.0,
                tabletFontSize: 26.0,
                desktopFontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              SizedBox(
                  height: context.responsive(
                mobile: 12.0,
                tablet: 14.0,
                desktop: 16.0,
              )),
          
              // Empty state description
              ResponsiveText(
                'Create your first event template to get started with organizing your events.',
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
          
              // Add Template button
              Container(
                width: double.infinity,
                height: context.responsive(
                  mobile: 56.0,
                  tablet: 60.0,
                  desktop: 64.0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    context.responsive(
                      mobile: 16.0,
                      tablet: 18.0,
                      desktop: 20.0,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: context.responsive(
                        mobile: 12.0,
                        tablet: 14.0,
                        desktop: 16.0,
                      ),
                      spreadRadius: 0,
                      offset: Offset(
                          0,
                          context.responsive(
                            mobile: 6.0,
                            tablet: 7.0,
                            desktop: 8.0,
                          )),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showAddTemplateDialog(context),
                    borderRadius: BorderRadius.circular(
                      context.responsive(
                        mobile: 16.0,
                        tablet: 18.0,
                        desktop: 20.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
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
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            color: colorScheme.primary,
                            size: context.responsive(
                              mobile: 18.0,
                              tablet: 20.0,
                              desktop: 22.0,
                            ),
                          ),
                        ),
                        SizedBox(
                            width: context.responsive(
                          mobile: 12.0,
                          tablet: 14.0,
                          desktop: 16.0,
                        )),
                        ResponsiveText(
                          'Create Your First Template',
                          mobileFontSize: 16.0,
                          tabletFontSize: 18.0,
                          desktopFontSize: 20.0,
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                  height: context.responsive(
                mobile: 16.0,
                tablet: 18.0,
                desktop: 20.0,
              )),
          
              // Refresh button
              TextButton.icon(
                onPressed: () {
                  ref.read(templateProvider.notifier).fetchTemplates();
                },
                icon: Icon(
                  Icons.refresh,
                  color: colorScheme.primary,
                  size: context.responsive(
                    mobile: 20.0,
                    tablet: 22.0,
                    desktop: 24.0,
                  ),
                ),
                label: ResponsiveText(
                  'Refresh',
                  mobileFontSize: 14.0,
                  tabletFontSize: 16.0,
                  desktopFontSize: 18.0,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditTemplateDialog(dynamic template) {
    final TextEditingController nameController =
        TextEditingController(text: template.name);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceVariant,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.edit,
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Edit Template',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Template Name Field
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Template Name',
                    hintText: 'Enter template name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final newName = nameController.text.trim();
                          if (newName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('Please enter a template name'),
                                backgroundColor: colorScheme.error,
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
                            // Create updated template model
                            final updatedTemplate = EventTemplateModel(
                              id: template.id,
                              name: newName,
                              createdAt: template.createdAt,
                            );
                            await ref
                                .read(templateProvider.notifier)
                                .updateTemplate(template.id, updatedTemplate);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Template "$newName" updated successfully!'),
                                backgroundColor: colorScheme.primary,
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
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error updating template: ${e.toString()}'),
                                backgroundColor: colorScheme.error,
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteTemplateConfirmation(dynamic template) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.surface,
                colorScheme.surfaceVariant,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.delete_outline,
                        color: colorScheme.error,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Delete Template',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Warning Message
                Text(
                  'Are you sure you want to delete "${template.name}"? This action cannot be undone.',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            print(
                                '🗑️ Deleting template with ID: ${template.id}, name: ${template.name}');
                            await ref
                                .read(templateProvider.notifier)
                                .deleteTemplate(template.id);
                            print('✅ Template deleted successfully');
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Template "${template.name}" deleted successfully!'),
                                backgroundColor: colorScheme.primary,
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
                          } catch (e) {
                            print('❌ Error deleting template: $e');
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error deleting template: ${e.toString()}'),
                                backgroundColor: colorScheme.error,
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
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
