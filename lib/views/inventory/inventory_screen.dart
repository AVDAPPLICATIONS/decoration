import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_inventory_screen.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart';
import '../../providers/inventory_provider.dart';
import '../../utils/snackbar_manager.dart';
import 'package:file_picker/file_picker.dart';

class InventoryFormPage extends ConsumerStatefulWidget {
  const InventoryFormPage({super.key});

  @override
  ConsumerState<InventoryFormPage> createState() => _InventoryFormPageState();
}

class _InventoryFormPageState extends ConsumerState<InventoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  DateTime? _lastSubmissionTime;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Clear any existing SnackBars when the form page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SnackBarManager.clearAll(context);
      }
    });
  }

  // Helper method for safe navigation
  void _safePop([dynamic result]) {
    if (mounted) {
      // Add a small delay to ensure Navigator state is stable
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          try {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(result);
            } else {
              // Use root navigator as fallback
              Navigator.of(context, rootNavigator: true).pop(result);
            }
          } catch (e) {
            print('Navigation error: $e');
            // If all else fails, just pop without result
            try {
              Navigator.of(context, rootNavigator: true).pop();
            } catch (e2) {
              print('Fallback navigation also failed: $e2');
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(inventoryFormNotifierProvider);
    final categories = ref.watch(categoryProvider);
    final categoryNotifier = ref.watch(categoryProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Inventory Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 20,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category Selection Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.shadow.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.category_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Select Category',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 130,
                    child: categoryNotifier.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : categoryNotifier.error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Error loading categories',
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextButton(
                                      onPressed: () =>
                                          categoryNotifier.refreshCategories(),
                                      child: const Text('Retry',
                                          style: TextStyle(fontSize: 10)),
                                    ),
                                  ],
                                ),
                              )
                            : categories.isEmpty
                                ? Center(
                                    child: Text(
                                      'No categories available',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant),
                                    ),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: categories.length,
                                    itemBuilder: (context, index) {
                                      final category = categories[index];
                                      final isSelected =
                                          formState.selectedCategory?.id ==
                                              category.id;

                                      return GestureDetector(
                                        onTap: () {
                                          ref
                                              .read(
                                                  inventoryFormNotifierProvider
                                                      .notifier)
                                              .selectCategory(category);
                                        },
                                        child: Container(
                                          width: 110,
                                          margin:
                                              const EdgeInsets.only(right: 16),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isSelected
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .outline,
                                              width: isSelected ? 2 : 1.5,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: isSelected
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.3)
                                                    : Colors.black
                                                        .withOpacity(0.06),
                                                spreadRadius: 0,
                                                blurRadius:
                                                    isSelected ? 20 : 10,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                _getCategoryIcon(category.name),
                                                style: const TextStyle(
                                                    fontSize: 36),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                category.name,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isSelected
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .surface
                                                      : Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            ),

            // Form Section
            if (formState.selectedCategory != null)
              _buildForm(formState.selectedCategory!)
            else
              _buildPlaceholder(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Select a category to start',
            style: TextStyle(
              fontSize: 20,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Choose from the categories above to fill out the inventory form.\nAll fields are optional - fill in what you know.',
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm(CategoryModel category) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(28),
      constraints: const BoxConstraints(maxHeight: double.infinity),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.04),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text(
                      _getCategoryIcon(category.name),
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Dynamic form fields based on category
              ..._buildCategoryFields(category),

              const SizedBox(height: 36),

              // Image picker
              _buildImagePicker(),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isSubmitting)
                      ? null
                      : () => _submitForm(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor:
                        Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                  child: (_isLoading || _isSubmitting)
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.onPrimary,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Creating...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.save_outlined,
                              size: 20,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Submit Inventory',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Category field builders (unchanged except colors in TextFields/Dropdowns)
  // Example for one:

  Widget _buildTextField({
    required String label,
    String? value,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLines,
    bool isOptional = true,
  }) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      decoration: InputDecoration(
        labelText: isOptional ? '$label (optional)' : label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  // Build size/dimensions field with dropdown for units
  Widget _buildSizeField({
    required String label,
    String? value,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    bool isOptional = true,
    // required TextInputType txttype
  }) {
    // Parse the current value to extract size and unit
    String initialSizeValue = '';
    String initialUnit = 'm'; // Default unit

    if (value != null && value.isNotEmpty) {
      final units = ['mm', 'cm', 'm', 'in', 'ft', 'Roll'];
      for (String unit in units) {
        if (value.endsWith(' $unit') || value.endsWith(unit)) {
          initialUnit = unit;
          initialSizeValue =
              value.replaceAll(' $unit', '').replaceAll(unit, '').trim();
          break;
        }
      }
      if (initialSizeValue.isEmpty) {
        initialSizeValue = value;
      }
    }

    return StatefulBuilder(
      builder: (context, setState) {
        // ✅ Keep values in the state
        String sizeValue = initialSizeValue;
        String selectedUnit = initialUnit;

        return Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                initialValue: sizeValue,
                // keyboardType: TextInputType.number,

                onChanged: (newValue) {
                  setState(() {
                    initialSizeValue = newValue;
                    sizeValue = newValue; // ✅ Also update the local variable
                  });
                  final combinedValue =
                  newValue.isNotEmpty ? '$newValue $selectedUnit' : '';
                  onChanged(combinedValue);
                  print('TextField → $combinedValue');
                },
                validator: validator,
                decoration: InputDecoration(
                  labelText: isOptional ? '$label (optional)' : label,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: selectedUnit,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedUnit = newValue;
                    });

                    // Use the current text field value (sizeValue) which is now properly updated
                    final numericPart = sizeValue.trim().split(' ').first;
                    final combinedValue =
                    numericPart.isNotEmpty ? '$numericPart $newValue' : newValue;

                    onChanged(combinedValue);
                    print('Dropdown → $combinedValue');
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Unit',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                ),
                items: const [
                  DropdownMenuItem(value: 'mm', child: Text('Millimeter (mm)')),
                  DropdownMenuItem(value: 'cm', child: Text('Centimeter (cm)')),
                  DropdownMenuItem(value: 'm', child: Text('Meter (m)')),
                  DropdownMenuItem(value: 'in', child: Text('Inch (in)')),
                  DropdownMenuItem(value: 'ft', child: Text('Foot (ft)')),
                  DropdownMenuItem(value: 'Roll', child: Text('Roll')),
                ],
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildThicknessDropdown() {
    return Consumer(
      builder: (context, ref, child) {
        final formState = ref.watch(inventoryFormNotifierProvider);
        final currentThickness =
            formState.thermocol.thickness?.toString() ?? '';

        return DropdownButtonFormField<String>(
          isExpanded: true,
          value: currentThickness.isNotEmpty ? currentThickness : null,
          onChanged: (String? newValue) {
            if (newValue != null) {
              // Extract numeric value from the selected option
              final numericValue =
                  double.tryParse(newValue.replaceAll(' mm', ''));
              ref
                  .read(inventoryFormNotifierProvider.notifier)
                  .updateThermocolData(thickness: numericValue);
            }
          },
          decoration: InputDecoration(
            labelText: 'Thickness',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: const [
            DropdownMenuItem(value: '10', child: Text('10 mm')),
            DropdownMenuItem(value: '15', child: Text('15 mm')),
            DropdownMenuItem(value: '20', child: Text('20 mm')),
            DropdownMenuItem(value: '25', child: Text('25 mm')),
            DropdownMenuItem(value: '35', child: Text('35 mm')),
            DropdownMenuItem(value: '50', child: Text('50 mm')),
          ],
        );
      },
    );
  }

  // Inside _InventoryFormPageState

  List<Widget> _buildCategoryFields(CategoryModel category) {
    switch (category.name.toLowerCase()) {
      case 'furniture':
        return [
          _buildTextField(
              label: "Furniture Name",
              isOptional: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Furniture name is required';
                }
                return null;
              },
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFurnitureData(name: value);
              }),
          const SizedBox(height: 16),
          _buildSizeField(
              label: "Dimensions (e.g., 45x45x90)",
              value:
                  ref.watch(inventoryFormNotifierProvider).furniture.dimensions,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFurnitureData(dimensions: value);
              }),
          const SizedBox(height: 16),
          _buildTextField(
              label: "Material",
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFurnitureData(material: value);
              }),
          const SizedBox(height: 16),
          _buildTextField(
              label: "Total Stock",
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFurnitureData(quantity: int.tryParse(value));
              }),
          const SizedBox(height: 16),
          _buildTextField(
              label: "Storage Location",
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFurnitureData(storageLocation: value);
              }),
          const SizedBox(height: 16),
          _buildTextField(
              label: "Notes",
              maxLines: 3,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFurnitureData(notes: value);
              }),
        ];

      case 'fabric':
      case 'fabrics':
        return [
          // 1. Fabric Name
          _buildTextField(
              label: "Fabric Name",
              isOptional: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Fabric name is required';
                }
                return null;
              },
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFabricData(name: value);
              }),
          const SizedBox(height: 16),
          // 2. Fabric Type
          _buildTextField(
              label: "Fabric Type",
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFabricData(type: value);
              }),
          const SizedBox(height: 16),
          // 3. Size (combining width and length)
          _buildSizeField(
              label: "Size (e.g., 1x2)",
              value: ref.watch(inventoryFormNotifierProvider).fabric.dimensions,
              onChanged: (value) {
                // Parse the size input to extract width and length

                final value1 = value;
                    ref.read(inventoryFormNotifierProvider.notifier)
                        .updateFabricData(dimensions:value1);

              }),
          const SizedBox(height: 16),
          // 4. Total Stock
          _buildTextField(
              label: "Total Stock",
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFabricData(stock: double.tryParse(value));
              }),
          const SizedBox(height: 16),
          // 5. Storage Location
          _buildTextField(
              label: "Storage Location",
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFabricData(storageLocation: value);
              }),
          const SizedBox(height: 16),
          // 6. Notes
          _buildTextField(
              label: "Notes",
              maxLines: 3,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFabricData(notes: value);
              }),
        ];

      case 'frame structure':
      case 'frame structures':
        return [
          // 1. Frame Structures Name
          _buildTextField(
              label: "Frame Structures Name",
              isOptional: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Frame structures name is required';
                }
                return null;
              },
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFrameData(name: value);
              }),
          const SizedBox(height: 16),
          // 2. Frame Type
          _buildTextField(
              label: "Frame Type",
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFrameData(type: value);
              }),
          const SizedBox(height: 16),
          // 3. Dimensions
          _buildSizeField(
              label: "Dimensions (e.g., 1x2)",
              value: ref.watch(inventoryFormNotifierProvider).frame.dimensions,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFrameData(dimensions: value);
              }),
          const SizedBox(height: 16),
          // 4. Quantity
          _buildTextField(
              label: "Total Stock",
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFrameData(quantity: int.tryParse(value));
              }),
          const SizedBox(height: 16),
          // 5. Storage Location
          _buildTextField(
              label: "Storage Location",
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFrameData(storageLocation: value);
              }),
          const SizedBox(height: 16),
          // 6. Notes
          _buildTextField(
              label: "Notes",
              maxLines: 3,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFrameData(notes: value);
              }),
        ];

      case 'carpet':
      case 'carpets':
        return [
          // 1. Carpet Name
          _buildTextField(
              label: "Carpet Name",
              isOptional: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Carpet name is required';
                }
                return null;
              },
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateCarpetData(name: value);
              }),
          const SizedBox(height: 16),
          // 2. Size
          _buildSizeField(
              label: "Size (e.g., 4x3)",

              value: ref.watch(inventoryFormNotifierProvider).carpet.size,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateCarpetData(size: value);
              }),
          const SizedBox(height: 16),
          // 3. Quantity
          _buildTextField(
              label: "Total Stock",
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateCarpetData(stock: int.tryParse(value));
              }),
          const SizedBox(height: 16),
          // 4. Storage Location
          _buildTextField(
              label: "Storage Location",
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateCarpetData(storageLocation: value);
              }),
          const SizedBox(height: 16),
          // 5. Notes
          _buildTextField(
              label: "Notes",
              maxLines: 3,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateCarpetData(notes: value);
              }),
        ];

      case 'thermocol':
      case 'thermocol material':
      case 'thermocol materials':
        return [
          // 1. Name
          _buildTextField(
              label: "Thermocol Material Name",
              isOptional: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Thermocol material name is required';
                }
                return null;
              },
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateThermocolData(name: value);
              }),
          const SizedBox(height: 16),
          // 2. Dimensions
          _buildSizeField(
              label: "Dimensions (e.g., 70x50x12)",
              value: ref.watch(inventoryFormNotifierProvider).thermocol.dimensions,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateThermocolData(dimensions: value);
              }),
          const SizedBox(height: 16),
          // 3. Quantity
          _buildTextField(
              label: "Total Stock",
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateThermocolData(quantity: int.tryParse(value));
              }),
          const SizedBox(height: 16),
          // 4. Thickness
          _buildThicknessDropdown(),
          const SizedBox(height: 16),
          // 5. Density
          _buildTextField(
              label: "Density",
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateThermocolData(density: double.tryParse(value));
              }),
          const SizedBox(height: 16),
          // 6. Storage Location
          _buildTextField(
              label: "Storage Location",
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateThermocolData(storageLocation: value);
              }),
          const SizedBox(height: 16),
          // 7. Notes
          _buildTextField(
              label: "Notes",
              maxLines: 3,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateThermocolData(notes: value);
              }),
        ];

      case 'stationery':
        return [
          // 1. Stationery Name
          _buildTextField(
              label: "Stationery Name",
              isOptional: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Stationery name is required';
                }
                return null;
              },
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateStationeryData(name: value);
              }),
          const SizedBox(height: 16),
          // 2. Quantity
          _buildTextField(
              label: "Total Stock",
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateStationeryData(quantity: int.tryParse(value));
              }),
          const SizedBox(height: 16),
          // 3. Specifications
          _buildTextField(
              label: "Specifications",
              maxLines: 3,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateStationeryData(specifications: value);
              }),
          const SizedBox(height: 16),
          // 4. Storage Location
          _buildTextField(
              label: "Storage Location",
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateStationeryData(storageLocation: value);
              }),
          const SizedBox(height: 16),
          // 5. Notes
          _buildTextField(
              label: "Notes",
              maxLines: 3,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateStationeryData(notes: value);
              }),
        ];

      case 'murti set':
      case 'murti sets':
        return [
          // 1. Murti Set Name
          _buildTextField(
              label: "Murti Set Name",
              isOptional: false,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Murti set name is required';
                }
                return null;
              },
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateMurtiData(name: value);
              }),
          const SizedBox(height: 16),
          // 2. Dimensions
          _buildSizeField(
              label: "Dimensions (e.g., 8x12)",
              value: ref.watch(inventoryFormNotifierProvider).murti.dimensions,
              onChanged: (value) {
                print('Murti dimensions changed: $value');
                ref.read(inventoryFormNotifierProvider.notifier)
                    .updateMurtiData(dimensions: value);
              }),
          const SizedBox(height: 16),
          // 3. Set Number
          _buildTextField(
              label: "Set Number",
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateMurtiData(setNumber: value);
              }),
          const SizedBox(height: 16),
          // 4. Quantity
          _buildTextField(
              label: "Total Stock",
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateMurtiData(quantity: int.tryParse(value));
              }),
          const SizedBox(height: 16),
          // 5. Material
          _buildTextField(
              label: "Material",
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateMurtiData(material: value);
              }),
          const SizedBox(height: 16),
          // 6. Storage Location
          _buildTextField(
              label: "Storage Location",
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateMurtiData(storageLocation: value);
              }),
          const SizedBox(height: 16),
          // 7. Notes
          _buildTextField(
              label: "Notes",
              maxLines: 3,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateMurtiData(notes: value);
              }),
        ];

      default:
        // For any other category, use furniture fields as default
        return [
          _buildTextField(
              label: "Item Name",
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFurnitureData(name: value);
              }),
          const SizedBox(height: 16),
          _buildTextField(
              label: "Material",
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFurnitureData(material: value);
              }),
          const SizedBox(height: 16),
          _buildTextField(
              label: "Quantity",
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref
                    .read(inventoryFormNotifierProvider.notifier)
                    .updateFurnitureData(quantity: int.tryParse(value));
              }),
        ];
    }
  }

  // Helper method to get category icon
  String _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'furniture':
        return '🪑';
      case 'fabric':
      case 'fabrics':
        return '🧵';
      case 'frame structure':
        return '🖼';
      case 'carpet':
        return '🟫';
      case 'thermocol':
      case 'thermocol material':
        return '📦';
      case 'stationery':
        return '✏';
      case 'murti set':
        return '🙏';
      default:
        return '📦'; // Default icon
    }
  }

  Widget _buildLoadingDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular progress indicator
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Loading text
            Text(
              'Creating Inventory Item...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              'Please wait while we process your request',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    final formState = ref.watch(inventoryFormNotifierProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attach Image (optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
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
                  withData: false, // Don't load bytes, just get file path
                  allowCompression: false, // Don't compress the image
                );
                if (result != null && result.files.single.path != null) {
                  final file = File(result.files.single.path!);
                  print(
                      '🔍 Debug: Selected file path: ${result.files.single.path}');
                  print('🔍 Debug: File name: ${result.files.single.name}');
                  print('🔍 Debug: File exists: ${await file.exists()}');

                  if (await file.exists()) {
                    // Read bytes from the file
                    final bytes = await file.readAsBytes();
                    print('🔍 Debug: File size: ${bytes.length} bytes');
                    ref.read(inventoryFormNotifierProvider.notifier).setImage(
                          bytes: bytes,
                          name: result.files.single.name,
                          path: result.files.single.path,
                        );
                    print(
                        '✅ Image selected and stored: ${result.files.single.path}');
                  } else {
                    print(
                        '❌ Selected file does not exist: ${result.files.single.path}');
                    // Try to get bytes directly as fallback
                    if (result.files.single.bytes != null) {
                      print('🔍 Debug: Using bytes directly as fallback');
                      ref.read(inventoryFormNotifierProvider.notifier).setImage(
                            bytes: result.files.single.bytes!,
                            name: result.files.single.name,
                            path: null, // No path available
                          );
                      print('✅ Image selected using bytes fallback');
                    } else {
                      print('❌ No bytes available either');
                    }
                  }
                } else {
                  print('❌ No file selected or path is null');
                }
              },
              icon: const Icon(Icons.attach_file),
              label: const Text('Choose Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (formState.imageName != null)
              Expanded(
                child: Text(
                  formState.imageName!,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            if (formState.imageBytes != null)
              IconButton(
                tooltip: 'Remove',
                onPressed: () {
                  ref.read(inventoryFormNotifierProvider.notifier).clearImage();
                },
                icon: Icon(Icons.close,
                    color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
        if (formState.imageBytes != null) ...[
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              formState.imageBytes!,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  void _submitForm() async {
    print('Form submission started');

    // Prevent multiple simultaneous submissions
    if (_isSubmitting || _isLoading) {
      print('Submission blocked: already submitting');
      return;
    }

    // Prevent rapid successive submissions (increased to 3 seconds for better UX)
    final now = DateTime.now();
    if (_lastSubmissionTime != null &&
        now.difference(_lastSubmissionTime!).inSeconds < 3) {
      print('Submission blocked: too soon after last submission');
      // Show a brief message to user
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          SnackBarManager.showWarning(
            context: context,
            message: 'Please wait before submitting again',
            duration: const Duration(seconds: 2),
          );
        }
      });
      return;
    }

    _isSubmitting = true;
    _lastSubmissionTime = now;

    try {
      if (_formKey.currentState!.validate()) {
        print('Form validation passed');
        final notifier = ref.read(inventoryFormNotifierProvider.notifier);

        if (notifier.validateForm()) {
          print('Business validation passed');

          // Set loading state
          setState(() {
            _isLoading = true;
          });

          // Prepare data for API
          final formData = _prepareFormData();
          print('Form data prepared: $formData');
          print('🔍 Debug: Image path in form data: ${formData['imagePath']}');

          try {
            // Test API connection first
            print('🔍 Testing API connection before creating item...');
            final isConnected =
                await ref.read(inventoryProvider.notifier).testApiConnection();
            if (!isConnected) {
              throw Exception(
                  'Cannot connect to server. Please check your internet connection and try again.');
            }
            print('✅ API connection test passed');

            // Show loading dialog with progress indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => _buildLoadingDialog(context),
            );

            // Check if this is a furniture, fabric, carpet, or frame structures category and use appropriate API
            final category =
                ref.read(inventoryFormNotifierProvider).selectedCategory;
            if (category?.name.toLowerCase() == 'furniture') {
              // Use furniture-specific API
              await ref.read(inventoryProvider.notifier).createFurnitureItem(
                    name: formData['name'],
                    material: formData['material'],
                    dimensions: formData['dimensions'],
                    notes: formData['notes'],
                    storageLocation: formData['storage_location'],
                    quantityAvailable: formData['quantity_available'],
                    itemImagePath: formData['imagePath'],
                    itemImageBytes: formData['imageBytes'],
                    itemImageName: formData['imageName'],
                  );
            } else if (category?.name.toLowerCase() == 'fabric' ||
                category?.name.toLowerCase() == 'fabrics') {
              // Use fabric-specific API
              await ref.read(inventoryProvider.notifier).createFabricItem(
                    name: formData['name'],
                    fabricType: formData['fabric_type'],
                    size: formData['size'],
                    storageLocation: formData['storage_location'],
                    notes: formData['notes'],
                    quantityAvailable: formData['quantity_available'],
                    itemImagePath: formData['imagePath'],
                    itemImageBytes: formData['imageBytes'],
                    itemImageName: formData['imageName'],
                  );
            } else if (category?.name.toLowerCase() == 'carpet' ||
                category?.name.toLowerCase() == 'carpets') {
              // Use carpet-specific API
              await ref.read(inventoryProvider.notifier).createCarpetItem(
                    name: formData['name'],
                    size: formData['size'],
                    storageLocation: formData['storage_location'],
                    notes: formData['notes'],
                    quantityAvailable: formData['quantity_available'],
                    itemImagePath: formData['imagePath'],
                    itemImageBytes: formData['imageBytes'],
                    itemImageName: formData['imageName'],
                  );
            } else if (category?.name.toLowerCase() == 'frame structure' ||
                category?.name.toLowerCase() == 'frame structures') {
              // Use frame structures-specific API
              await ref
                  .read(inventoryProvider.notifier)
                  .createFrameStructureItem(
                    name: formData['name'],
                    frameType: formData['frame_type'],
                    dimensions: formData['dimensions'],
                    storageLocation: formData['storage_location'],
                    notes: formData['notes'],
                    quantityAvailable: formData['quantity_available'],
                    itemImagePath: formData['imagePath'],
                    itemImageBytes: formData['imageBytes'],
                    itemImageName: formData['imageName'],
                  );
            } else if (category?.name.toLowerCase() == 'murti set' ||
                category?.name.toLowerCase() == 'murti sets') {
              // Use murti sets-specific API
              print('murti set dimension ${formData['dimensions']}');
              print('murti data  ${formData}');
              await ref.read(inventoryProvider.notifier).createMurtiSetsItem(
                    name: formData['name'],
                    setNumber: formData['set_number'],
                    material: formData['material'],
                    dimensions: formData['dimensions'],
                    storageLocation: formData['storage_location'],
                    notes: formData['notes'],
                    quantityAvailable: formData['quantity_available'],
                    itemImagePath: formData['imagePath'],
                    itemImageBytes: formData['imageBytes'],
                    itemImageName: formData['imageName'],
                  );
            } else if (category?.name.toLowerCase() == 'thermocol' ||
                category?.name.toLowerCase() == 'thermocol material' ||
                category?.name.toLowerCase() == 'thermocol materials') {
              // Use thermocol materials-specific API
              await ref
                  .read(inventoryProvider.notifier)
                  .createThermocolMaterialsItem(
                    name: formData['name'],
                    thermocolType: formData['thermocol_type'],
                    dimensions: formData['dimensions'],
                    thickness: formData['thickness'],
                    density: formData['density'],
                    storageLocation: formData['storage_location'],
                    notes: formData['notes'],
                    quantityAvailable: formData['quantity_available'],
                    itemImagePath: formData['imagePath'],
                    itemImageBytes: formData['imageBytes'],
                    itemImageName: formData['imageName'],
                  );
            } else if (category?.name.toLowerCase() == 'stationery') {
              // Use stationery-specific API
              await ref.read(inventoryProvider.notifier).createStationeryItem(
                    name: formData['name'],
                    specifications: formData['specifications'],
                    storageLocation: formData['storage_location'],
                    notes: formData['notes'],
                    quantityAvailable: formData['quantity_available'],
                    itemImagePath: formData['imagePath'],
                    itemImageBytes: formData['imageBytes'],
                    itemImageName: formData['imageName'],
                  );
            } else {
              // Use general inventory API for other categories
              await ref.read(inventoryProvider.notifier).createItem(
                    name: formData['name'],
                    categoryId: category?.id ?? 1,
                    unit: formData['unit'],
                    storageLocation: formData['storage_location'],
                    notes: formData['notes'],
                    quantityAvailable: formData['quantity_available'],
                    itemImagePath: formData['imagePath'],
                    itemImageBytes: formData['imageBytes'],
                    itemImageName: formData['imageName'],
                    categoryDetails: formData['category_details'],
                  );
            }

            // Close loading dialog
            _safePop();

            // Reset loading state
            setState(() {
              _isLoading = false;
              _isSubmitting = false;
            });

            // Success message will be shown by the inventory list screen
            // after receiving the form result

            // Reset form
            ref.read(inventoryFormNotifierProvider.notifier).resetForm();

            // Refresh inventory data to clear any errors and update the list
            try {
              await ref.read(inventoryProvider.notifier).refreshInventoryData();
              print('✅ Inventory data refreshed successfully');
            } catch (e) {
              print('⚠️ Warning: Could not refresh inventory data: $e');
            }

            // Navigate back with result data using safe navigation
            print('🔍 Debug: Navigating back with form data: $formData');
            _safePop({'success': true, 'data': formData});
          } catch (e) {
            // Close loading dialog
            _safePop();

            // Reset loading state
            setState(() {
              _isLoading = false;
              _isSubmitting = false;
            });

            // Show error message with a small delay to ensure UI is stable
            Future.delayed(const Duration(milliseconds: 100), () {
              if (mounted) {
                SnackBarManager.showError(
                  context: context,
                  message: 'Error creating item: ${e.toString()}',
                );
              }
            });

            // Don't navigate back on error, let user fix the form
          }
        } else {
          print('Business validation failed');
          // Show error message with a small delay to ensure UI is stable
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              SnackBarManager.showError(
                context: context,
                message:
                    'Please select a category and fill in at least one field',
              );
            }
          });
        }
      } else {
        print('Form validation failed');
      }
    } catch (e) {
      print('Unexpected error during form submission: $e');
      // Show error message with a small delay to ensure UI is stable
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          SnackBarManager.showError(
            context: context,
            message: 'An unexpected error occurred. Please try again.',
          );
        }
      });
    } finally {
      // Always reset submitting state
      _isSubmitting = false;
    }
  }

  Map<String, dynamic> _prepareFormData() {
    final formState = ref.read(inventoryFormNotifierProvider);
    final category = formState.selectedCategory;

    Map<String, dynamic> data = {
      'name': '',
      'category_id': category?.id ?? 1,
      'unit': 'piece', // Default unit
      'storage_location': formState.location ?? 'Unknown',
      'notes': '',
      'quantity_available': 0.0,
      'category_details': {},
      'dimensions': 'size',
      'imagePath': formState.imagePath,
      'imageBytes': formState.imageBytes,
      'imageName': formState.imageName,
    };

    switch (category?.name.toLowerCase()) {
      case 'furniture':
        data['name'] = formState.furniture.name ?? 'Unknown';
        data['material'] = formState.furniture.material ?? 'Unknown';
        data['dimensions'] = formState.furniture.dimensions ?? 'Unknown';
        data['unit'] = formState.furniture.unit ?? 'piece';
        data['notes'] = formState.furniture.notes ?? 'Furniture item';
        data['storage_location'] =
            formState.furniture.storageLocation ?? 'Unknown';
        data['quantity_available'] =
            (formState.furniture.quantity ?? 1).toDouble();
        // Also keep category_details for general API compatibility
        data['category_details'] = {
          'material': formState.furniture.material ?? 'Unknown',
          'dimensions': formState.furniture.dimensions ?? 'Unknown',
        };
        print('🔍 Debug Furniture Form Data:');
        print('  - Name: ${formState.furniture.name}');
        print('  - Material: ${formState.furniture.material}');
        print('  - Dimensions: ${formState.furniture.dimensions}');
        print('  - Unit: ${formState.furniture.unit}');
        print('  - Notes: ${formState.furniture.notes}');
        print('  - Storage Location: ${formState.furniture.storageLocation}');
        print('  - Quantity: ${formState.furniture.quantity}');
        break;
      case 'fabric':
      case 'fabrics':
        data['name'] = formState.fabric.name ?? 'Unknown';
        data['fabric_type'] = formState.fabric.type ?? 'Unknown';
        // Combine width and length into size field as per API specification

        // data['size'] = '${width}x${length}';
        data['size'] = formState.fabric.dimensions ?? '0x0 m';

        data['storage_location'] =
            formState.fabric.storageLocation ?? 'Unknown';
        data['notes'] = formState.fabric.notes ?? 'Fabric item';
        data['quantity_available'] = formState.fabric.stock ?? 0.0;
        // Also keep category_details for general API compatibility
        data['category_details'] = {
          'fabric_type': formState.fabric.type ?? 'Unknown',
          'pattern': formState.fabric.pattern ?? 'Unknown',
          'dimensions':formState.fabric.dimensions ?? '0x0 m',
          'color': formState.fabric.color ?? 'Unknown',
        };
        break;
      case 'frame structure':
      case 'frame structures':
        data['name'] = formState.frame.name ?? 'Unknown';
        data['frame_type'] = formState.frame.type ?? 'Unknown';
        data['dimensions'] = formState.frame.dimensions ?? 'Unknown';
        data['storage_location'] = formState.frame.storageLocation ?? 'Unknown';
        data['notes'] = formState.frame.notes ?? 'Frame structure';
        data['quantity_available'] = (formState.frame.quantity ?? 1).toDouble();
        // Also keep category_details for general API compatibility
        data['category_details'] = {
          'frame_type': formState.frame.type ?? 'Unknown',
          'material': formState.frame.material ?? 'Unknown',
          'dimensions': formState.frame.dimensions ?? 'Unknown',
        };
        break;
      case 'carpet':
      case 'carpets':
        data['name'] = formState.carpet.name ?? 'Unknown';
        data['size'] = formState.carpet.size ?? 'Unknown';
        data['storage_location'] =
            formState.carpet.storageLocation ?? 'Unknown';
        data['notes'] = formState.carpet.notes ?? 'Carpet item';
        data['quantity_available'] = (formState.carpet.stock ?? 1).toDouble();
        print('🔍 Debug Carpet Form Data:');
        print('  - Name: ${formState.carpet.name}');
        print('  - Size: ${formState.carpet.size}');
        print('  - Storage Location: ${formState.carpet.storageLocation}');
        print('  - Notes: ${formState.carpet.notes}');
        print('  - Stock: ${formState.carpet.stock}');
        break;
      case 'thermocol':
      case 'thermocol material':
      case 'thermocol materials':
        data['name'] = formState.thermocol.name ?? 'Unknown';
        data['thermocol_type'] = formState.thermocol.thermocolType ?? 'Unknown';
        data['dimensions'] = formState.thermocol.dimensions ?? 'Unknown';
        data['thickness'] = '${formState.thermocol.thickness ?? 1.0} inches';
        data['density'] = formState.thermocol.density ?? 1.0;
        data['storage_location'] =
            formState.thermocol.storageLocation ?? 'Unknown';
        data['notes'] = formState.thermocol.notes ?? 'Thermocol material';
        data['quantity_available'] =
            (formState.thermocol.quantity ?? 1).toDouble();
        break;
      case 'stationery':
        data['name'] = formState.stationery.name ?? 'Unknown';
        data['specifications'] =
            formState.stationery.specifications ?? 'Unknown';
        data['storage_location'] =
            formState.stationery.storageLocation ?? 'Unknown';
        data['notes'] = formState.stationery.notes ?? 'Stationery item';
        data['quantity_available'] =
            (formState.stationery.quantity ?? 1).toDouble();
        break;
      case 'murti set':
      case 'murti sets':
        data['name'] = formState.murti.name ?? 'Unknown';
        data['set_number'] = formState.murti.setNumber ?? '1';
        data['material'] = formState.murti.material ?? 'Unknown';
        data['dimensions'] = formState.murti.dimensions ?? 'Unknown';
        data['storage_location'] = formState.murti.storageLocation ?? 'Unknown';
        data['notes'] = formState.murti.notes ?? 'Murti set';
        data['quantity_available'] = (formState.murti.quantity ?? 1).toDouble();
        break;
      default:
        data['name'] = formState.furniture.name ?? 'Unknown';
        data['unit'] = 'piece';
        data['notes'] = 'Item';
        data['quantity_available'] =
            (formState.furniture.quantity ?? 1).toDouble();
        data['category_details'] = {
          'material': formState.furniture.material ?? 'Unknown',
          'dimensions': formState.furniture.dimensions ?? 'Unknown',
        };
        break;
    }

    return data;
  }
}
