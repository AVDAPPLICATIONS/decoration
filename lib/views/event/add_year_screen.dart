import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'event_details_screen.dart';
import '../../themes/app_theme.dart';
import '../../services/event_service.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../custom_widget/year_selection_dropdown.dart';

class AddYearScreen extends ConsumerStatefulWidget {
  final String eventName;
  final int templateId;
  const AddYearScreen(
      {Key? key, required this.eventName, required this.templateId})
      : super(key: key);

  @override
  ConsumerState<AddYearScreen> createState() => _AddYearScreenState();
}

class _AddYearScreenState extends ConsumerState<AddYearScreen> {
  String? _selectedYear;
  bool _isLoading = false;
  final List<String> _years = [
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
    '2027',
    '2028',
    '2029',
    '2030'
  ];

  Future<void> _saveYear() async {
    if (_selectedYear == null || _selectedYear!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a year.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Make direct API call to create year
      final response = await _createYearAPI(_selectedYear!);

      if (mounted) {
        final yearData = {
          'year': _selectedYear!,
          'createdYear': response, // Include API response data
        };

        // ref.read(yearsProvider(widget.eventName).notifier).addYear(yearData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Year created successfully!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Year: ${response['year_name']} (ID: ${response['id']})'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pop(context, yearData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Error creating year',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Details: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
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

  Future<Map<String, dynamic>> _createYearAPI(String yearName) async {
    const String apiUrl = '${apiBaseUrl}/api/years/create';

    try {
      print('Creating year: $yearName');
      print('API URL: $apiUrl');

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'year_name': yearName,
        }),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          print('Successfully created year: $responseData');
          return responseData;
        } catch (e) {
          throw Exception('Invalid JSON response: ${e.toString()}');
        }
      } else {
        // Handle HTTP error
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['error'] ?? 
              errorData['message'] ?? 
              'HTTP Error: ${response.statusCode}');
        } catch (e) {
          throw Exception('HTTP Error: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      print('Network error creating year: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add New Year',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, Colors.white],
            stops: [0.0, 1.0],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.primary.withOpacity(0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Add New Year',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                const Text(
                  'Enter the year to add',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Year Selection Label
                const Text(
                  'Select Year *',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Year Selection Dropdown
                YearSelectionDropdown(
                  selectedYear: _selectedYear,
                  onChanged: (year) {
                    setState(() {
                      _selectedYear = year;
                    });
                  },
                  years: _years,
                ),

                const SizedBox(height: 40),

                // Save Button
                Container(
                  width: double.infinity,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 25,
                        spreadRadius: 0,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveYear,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.save_alt,
                                  color: Colors.white,
                                  size: 26,
                                ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _isLoading ? 'Creating...' : 'Save Year',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
