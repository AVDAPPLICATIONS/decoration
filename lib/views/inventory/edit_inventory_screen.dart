import 'package:avd_decoration_application/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import '../../providers/inventory_provider.dart';
import '../custom_widget/custom_appbar.dart';

class EditInventoryPage extends ConsumerStatefulWidget {
  final String itemId;
  const EditInventoryPage({super.key, required this.itemId});

  @override
  ConsumerState<EditInventoryPage> createState() => _EditInventoryPageState();
}

class _EditInventoryPageState extends ConsumerState<EditInventoryPage> {
  final _formKey = GlobalKey<FormState>();
  late InventoryItem item;
  late String categoryName;

  // Controllers for all possible fields
  final nameCtrl = TextEditingController();
  final unitCtrl = TextEditingController();
  final storageLocationCtrl = TextEditingController();
  final notesCtrl = TextEditingController();
  final quantityCtrl = TextEditingController();
  final materialCtrl = TextEditingController();
  final dimensionsCtrl = TextEditingController();
  final fabricTypeCtrl = TextEditingController();
  final patternCtrl = TextEditingController();
  final widthCtrl = TextEditingController();
  final lengthCtrl = TextEditingController();
  final colorCtrl = TextEditingController();
  final carpetTypeCtrl = TextEditingController();
  final sizeCtrl = TextEditingController();
  final frameTypeCtrl = TextEditingController();
  final setNumberCtrl = TextEditingController();
  final specificationsCtrl = TextEditingController();
  final thermocolTypeCtrl = TextEditingController();
  final densityCtrl = TextEditingController();

  // Image handling
  Uint8List? imageBytes;
  String? imagePath;
  String? imageName;

  // Loading state
  bool _isLoading = false;

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
      _initializeFormFields();
    } catch (e) {
      print('Error initializing item: $e');
      // Show error and navigate back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading item: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        Navigator.of(context).pop();
      });
    }
  }

  void _initializeFormFields() {
    nameCtrl.text = item.name;
    unitCtrl.text = item.unit;
    storageLocationCtrl.text = item.storageLocation;
    notesCtrl.text = item.notes;
    quantityCtrl.text = item.availableQuantity.toString();

    // Set category-specific fields based on the item's category
    switch (categoryName) {
      case 'furniture':
        materialCtrl.text = item.material ?? '';
        dimensionsCtrl.text = item.dimensions ?? '';
        break;
      case 'fabric':
      case 'fabrics':
        fabricTypeCtrl.text = item.fabricType ?? '';
        patternCtrl.text = item.pattern ?? '';
        widthCtrl.text = item.width?.toString() ?? '';
        lengthCtrl.text = item.length?.toString() ?? '';
        colorCtrl.text = item.color ?? '';
        break;
      case 'carpet':
      case 'carpets':
        carpetTypeCtrl.text = item.carpetType ?? '';
        materialCtrl.text = item.material ?? '';
        sizeCtrl.text = item.size ?? '';
        break;
      case 'frame structure':
      case 'frame structures':
        frameTypeCtrl.text = item.frameType ?? '';
        materialCtrl.text = item.material ?? '';
        dimensionsCtrl.text = item.dimensions ?? '';
        break;
      case 'murti set':
      case 'murti sets':
        setNumberCtrl.text = item.setNumber ?? '';
        materialCtrl.text = item.material ?? '';
        dimensionsCtrl.text = item.dimensions ?? '';
        break;
      case 'stationery':
        specificationsCtrl.text = item.specifications ?? '';
        break;
      case 'thermocol':
      case 'thermocol material':
      case 'thermocol materials':
        thermocolTypeCtrl.text = item.thermocolType ?? '';
        dimensionsCtrl.text = item.dimensions ?? '';
        densityCtrl.text = item.density?.toString() ?? '';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: CustomAppBar(
        title: 'Edit ${item.categoryName} Item',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Main card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.04),
                  spreadRadius: 0,
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.edit,
                            color: colorScheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text('Update ${item.categoryName} Item',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._buildCategoryFields(),
                  const SizedBox(height: 16),
                  _buildImagePicker(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () {
                      if (_formKey.currentState?.validate() == true) {
                        _save();
                      }
                    },
              icon: const Icon(Icons.save),
              style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary),
              label: const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryFields() {
    switch (categoryName) {
      case 'furniture':
        return [
          _buildTextField('Furniture Name', nameCtrl, required: true),
          _buildTextField('Material', materialCtrl, required: true),
          _buildTextField(
              'Dimensions (e.g., 45cm x 45cm x 90cm)', dimensionsCtrl,
              required: true),
          _buildTextField('Unit (e.g., piece, set)', unitCtrl, required: true),
          _buildTextField('Notes', notesCtrl, maxLines: 3),
          _buildTextField('Storage Location', storageLocationCtrl,
              required: true),
          _buildTextField('Quantity Available', quantityCtrl,
              keyboardType: TextInputType.number, required: true),
        ];
      case 'fabric':
      case 'fabrics':
        return [
          _buildTextField('Fabric Name', nameCtrl, required: true),
          _buildTextField('Fabric Type', fabricTypeCtrl, required: true),
          _buildTextField('Pattern', patternCtrl, required: true),
          _buildTextField('Width', widthCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              required: true),
          _buildTextField('Length', lengthCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              required: true),
          _buildTextField('Color', colorCtrl, required: true),
          _buildTextField('Unit (e.g., meter, yard)', unitCtrl, required: true),
          _buildTextField('Storage Location', storageLocationCtrl,
              required: true),
          _buildTextField('Notes', notesCtrl, maxLines: 3),
          _buildTextField('Quantity Available', quantityCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              required: true),
        ];
      case 'carpet':
      case 'carpets':
        return [
          _buildTextField('Carpet Name', nameCtrl, required: true),
          _buildTextField('Unit (e.g., piece, set)', unitCtrl, required: true),
          _buildTextField('Storage Location', storageLocationCtrl,
              required: true),
          _buildTextField('Notes', notesCtrl, maxLines: 3),
          _buildTextField('Carpet Type', carpetTypeCtrl, required: true),
          _buildTextField('Material', materialCtrl, required: true),
          _buildTextField('Size', sizeCtrl, required: true),
          _buildTextField('Quantity Available', quantityCtrl,
              keyboardType: TextInputType.number, required: true),
        ];
      case 'frame structure':
      case 'frame structures':
        return [
          _buildTextField('Frame Structure Name', nameCtrl, required: true),
          _buildTextField('Unit (e.g., piece, set)', unitCtrl, required: true),
          _buildTextField('Storage Location', storageLocationCtrl,
              required: true),
          _buildTextField('Notes', notesCtrl, maxLines: 3),
          _buildTextField('Frame Type', frameTypeCtrl, required: true),
          _buildTextField('Material', materialCtrl, required: true),
          _buildTextField(
              'Dimensions (e.g., 3.5m x 2.8m x 0.6m)', dimensionsCtrl,
              required: true),
          _buildTextField('Quantity Available', quantityCtrl,
              keyboardType: TextInputType.number, required: true),
        ];
      case 'murti set':
      case 'murti sets':
        return [
          _buildTextField('Murti Set Name', nameCtrl, required: true),
          _buildTextField('Unit (e.g., set, piece)', unitCtrl, required: true),
          _buildTextField('Storage Location', storageLocationCtrl,
              required: true),
          _buildTextField('Notes', notesCtrl, maxLines: 3),
          _buildTextField('Set Number', setNumberCtrl, required: true),
          _buildTextField('Material', materialCtrl, required: true),
          _buildTextField('Dimensions (e.g., 8inch x 12inch)', dimensionsCtrl,
              required: true),
          _buildTextField('Quantity Available', quantityCtrl,
              keyboardType: TextInputType.number, required: true),
        ];
      case 'stationery':
        return [
          _buildTextField('Stationery Name', nameCtrl, required: true),
          _buildTextField('Unit (e.g., piece, set)', unitCtrl, required: true),
          _buildTextField('Storage Location', storageLocationCtrl,
              required: true),
          _buildTextField('Notes', notesCtrl, maxLines: 3),
          _buildTextField('Specifications', specificationsCtrl,
              maxLines: 3, required: true),
          _buildTextField('Quantity Available', quantityCtrl,
              keyboardType: TextInputType.number, required: true),
        ];
      case 'thermocol':
      case 'thermocol material':
      case 'thermocol materials':
        return [
          _buildTextField('Thermocol Material Name', nameCtrl, required: true),
          _buildTextField('Unit (e.g., set, piece)', unitCtrl, required: true),
          _buildTextField('Storage Location', storageLocationCtrl,
              required: true),
          _buildTextField('Notes', notesCtrl, maxLines: 3),
          _buildTextField('Thermocol Type', thermocolTypeCtrl, required: true),
          _buildTextField(
              'Dimensions (e.g., 70cm x 50cm x 12cm)', dimensionsCtrl,
              required: true),
          _buildTextField('Density', densityCtrl,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              required: true),
          _buildTextField('Quantity Available', quantityCtrl,
              keyboardType: TextInputType.number, required: true),
        ];
      default:
        return [
          _buildTextField('Item Name', nameCtrl, required: true),
          _buildTextField('Unit', unitCtrl, required: true),
          _buildTextField('Storage Location', storageLocationCtrl,
              required: true),
          _buildTextField('Notes', notesCtrl, maxLines: 3),
          _buildTextField('Quantity Available', quantityCtrl,
              keyboardType: TextInputType.number, required: true),
        ];
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool required = false,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colorScheme.primary),
          ),
          filled: true,
          fillColor: colorScheme.surface,
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Update Image (optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.image,
                  allowMultiple: false,
                  withData: false,
                  allowCompression: false,
                );

                if (result != null && result.files.isNotEmpty) {
                  final file = result.files.first;
                  setState(() {
                    imagePath = file.path;
                    imageName = file.name;
                    // Read bytes for preview if needed
                    if (file.bytes != null) {
                      imageBytes = file.bytes;
                    }
                  });
                }
              },
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 12),
            if (imagePath != null || item.itemImage != null)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    imagePath = null;
                    imageName = null;
                    imageBytes = null;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                ),
              ),
          ],
        ),
        if (imagePath != null || item.itemImage != null) ...[
          const SizedBox(height: 12),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imagePath != null
                  ? Image.file(File(imagePath!), fit: BoxFit.cover)
                  : item.itemImage != null
                      ? Image.network(
                          '$apiBaseUrl${item.itemImage}',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: colorScheme.surfaceVariant,
                              child: Icon(Icons.image, size: 50, color: colorScheme.onSurfaceVariant),
                            );
                          },
                        )
                      : Icon(Icons.image, size: 50, color: colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ],
    );
  }

  void _save() async {
    // Validate form first
    if (_formKey.currentState?.validate() != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all required fields'),
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Prepare form data based on category
      final formData = _prepareFormData();

      // Call appropriate update method based on category
      switch (categoryName) {
        case 'furniture':
          await ref.read(inventoryProvider.notifier).updateFurnitureItem(
                id: int.parse(item.id),
                name: formData['name'],
                material: formData['material'],
                dimensions: formData['dimensions'],
                unit: formData['unit'],
                notes: formData['notes'],
                storageLocation: formData['storage_location'],
                quantityAvailable: formData['quantity_available'],
                itemImagePath: imagePath,
                itemImageBytes: imageBytes,
                itemImageName: imageName,
              );
          break;
        case 'carpet':
        case 'carpets':
          await ref.read(inventoryProvider.notifier).updateCarpetItem(
                id: int.parse(item.id),
                name: formData['name'],
                unit: formData['unit'],
                storageLocation: formData['storage_location'],
                notes: formData['notes'],
                quantityAvailable: formData['quantity_available'],
                carpetType: formData['carpet_type'],
                material: formData['material'],
                size: formData['size'],
                itemImagePath: imagePath,
                itemImageBytes: imageBytes,
                itemImageName: imageName,
              );
          break;
        case 'fabric':
        case 'fabrics':
          await ref.read(inventoryProvider.notifier).updateFabricItem(
                id: int.parse(item.id),
                name: formData['name'],
                unit: formData['unit'],
                storageLocation: formData['storage_location'],
                notes: formData['notes'],
                quantityAvailable: formData['quantity_available'],
                fabricType: formData['fabric_type'],
                pattern: formData['pattern'],
                width: formData['width'],
                length: formData['length'],
                color: formData['color'],
                itemImagePath: imagePath,
                itemImageBytes: imageBytes,
                itemImageName: imageName,
              );
          break;
        case 'frame structure':
        case 'frame structures':
          await ref.read(inventoryProvider.notifier).updateFrameStructureItem(
                id: int.parse(item.id),
                name: formData['name'],
                unit: formData['unit'],
                storageLocation: formData['storage_location'],
                notes: formData['notes'],
                quantityAvailable: formData['quantity_available'],
                frameType: formData['frame_type'],
                material: formData['material'],
                dimensions: formData['dimensions'],
                itemImagePath: imagePath,
                itemImageBytes: imageBytes,
                itemImageName: imageName,
              );
          break;
        case 'thermocol':
        case 'thermocol material':
        case 'thermocol materials':
          await ref
              .read(inventoryProvider.notifier)
              .updateThermocolMaterialsItem(
                id: int.parse(item.id),
                name: formData['name'],
                unit: formData['unit'],
                storageLocation: formData['storage_location'],
                notes: formData['notes'],
                quantityAvailable: formData['quantity_available'],
                thermocolType: formData['thermocol_type'],
                density: formData['density'],
                dimensions: formData['dimensions'],
                itemImagePath: imagePath,
                itemImageBytes: imageBytes,
                itemImageName: imageName,
              );
          break;
        case 'murti set':
        case 'murti sets':
          await ref.read(inventoryProvider.notifier).updateMurtiSetsItem(
                id: int.parse(item.id),
                name: formData['name'],
                unit: formData['unit'],
                storageLocation: formData['storage_location'],
                notes: formData['notes'],
                quantityAvailable: formData['quantity_available'],
                setNumber: formData['set_number'],
                material: formData['material'],
                dimensions: formData['dimensions'],
                itemImagePath: imagePath,
                itemImageBytes: imageBytes,
                itemImageName: imageName,
              );
          break;
        case 'stationery':
          await ref.read(inventoryProvider.notifier).updateStationeryItem(
                id: int.parse(item.id),
                name: formData['name'],
                unit: formData['unit'],
                storageLocation: formData['storage_location'],
                notes: formData['notes'],
                quantityAvailable: formData['quantity_available'],
                specifications: formData['specifications'],
                itemImagePath: imagePath,
                itemImageBytes: imageBytes,
                itemImageName: imageName,
              );
          break;
        default:
          // For other categories, use general update method for now
          final updated = item.copyWith(
            name: formData['name'],
            unit: formData['unit'],
            storageLocation: formData['storage_location'],
            notes: formData['notes'],
            availableQuantity: formData['quantity_available'],
          );
          await ref
              .read(inventoryProvider.notifier)
              .updateItem(updated.id, updated.toMap());
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Item updated successfully'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Reset loading state
      setState(() {
        _isLoading = false;
      });

      // Show error message with more details
      String errorMessage = 'Error updating item';
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('validation')) {
        errorMessage = 'Validation error. Please check your input.';
      } else if (e.toString().contains('permission')) {
        errorMessage =
            'Permission denied. You may not have access to edit this item.';
      } else {
        errorMessage = 'Error updating item: ${e.toString()}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  Map<String, dynamic> _prepareFormData() {
    final data = {
      'name': nameCtrl.text.trim(),
      'unit': unitCtrl.text.trim(),
      'storage_location': storageLocationCtrl.text.trim(),
      'notes': notesCtrl.text.trim(),
      'quantity_available': double.tryParse(quantityCtrl.text.trim()) ?? 0.0,
    };

    // Add category-specific fields
    switch (categoryName) {
      case 'furniture':
        data['material'] = materialCtrl.text.trim();
        data['dimensions'] = dimensionsCtrl.text.trim();
        break;
      case 'fabric':
      case 'fabrics':
        data['fabric_type'] = fabricTypeCtrl.text.trim();
        data['pattern'] = patternCtrl.text.trim();
        data['width'] = double.tryParse(widthCtrl.text.trim()) ?? 0.0;
        data['length'] = double.tryParse(lengthCtrl.text.trim()) ?? 0.0;
        data['color'] = colorCtrl.text.trim();
        break;
      case 'carpet':
      case 'carpets':
        data['carpet_type'] = carpetTypeCtrl.text.trim();
        data['material'] = materialCtrl.text.trim();
        data['size'] = sizeCtrl.text.trim();
        break;
      case 'frame structure':
      case 'frame structures':
        data['frame_type'] = frameTypeCtrl.text.trim();
        data['material'] = materialCtrl.text.trim();
        data['dimensions'] = dimensionsCtrl.text.trim();
        break;
      case 'murti set':
      case 'murti sets':
        data['set_number'] = setNumberCtrl.text.trim();
        data['material'] = materialCtrl.text.trim();
        data['dimensions'] = dimensionsCtrl.text.trim();
        break;
      case 'stationery':
        data['specifications'] = specificationsCtrl.text.trim();
        break;
      case 'thermocol':
      case 'thermocol material':
      case 'thermocol materials':
        data['thermocol_type'] = thermocolTypeCtrl.text.trim();
        data['dimensions'] = dimensionsCtrl.text.trim();
        data['density'] = double.tryParse(densityCtrl.text.trim()) ?? 0.0;
        break;
    }

    return data;
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    unitCtrl.dispose();
    storageLocationCtrl.dispose();
    notesCtrl.dispose();
    quantityCtrl.dispose();
    materialCtrl.dispose();
    dimensionsCtrl.dispose();
    fabricTypeCtrl.dispose();
    patternCtrl.dispose();
    widthCtrl.dispose();
    lengthCtrl.dispose();
    colorCtrl.dispose();
    carpetTypeCtrl.dispose();
    sizeCtrl.dispose();
    frameTypeCtrl.dispose();
    setNumberCtrl.dispose();
    specificationsCtrl.dispose();
    thermocolTypeCtrl.dispose();
    densityCtrl.dispose();
    super.dispose();
  }
}
