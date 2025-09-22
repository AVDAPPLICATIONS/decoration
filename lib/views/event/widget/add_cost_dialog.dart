import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../../../utils/constants.dart';
import '../../../services/cost_service.dart';
import 'fullscreen_image_viewer.dart';

class AddCostDialog extends StatefulWidget {
  final int eventId;
  final VoidCallback onCostAdded;
  final Map<String, dynamic>? existingCost;

  const AddCostDialog({
    Key? key,
    required this.eventId,
    required this.onCostAdded,
    this.existingCost,
  }) : super(key: key);

  @override
  State<AddCostDialog> createState() => _AddCostDialogState();
}

class _AddCostDialogState extends State<AddCostDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  bool _isSubmitting = false;
  File? _selectedReceiptFile;
  DateTime _selectedDate = DateTime.now();
  
  // Validation states
  String? _descriptionError;
  String? _amountError;

  @override
  void initState() {
    super.initState();

    if (widget.existingCost != null) {
      // Editing existing cost
      _descriptionController.text = widget.existingCost!['description'] ?? '';
      _amountController.text = widget.existingCost!['amount'] ?? '';

      // Parse existing date
      final existingDate = widget.existingCost!['uploaded_at'];
      if (existingDate != null) {
        try {
          _selectedDate = DateTime.parse(existingDate);
          _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
        } catch (e) {
          _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
        }
      } else {
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      }
    } else {
      // Adding new cost
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
    }

    // Add listeners for real-time validation
    _descriptionController.addListener(_validateDescription);
    _amountController.addListener(_validateAmount);
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_validateDescription);
    _amountController.removeListener(_validateAmount);
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _validateDescription() {
    final text = _descriptionController.text.trim();
    setState(() {
      if (text.isEmpty) {
        _descriptionError = 'Please enter a description';
      } else {
        _descriptionError = null;
      }
    });
  }

  void _validateAmount() {
    final text = _amountController.text.trim();
    setState(() {
      if (text.isEmpty) {
        _amountError = 'Please enter an amount';
      } else {
        final amount = double.tryParse(text);
        if (amount == null || amount <= 0) {
          _amountError = 'Please enter a valid amount';
        } else {
          _amountError = null;
        }
      }
    });
  }

  void _validateAllFields() {
    _validateDescription();
    _validateAmount();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectReceiptFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedReceiptFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewExistingDocument(String documentUrl, String? documentType) {
    // Convert relative URL to full URL if needed
    String fullUrl = documentUrl;
    if (documentUrl.startsWith('/')) {
      fullUrl = '$apiBaseUrl$documentUrl';
    }

    if (documentType == 'pdf') {
      // For PDF, you might want to open in a web view or external app
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening PDF: $fullUrl'),
          backgroundColor: Colors.blue,
        ),
      );
      // TODO: Implement PDF viewer
    } else {
      // For images, show in full screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageViewer(
            imageUrl: fullUrl,
            title: 'Cost Receipt',
          ),
        ),
      );
    }
  }

  Future<void> _submitCost() async {
    // Validate all fields
    _validateAllFields();
    
    // Check if there are any validation errors
    if (_descriptionError != null || _amountError != null) {
      return; // Don't proceed if there are validation errors
    }

    // Parse amount since validation passed
    final amount = double.parse(_amountController.text.trim());

    setState(() {
      _isSubmitting = true;
    });

    try {
      final costService = CostService(apiBaseUrl);
      Map<String, dynamic> result;

      if (widget.existingCost != null) {
        // Update existing cost
        result = await costService.updateEventCostItem(
          costId: widget.existingCost!['id'],
          description: _descriptionController.text.trim(),
          amount: amount,
          document: _selectedReceiptFile,
        );
      } else {
        // Create new cost
        result = await costService.createEventCostItem(
          eventId: widget.eventId,
          description: _descriptionController.text.trim(),
          amount: amount,
          document: _selectedReceiptFile,
        );
      }

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ??
                (widget.existingCost != null
                    ? 'Cost updated successfully'
                    : 'Cost added successfully')),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
        widget.onCostAdded();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ??
                (widget.existingCost != null
                    ? 'Failed to update cost'
                    : 'Failed to add cost')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with plus icon and title
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    widget.existingCost != null ? 'Edit Cost' : 'Add New Cost',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description field
                    _buildInputField(
                      controller: _descriptionController,
                      icon: Icons.description,
                      label: 'Description *',
                      hintText: 'Enter cost description',
                      colorScheme: colorScheme,
                      errorText: _descriptionError,
                    ),

                    const SizedBox(height: 20),

                    // Amount field
                    _buildInputField(
                      controller: _amountController,
                      icon: Icons.currency_rupee,
                      label: 'Amount (Rs) *',
                      hintText: 'Enter amount',
                      keyboardType: TextInputType.number,
                      colorScheme: colorScheme,
                      errorText: _amountError,
                    ),

                    const SizedBox(height: 20),

                    // Receipt file section
                    _buildReceiptFileSection(),
                  ],
                ),
              ),
            ),

            // Bottom buttons
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitCost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  widget.existingCost != null
                                      ? 'Update'
                                      : 'Add',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    required String hintText,
    TextInputType? keyboardType,
    required ColorScheme colorScheme,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: Colors.grey[600]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey[300]!,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : Colors.grey[300]!,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: errorText != null ? Colors.red : colorScheme.primary,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReceiptFileSection() {
    final existingDocumentUrl = widget.existingCost?['document_url'];
    final existingDocumentType = widget.existingCost?['document_type'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description, color: Colors.grey[600]),
            const SizedBox(width: 8),
            const Text(
              'Receipt File (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Show existing document if available
        if (existingDocumentUrl != null && _selectedReceiptFile == null) ...[
          GestureDetector(
            onTap: () => _viewExistingDocument(
                existingDocumentUrl, existingDocumentType),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    existingDocumentType == 'pdf'
                        ? Icons.picture_as_pdf
                        : Icons.image,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Receipt',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to view',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.visibility,
                    color: Colors.blue,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Upload new file section
        GestureDetector(
          onTap: _selectReceiptFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.upload_file, color: Colors.grey[600]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedReceiptFile != null
                        ? _selectedReceiptFile!.path.split('/').last
                        : existingDocumentUrl != null
                            ? 'Replace Receipt File'
                            : 'Upload Receipt File',
                    style: TextStyle(
                      color: _selectedReceiptFile != null
                          ? Colors.black87
                          : Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                ),
                if (_selectedReceiptFile != null)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedReceiptFile = null;
                      });
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[500], size: 12),
            const SizedBox(width: 4),
            Text(
              'Supported: Images and PDFs',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
