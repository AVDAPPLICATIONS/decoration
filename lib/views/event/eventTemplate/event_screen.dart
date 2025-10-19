import 'package:flutter/material.dart';
import '../../../utils/top_snackbar_helper.dart';
import 'add_template_dialog.dart';
import 'deleteTemplate.dart';
import 'delete_template_dialog.dart';
import 'editTemplate.dart';
import 'edit_template_dialog.dart';
import '../event_details_screen.dart';
import '../years_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/event_provider.dart';
import '../../../providers/template_provider.dart';
import '../../../models/event_model.dart';
import '../../../models/event_template_model.dart';
import '../../../utils/responsive_utils.dart';
import '../../custom_widget/custom_appbar.dart';
import '../../custom_widget/custom_loading_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    final allEventsData = ref.watch(eventProvider);
    final templates = ref.watch(templateProvider);
    final isEventsLoading = ref.watch(eventLoadingProvider);
    final isTemplatesLoading = ref.watch(templateLoadingProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Debug logging
    print('EventScreen build: templates count = ${templates.length}');
    print(
        'EventScreen build: isEventsLoading = $isEventsLoading, isTemplatesLoading = $isTemplatesLoading');

    return ResponsiveBuilder(
      mobile: _buildMobileLayout(context, allEventsData, templates, colorScheme,
          isEventsLoading, isTemplatesLoading),
      tablet: _buildTabletLayout(context, allEventsData, templates, colorScheme,
          isEventsLoading, isTemplatesLoading),
      desktop: _buildDesktopLayout(context, allEventsData, templates,
          colorScheme, isEventsLoading, isTemplatesLoading),
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
      ColorScheme colorScheme,
      bool isEventsLoading,
      bool isTemplatesLoading) {
    return _buildEventScreen(context, allEventsData, templates, colorScheme,
        isEventsLoading, isTemplatesLoading);
  }

  Widget _buildTabletLayout(
      BuildContext context,
      List<EventModel> allEventsData,
      List<dynamic> templates,
      ColorScheme colorScheme,
      bool isEventsLoading,
      bool isTemplatesLoading) {
    return _buildEventScreen(context, allEventsData, templates, colorScheme,
        isEventsLoading, isTemplatesLoading);
  }

  Widget _buildDesktopLayout(
      BuildContext context,
      List<EventModel> allEventsData,
      List<dynamic> templates,
      ColorScheme colorScheme,
      bool isEventsLoading,
      bool isTemplatesLoading) {
    return _buildEventScreen(context, allEventsData, templates, colorScheme,
        isEventsLoading, isTemplatesLoading);
  }

  Widget _buildEventScreen(
      BuildContext context,
      List<EventModel> allEventsData,
      List<dynamic> templates,
      ColorScheme colorScheme,
      bool isEventsLoading,
      bool isTemplatesLoading) {
    return Scaffold(
      backgroundColor: colorScheme.primary,

      appBar: _buildResponsiveAppBar(colorScheme),
      // backgroundColor: colorScheme.background,
      body: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(
        //     begin: Alignment.topCenter,
        //     end: Alignment.bottomCenter,
        //     colors: [
        //       colorScheme.primary,
        //       colorScheme.background,
        //     ],
        //     stops: const [0.0, 0.25],
        //   ),
        // ),
        child: Container(
          margin: EdgeInsets.only(
            top: context.responsive(
              mobile: 15.0,
              tablet: 18.0,
              desktop: 24.0,
            ),
          ),
          decoration: BoxDecoration(
            // Krutarth
            color: colorScheme.secondaryContainer.withOpacity(1),
            // color: colorScheme.secondaryContainer.withOpacity(0.8),

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
                child: Column(
                  children: [
                    Row(
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
                          onPressed: () => showAddTemplateDialog(context, ref),
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
                    // Loading bar for templates
                    if (isTemplatesLoading) ...[
                      SizedBox(
                          height: context.responsive(
                              mobile: 12.0, tablet: 14.0, desktop: 16.0)),
                      CustomLoadingBar(
                        message: 'Loading templates...',
                        primaryColor: colorScheme.primary,
                        backgroundColor: colorScheme.surface,
                        height: context.responsive(
                            mobile: 4.0, tablet: 5.0, desktop: 6.0),
                      ),
                    ],
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
              if (isEventsLoading) ...[
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsive(
                        mobile: 24.0, tablet: 28.0, desktop: 32.0),
                    vertical: context.responsive(
                        mobile: 16.0, tablet: 18.0, desktop: 20.0),
                  ),
                  child: Column(
                    children: [
                      ResponsiveText(
                        'Events',
                        mobileFontSize: 18.0,
                        tabletFontSize: 20.0,
                        desktopFontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                      SizedBox(
                          height: context.responsive(
                              mobile: 12.0, tablet: 14.0, desktop: 16.0)),
                      CustomLoadingBar(
                        message: 'Loading events...',
                        primaryColor: colorScheme.primary,
                        backgroundColor: colorScheme.surface,
                        height: context.responsive(
                            mobile: 4.0, tablet: 5.0, desktop: 6.0),
                      ),
                    ],
                  ),
                ),
              ] else ...[
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
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
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size: 18,
                                      ),
                                    ),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        showEditEventDialog(
                                            context, ref, eventData);
                                      } else if (value == 'delete') {
                                        showDeleteEventDialog(
                                            context, ref, eventData);
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
                                                'status':
                                                    eventData.status ?? '',
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
        child: Row(
          children: [
            // Edit Button (Left side)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(16),
                ),
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
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      color: colorScheme.onPrimary,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Delete',
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
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        // Handle swipe actions based on direction
        print('🔄 Swipe detected: $direction for template: ${template.name}');
        if (direction == DismissDirection.startToEnd) {
          showEditTemplateDialog(context, ref, template);
        } else if (direction == DismissDirection.endToStart) {
          showDeleteTemplateDialog(context, ref, template);
        }
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
                    onTap: () => showAddTemplateDialog(context, ref),
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
}
