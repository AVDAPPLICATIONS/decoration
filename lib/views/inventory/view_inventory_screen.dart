import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avd_decoration_application/widgets/cached_network_or_file_image.dart'
    as cnf;
import '../../providers/inventory_provider.dart';
import '../../utils/responsive_utils.dart';
import '../../utils/snackbar_manager.dart';
import 'fullscreen_image_viewer.dart';

class ViewInventoryPage extends ConsumerStatefulWidget {
  final String itemId;
  const ViewInventoryPage({super.key, required this.itemId});

  @override
  ConsumerState<ViewInventoryPage> createState() => _ViewInventoryPageState();
}

class _ViewInventoryPageState extends ConsumerState<ViewInventoryPage> {
  late InventoryItem item;
  late String categoryName;

  // Loading state
  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeItem();
  }

  void _initializeItem() {
    try {
      final inventoryItems = ref.read(inventoryProvider);
      item = inventoryItems.firstWhere((i) => i.id == widget.itemId);
      categoryName = item.categoryName.toLowerCase();
    } catch (e) {
      // Show error and navigate back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SnackBarManager.showErrorCustom(
          context: context,
          message: 'Error loading item: $e',
        );
        Navigator.of(context).pop();
      });
    }
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    IconData? icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    if (item.itemImage == null || item.itemImage!.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No Image Available',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item Image',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImageViewer(
                    imageUrl: ref
                        .read(inventoryServiceProvider)
                        .getImageUrl(item.itemImage),
                    itemName: item.name,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: cnf.CachedNetworkOrFileImage(
                  imageUrl: ref
                      .read(inventoryServiceProvider)
                      .getImageUrl(item.itemImage),
                  fit: BoxFit.cover,
                  placeholder: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: Container(
                    color: Theme.of(context).colorScheme.surface,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 48,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
        'View Item',
        mobileFontSize: 20.0,
        tabletFontSize: 22.0,
        desktopFontSize: 24.0,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimary,
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back,
          color: colorScheme.onPrimary,
          size: context.responsive(
            mobile: 20.0,
            tablet: 22.0,
            desktop: 24.0,
          ),
        ),
        tooltip: 'Back',
        padding: EdgeInsets.all(
          context.responsive(
            mobile: 8.0,
            tablet: 10.0,
            desktop: 12.0,
          ),
        ),
        constraints: BoxConstraints(
          minWidth: context.responsive(
            mobile: 40.0,
            tablet: 44.0,
            desktop: 48.0,
          ),
          minHeight: context.responsive(
            mobile: 40.0,
            tablet: 44.0,
            desktop: 48.0,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildResponsiveAppBar(colorScheme),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary,
              colorScheme.surface,
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
            color: colorScheme.secondaryContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withOpacity(0.15),
                blurRadius: 25,
                offset: const Offset(0, -8),
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Section
                        _buildImageSection(),

                        // Basic Information
                        Text(
                          'Basic Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildInfoCard(
                          title: 'Item Name',
                          value: item.name,
                          icon: Icons.inventory_2_outlined,
                        ),

                        _buildInfoCard(
                          title: 'Category',
                          value: item.categoryName,
                          icon: Icons.category_outlined,
                        ),

                        _buildInfoCard(
                          title: 'Available Quantity',
                          value: '${item.availableQuantity} ${item.unit}',
                          icon: Icons.inventory_outlined,
                        ),

                        if (item.totalStock != null)
                          _buildInfoCard(
                            title: 'Total Quantity',
                            value: '${item.totalStock} ${item.unit}',
                            icon: Icons.storage_outlined,
                          ),

                        if (item.storageLocation.isNotEmpty)
                          _buildInfoCard(
                            title: 'Storage Location',
                            value: item.storageLocation,
                            icon: Icons.location_on_outlined,
                          ),

                        if (item.notes.isNotEmpty)
                          _buildInfoCard(
                            title: 'Notes',
                            value: item.notes,
                            icon: Icons.note_outlined,
                          ),

                        // Category-specific information
                        if (_getCategorySpecificFields().isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            'Category Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ..._getCategorySpecificFields(),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getCategorySpecificFields() {
    List<Widget> fields = [];

    switch (categoryName) {
      case 'furniture':
        if (item.material?.isNotEmpty == true) {
          fields.add(_buildInfoCard(
            title: 'Material',
            value: item.material!,
            icon: Icons.chair_outlined,
          ));
        }
        if (item.dimensions?.isNotEmpty == true) {
          fields.add(_buildInfoCard(
            title: 'Dimensions',
            value: item.dimensions!,
            icon: Icons.straighten_outlined,
          ));
        }
        break;

      case 'fabric':
        if (item.fabricType?.isNotEmpty == true) {
          fields.add(_buildInfoCard(
            title: 'Fabric Type',
            value: item.fabricType!,
            icon: Icons.texture_outlined,
          ));
        }
        if (item.pattern?.isNotEmpty == true) {
          fields.add(_buildInfoCard(
            title: 'Pattern',
            value: item.pattern!,
            icon: Icons.pattern_outlined,
          ));
        }
        if (item.width != null) {
          fields.add(_buildInfoCard(
            title: 'Width',
            value: item.width!.toString(),
            icon: Icons.straighten_outlined,
          ));
        }
        if (item.length != null) {
          fields.add(_buildInfoCard(
            title: 'Length',
            value: item.length!.toString(),
            icon: Icons.straighten_outlined,
          ));
        }
        if (item.color?.isNotEmpty == true) {
          fields.add(_buildInfoCard(
            title: 'Color',
            value: item.color!,
            icon: Icons.palette_outlined,
          ));
        }
        break;

      case 'carpet':
        if (item.carpetType?.isNotEmpty == true) {
          fields.add(_buildInfoCard(
            title: 'Carpet Type',
            value: item.carpetType!,
            icon: Icons.home_outlined,
          ));
        }
        if (item.size?.isNotEmpty == true) {
          fields.add(_buildInfoCard(
            title: 'Size',
            value: item.size!,
            icon: Icons.straighten_outlined,
          ));
        }
        if (item.color?.isNotEmpty == true) {
          fields.add(_buildInfoCard(
            title: 'Color',
            value: item.color!,
            icon: Icons.palette_outlined,
          ));
        }
        break;

      case 'frame':
        if (item.frameType?.isNotEmpty == true) {
          fields.add(_buildInfoCard(
            title: 'Frame Type',
            value: item.frameType!,
            icon: Icons.crop_square_outlined,
          ));
        }
        if (item.setNumber?.isNotEmpty == true) {
          fields.add(_buildInfoCard(
            title: 'Set Number',
            value: item.setNumber!,
            icon: Icons.numbers_outlined,
          ));
        }
        if (item.specifications?.isNotEmpty == true) {
          fields.add(_buildInfoCard(
            title: 'Specifications',
            value: item.specifications!,
            icon: Icons.description_outlined,
          ));
        }
        break;

      case 'thermocol':
        if (item.thermocolType?.isNotEmpty == true) {
          fields.add(_buildInfoCard(
            title: 'Thermocol Type',
            value: item.thermocolType!,
            icon: Icons.crop_square_outlined,
          ));
        }
        if (item.density != null) {
          fields.add(_buildInfoCard(
            title: 'Density',
            value: item.density!.toString(),
            icon: Icons.scale_outlined,
          ));
        }
        break;
    }

    return fields;
  }
}
