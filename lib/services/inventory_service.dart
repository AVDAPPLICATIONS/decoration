import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class InventoryService {
  final String baseUrl;

  InventoryService(this.baseUrl);

  // Helper method to safely parse JSON response
  Map<String, dynamic> _parseJsonResponse(
      http.Response response, String operation) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      print('❌ Error parsing JSON response for $operation: $e');
      print('❌ Status code: ${response.statusCode}');
      print('❌ Response body: ${response.body}');

      // If JSON parsing fails, it's likely HTML (404, 500 error page)
      String errorMessage = 'Server error (${response.statusCode})';
      if (response.statusCode == 404) {
        errorMessage =
            'API endpoint not found. Please check server configuration.';
      } else if (response.statusCode == 500) {
        errorMessage = 'Internal server error. Please try again later.';
      } else if (response.statusCode == 401) {
        errorMessage = 'Authentication required. Please login again.';
      } else if (response.statusCode == 403) {
        errorMessage =
            'Access denied. You do not have permission to perform this action.';
      }

      throw Exception(errorMessage);
    }
  }

  // Helper method to get full image URL
  String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return '$baseUrl$imagePath';
  }

  // Test API connection
  Future<bool> testConnection() async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/inventory/categories/getAll'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({}),
          )
          .timeout(const Duration(seconds: 10));

      print('🔍 API Connection Test: Status ${response.statusCode}');
      print(
          '🔍 API Connection Test: Response ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ API Connection Test Failed: $e');
      return false;
    }
  }

  // Get all inventory items
  Future<Map<String, dynamic>> getAllItems() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/inventory/items/getAll'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = _parseJsonResponse(response, 'getAllItems');
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to fetch inventory items');
      }
    } else {
      final errorData = _parseJsonResponse(response, 'getAllItems');
      throw Exception(
          errorData['message'] ?? 'Failed to fetch inventory items');
    }
  }

  // Get all categories
  Future<Map<String, dynamic>> getAllCategories() async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/inventory/categories/getAll'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = _parseJsonResponse(response, 'getAllCategories');
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to fetch categories');
      }
    } else {
      final errorData = _parseJsonResponse(response, 'getAllCategories');
      throw Exception(errorData['message'] ?? 'Failed to fetch categories');
    }
  }

  // Create new category
  Future<Map<String, dynamic>> createCategory(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/inventory/categories/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to create category');
        }
      } catch (e) {
        // If JSON parsing fails, it's likely HTML (server error page)
        throw Exception(
            'Server returned invalid response. Please check server configuration.');
      }
    } else {
      try {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create category');
      } catch (e) {
        // If JSON parsing fails, it's likely HTML (404, 500 error page)
        String errorMessage = 'Server error (${response.statusCode})';
        if (response.statusCode == 404) {
          errorMessage =
              'API endpoint not found. Please check server configuration.';
        } else if (response.statusCode == 500) {
          errorMessage = 'Internal server error. Please try again later.';
        } else if (response.statusCode == 401) {
          errorMessage = 'Authentication required. Please login again.';
        } else if (response.statusCode == 403) {
          errorMessage =
              'Access denied. You do not have permission to perform this action.';
        }
        throw Exception(errorMessage);
      }
    }
  }

  // Add new inventory item
  Future<Map<String, dynamic>> addItem(Map<String, dynamic> itemData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/inventory/items/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(itemData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to add inventory item');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to add inventory item');
    }
  }

  // Update inventory item
  Future<Map<String, dynamic>> updateItem(
      String itemId, Map<String, dynamic> itemData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/inventory/items/$itemId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(itemData),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to update inventory item');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          errorData['message'] ?? 'Failed to update inventory item');
    }
  }

  // Delete inventory item
  Future<Map<String, dynamic>> deleteItem(String itemId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/inventory/items/$itemId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] == true) {
        return responseData;
      } else {
        throw Exception(
            responseData['message'] ?? 'Failed to delete inventory item');
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(
          errorData['message'] ?? 'Failed to delete inventory item');
    }
  }

  // Create furniture item with specific API endpoint
  Future<Map<String, dynamic>> createFurnitureItem({
    required String name,
    required String material,
    required String dimensions,
    required String notes,
    required String storageLocation,
    required double quantityAvailable,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/furniture/create'),
      );

      // Add form fields
      request.fields['name'] = name;
      request.fields['material'] = material;
      request.fields['dimensions'] = dimensions;
      request.fields['notes'] = notes;
      request.fields['storage_location'] = storageLocation;
      request.fields['quantity_available'] = quantityAvailable.toString();

      // Add image file if provided
      print('🔍 Debug Furniture API: itemImage = $itemImage');
      print('🔍 Debug Furniture API: itemImagePath = $itemImagePath');
      print(
          '🔍 Debug Furniture API: itemImageBytes = ${itemImageBytes?.length} bytes');
      print('🔍 Debug Furniture API: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print('✅ Using itemImage file for furniture: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print(
            '🔍 Debug Furniture API: Checking if file exists: $itemImagePath');
        print(
            '🔍 Debug Furniture API: File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print('✅ Using itemImagePath file for furniture: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print('✅ MultipartFile created successfully for furniture');
          } catch (e) {
            print('❌ Error creating MultipartFile for furniture: $e');
          }
        } else {
          print('❌ File does not exist for furniture: $itemImagePath');
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print('🔍 Debug Furniture API: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print('✅ Created temporary file for furniture: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print('❌ Error creating temporary file from bytes for furniture: $e');
        }
      } else {
        print(
            '❌ No image provided for furniture - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print('🔍 Debug Furniture API: Request fields: ${request.fields}');
      print(
          '🔍 Debug Furniture API: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug Furniture API: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('🔍 Debug Furniture API: Response status: ${response.statusCode}');
      print('🔍 Debug Furniture API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData =
            _parseJsonResponse(response, 'createFurnitureItem');
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to create furniture item');
        }
      } else {
        final errorData = _parseJsonResponse(response, 'createFurnitureItem');
        throw Exception(
            errorData['message'] ?? 'Failed to create furniture item');
      }
    } catch (e) {
      print('❌ Furniture API Error: $e');
      rethrow;
    }
  }

  // Create murti sets item with specific API endpoint
  Future<Map<String, dynamic>> createMurtiSetsItem({
    required String name,
    required String setNumber,
    required String material,
    required String dimensions,
    required String storageLocation,
    required String notes,
    required double quantityAvailable,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/murti-sets/create'),
      );

      // Add form fields - only the fields required by the API
      request.fields['name'] = name;
      request.fields['set_number'] = setNumber;
      request.fields['material'] = material;
      request.fields['dimensions'] = dimensions;
      request.fields['storage_location'] = storageLocation;
      request.fields['notes'] = notes;
      request.fields['quantity_available'] = quantityAvailable.toString();

      // Add image file if provided
      print('🔍 Debug Murti Sets API: itemImage = $itemImage');
      print('🔍 Debug Murti Sets API: itemImagePath = $itemImagePath');
      print(
          '🔍 Debug Murti Sets API: itemImageBytes = ${itemImageBytes?.length} bytes');
      print('🔍 Debug Murti Sets API: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print('✅ Using itemImage file for murti sets: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print(
            '🔍 Debug Murti Sets API: Checking if file exists: $itemImagePath');
        print(
            '🔍 Debug Murti Sets API: File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print('✅ Using itemImagePath file for murti sets: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print('✅ MultipartFile created successfully for murti sets');
          } catch (e) {
            print('❌ Error creating MultipartFile for murti sets: $e');
          }
        } else {
          print('❌ File does not exist for murti sets: $itemImagePath');
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print('🔍 Debug Murti Sets API: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print('✅ Created temporary file for murti sets: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print(
              '❌ Error creating temporary file from bytes for murti sets: $e');
        }
      } else {
        print(
            '❌ No image provided for murti sets - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print('🔍 Debug Murti Sets API: Request fields: ${request.fields}');
      print(
          '🔍 Debug Murti Sets API: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug Murti Sets API: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('🔍 Debug Murti Sets API: Response status: ${response.statusCode}');
      print('🔍 Debug Murti Sets API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData =
            _parseJsonResponse(response, 'createMurtiSetsItem');
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to create murti sets item');
        }
      } else {
        final errorData = _parseJsonResponse(response, 'createMurtiSetsItem');
        throw Exception(
            errorData['message'] ?? 'Failed to create murti sets item');
      }
    } catch (e) {
      print('❌ Murti Sets API Error: $e');
      rethrow;
    }
  }

  // Create stationery item with specific API endpoint
  Future<Map<String, dynamic>> createStationeryItem({
    required String name,
    required String specifications,
    required String storageLocation,
    required String notes,
    required double quantityAvailable,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/stationery/create'),
      );

      // Add form fields - only the fields required by the API
      request.fields['name'] = name;
      request.fields['specifications'] = specifications;
      request.fields['storage_location'] = storageLocation;
      request.fields['notes'] = notes;
      request.fields['quantity_available'] = quantityAvailable.toString();

      // Add image file if provided
      print('🔍 Debug Stationery API: itemImage = $itemImage');
      print('🔍 Debug Stationery API: itemImagePath = $itemImagePath');
      print(
          '🔍 Debug Stationery API: itemImageBytes = ${itemImageBytes?.length} bytes');
      print('🔍 Debug Stationery API: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print('✅ Using itemImage file for stationery: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print(
            '🔍 Debug Stationery API: Checking if file exists: $itemImagePath');
        print(
            '🔍 Debug Stationery API: File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print('✅ Using itemImagePath file for stationery: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print('✅ MultipartFile created successfully for stationery');
          } catch (e) {
            print('❌ Error creating MultipartFile for stationery: $e');
          }
        } else {
          print('❌ File does not exist for stationery: $itemImagePath');
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print('🔍 Debug Stationery API: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print('✅ Created temporary file for stationery: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print(
              '❌ Error creating temporary file from bytes for stationery: $e');
        }
      } else {
        print(
            '❌ No image provided for stationery - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print('🔍 Debug Stationery API: Request fields: ${request.fields}');
      print(
          '🔍 Debug Stationery API: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug Stationery API: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('🔍 Debug Stationery API: Response status: ${response.statusCode}');
      print('🔍 Debug Stationery API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData =
            _parseJsonResponse(response, 'createStationeryItem');
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to create stationery item');
        }
      } else {
        final errorData = _parseJsonResponse(response, 'createStationeryItem');
        throw Exception(
            errorData['message'] ?? 'Failed to create stationery item');
      }
    } catch (e) {
      print('❌ Stationery API Error: $e');
      rethrow;
    }
  }

  // Create thermocol materials item with specific API endpoint
  Future<Map<String, dynamic>> createThermocolMaterialsItem({
    required String name,
    required String thermocolType,
    required String dimensions,
    required String thickness,
    required double density,
    required String storageLocation,
    required String notes,
    required double quantityAvailable,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/thermocol-materials/create'),
      );

      // Add form fields - only the fields required by the API
      request.fields['name'] = name;
      request.fields['thermocol_type'] = thermocolType;
      request.fields['dimensions'] = dimensions;
      request.fields['thickness'] = thickness;
      request.fields['density'] = density.toString();
      request.fields['storage_location'] = storageLocation;
      request.fields['notes'] = notes;
      request.fields['quantity_available'] = quantityAvailable.toString();

      // Add image file if provided
      print('🔍 Debug Thermocol Materials API: itemImage = $itemImage');
      print('🔍 Debug Thermocol Materials API: itemImagePath = $itemImagePath');
      print(
          '🔍 Debug Thermocol Materials API: itemImageBytes = ${itemImageBytes?.length} bytes');
      print('🔍 Debug Thermocol Materials API: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print(
            '✅ Using itemImage file for thermocol materials: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print(
            '🔍 Debug Thermocol Materials API: Checking if file exists: $itemImagePath');
        print(
            '🔍 Debug Thermocol Materials API: File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print(
              '✅ Using itemImagePath file for thermocol materials: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print(
                '✅ MultipartFile created successfully for thermocol materials');
          } catch (e) {
            print('❌ Error creating MultipartFile for thermocol materials: $e');
          }
        } else {
          print(
              '❌ File does not exist for thermocol materials: $itemImagePath');
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print(
            '🔍 Debug Thermocol Materials API: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print(
              '✅ Created temporary file for thermocol materials: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print(
              '❌ Error creating temporary file from bytes for thermocol materials: $e');
        }
      } else {
        print(
            '❌ No image provided for thermocol materials - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print(
          '🔍 Debug Thermocol Materials API: Request fields: ${request.fields}');
      print(
          '🔍 Debug Thermocol Materials API: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug Thermocol Materials API: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(
          '🔍 Debug Thermocol Materials API: Response status: ${response.statusCode}');
      print(
          '🔍 Debug Thermocol Materials API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData =
            _parseJsonResponse(response, 'createThermocolMaterialsItem');
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ??
              'Failed to create thermocol materials item');
        }
      } else {
        final errorData =
            _parseJsonResponse(response, 'createThermocolMaterialsItem');
        throw Exception(errorData['message'] ??
            'Failed to create thermocol materials item');
      }
    } catch (e) {
      print('❌ Thermocol Materials API Error: $e');
      rethrow;
    }
  }

  // Update furniture item with specific API endpoint
  Future<Map<String, dynamic>> updateFurnitureItem({
    required int id,
    required String name,
    required String material,
    required String dimensions,
    required String notes,
    required String storageLocation,
    required double quantityAvailable,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/furniture/update'),
      );

      // Add form fields
      request.fields['id'] = id.toString();
      request.fields['name'] = name;
      request.fields['material'] = material;
      request.fields['dimensions'] = dimensions;
      request.fields['notes'] = notes;
      request.fields['storage_location'] = storageLocation;
      request.fields['quantity_available'] = quantityAvailable.toString();

      // Add image file if provided
      print('🔍 Debug Furniture Update API: itemImage = $itemImage');
      print('🔍 Debug Furniture Update API: itemImagePath = $itemImagePath');
      print(
          '🔍 Debug Furniture Update API: itemImageBytes = ${itemImageBytes?.length} bytes');
      print('🔍 Debug Furniture Update API: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print('✅ Using itemImage file for furniture update: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print(
            '🔍 Debug Furniture Update API: Checking if file exists: $itemImagePath');
        print(
            '🔍 Debug Furniture Update API: File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print(
              '✅ Using itemImagePath file for furniture update: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print('✅ MultipartFile created successfully for furniture update');
          } catch (e) {
            print('❌ Error creating MultipartFile for furniture update: $e');
          }
        } else {
          print('❌ File does not exist for furniture update: $itemImagePath');
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print(
            '🔍 Debug Furniture Update API: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print(
              '✅ Created temporary file for furniture update: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print(
              '❌ Error creating temporary file from bytes for furniture update: $e');
        }
      } else {
        print(
            '❌ No image provided for furniture update - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print('🔍 Debug Furniture Update API: Request fields: ${request.fields}');
      print(
          '🔍 Debug Furniture Update API: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug Furniture Update API: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(
          '🔍 Debug Furniture Update API: Response status: ${response.statusCode}');
      print('🔍 Debug Furniture Update API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to update furniture item');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to update furniture item');
      }
    } catch (e) {
      print('❌ Furniture Update API Error: $e');
      rethrow;
    }
  }

  // Update carpet item with specific API endpoint
  Future<Map<String, dynamic>> updateCarpetItem({
    required int id,
    required String name,
    required String storageLocation,
    required String notes,
    required double quantityAvailable,
    required String carpetType,
    required String material,
    required String size,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/carpets/update'),
      );

      // Add form fields
      request.fields['id'] = id.toString();
      request.fields['name'] = name;
      request.fields['storage_location'] = storageLocation;
      request.fields['notes'] = notes;
      request.fields['quantity_available'] = quantityAvailable.toString();
      request.fields['carpet_type'] = carpetType;
      request.fields['material'] = material;
      request.fields['size'] = size;

      // Add image file if provided
      print('🔍 Debug Carpet Update API: itemImage = $itemImage');
      print('🔍 Debug Carpet Update API: itemImagePath = $itemImagePath');
      print(
          '🔍 Debug Carpet Update API: itemImageBytes = ${itemImageBytes?.length} bytes');
      print('🔍 Debug Carpet Update API: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print('✅ Using itemImage file for carpet update: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print(
            '🔍 Debug Carpet Update API: Checking if file exists: $itemImagePath');
        print(
            '🔍 Debug Carpet Update API: File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print('✅ Using itemImagePath file for carpet update: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print('✅ MultipartFile created successfully for carpet update');
          } catch (e) {
            print('❌ Error creating MultipartFile for carpet update: $e');
          }
        } else {
          print('❌ File does not exist for carpet update: $itemImagePath');
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print('🔍 Debug Carpet Update API: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print('✅ Created temporary file for carpet update: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print(
              '❌ Error creating temporary file from bytes for carpet update: $e');
        }
      } else {
        print(
            '❌ No image provided for carpet update - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print('🔍 Debug Carpet Update API: Request fields: ${request.fields}');
      print(
          '🔍 Debug Carpet Update API: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug Carpet Update API: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(
          '🔍 Debug Carpet Update API: Response status: ${response.statusCode}');
      print('🔍 Debug Carpet Update API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to update carpet item');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update carpet item');
      }
    } catch (e) {
      print('❌ Carpet Update API Error: $e');
      rethrow;
    }
  }

  // Update fabric item with specific API endpoint
  Future<Map<String, dynamic>> updateFabricItem({
    required int id,
    required String name,
    required String fabricType,
    required String size,
    required String storageLocation,
    required String notes,
    required double quantityAvailable,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/fabric/update'),
      );

      // Add form fields as per API specification
      request.fields['id'] = id.toString();
      request.fields['name'] = name;
      request.fields['fabric_type'] = fabricType;
      request.fields['size'] = size;
      request.fields['storage_location'] = storageLocation;
      request.fields['notes'] = notes;
      request.fields['quantity_available'] = quantityAvailable.toString();

      // Add image file if provided
      print('🔍 Debug Fabric Update API: itemImage = $itemImage');
      print('🔍 Debug Fabric Update API: itemImagePath = $itemImagePath');
      print(
          '🔍 Debug Fabric Update API: itemImageBytes = ${itemImageBytes?.length} bytes');
      print('🔍 Debug Fabric Update API: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print('✅ Using itemImage file for fabric update: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print(
            '🔍 Debug Fabric Update API: Checking if file exists: $itemImagePath');
        print(
            '🔍 Debug Fabric Update API: File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print('✅ Using itemImagePath file for fabric update: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print('✅ MultipartFile created successfully for fabric update');
          } catch (e) {
            print('❌ Error creating MultipartFile for fabric update: $e');
          }
        } else {
          print('❌ File does not exist for fabric update: $itemImagePath');
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print('🔍 Debug Fabric Update API: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print('✅ Created temporary file for fabric update: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print(
              '❌ Error creating temporary file from bytes for fabric update: $e');
        }
      } else {
        print(
            '❌ No image provided for fabric update - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print('🔍 Debug Fabric Update API: Request fields: ${request.fields}');
      print(
          '🔍 Debug Fabric Update API: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug Fabric Update API: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(
          '🔍 Debug Fabric Update API: Response status: ${response.statusCode}');
      print('🔍 Debug Fabric Update API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = _parseJsonResponse(response, 'updateFabricItem');
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to update fabric item');
        }
      } else {
        final errorData = _parseJsonResponse(response, 'updateFabricItem');
        throw Exception(errorData['message'] ?? 'Failed to update fabric item');
      }
    } catch (e) {
      print('❌ Fabric Update API Error: $e');
      rethrow;
    }
  }

  // Update frame structure item with specific API endpoint
  Future<Map<String, dynamic>> updateFrameStructureItem({
    required int id,
    required String name,
    required String storageLocation,
    required String notes,
    required double quantityAvailable,
    required String frameType,
    required String material,
    required String dimensions,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/frame-structures/update'),
      );

      // Add form fields
      request.fields['id'] = id.toString();
      request.fields['name'] = name;
      request.fields['storage_location'] = storageLocation;
      request.fields['notes'] = notes;
      request.fields['quantity_available'] = quantityAvailable.toString();
      request.fields['frame_type'] = frameType;
      request.fields['material'] = material;
      request.fields['dimensions'] = dimensions;

      // Add image file if provided
      print('🔍 Debug Frame Structure Update API: itemImage = $itemImage');
      print(
          '🔍 Debug Frame Structure Update API: itemImagePath = $itemImagePath');
      print(
          '🔍 Debug Frame Structure Update API: itemImageBytes = ${itemImageBytes?.length} bytes');
      print(
          '🔍 Debug Frame Structure Update API: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print(
            '✅ Using itemImage file for frame structure update: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print(
            '🔍 Debug Frame Structure Update API: Checking if file exists: $itemImagePath');
        print(
            '🔍 Debug Frame Structure Update API: File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print(
              '✅ Using itemImagePath file for frame structure update: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print(
                '✅ MultipartFile created successfully for frame structure update');
          } catch (e) {
            print(
                '❌ Error creating MultipartFile for frame structure update: $e');
          }
        } else {
          print(
              '❌ File does not exist for frame structure update: $itemImagePath');
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print(
            '🔍 Debug Frame Structure Update API: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print(
              '✅ Created temporary file for frame structure update: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print(
              '❌ Error creating temporary file from bytes for frame structure update: $e');
        }
      } else {
        print(
            '❌ No image provided for frame structure update - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print(
          '🔍 Debug Frame Structure Update API: Request fields: ${request.fields}');
      print(
          '🔍 Debug Frame Structure Update API: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug Frame Structure Update API: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(
          '🔍 Debug Frame Structure Update API: Response status: ${response.statusCode}');
      print(
          '🔍 Debug Frame Structure Update API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ??
              'Failed to update frame structure item');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to update frame structure item');
      }
    } catch (e) {
      print('❌ Frame Structure Update API Error: $e');
      rethrow;
    }
  }

  // Update thermocol materials item with specific API endpoint
  Future<Map<String, dynamic>> updateThermocolMaterialsItem({
    required int id,
    required String name,
    required String storageLocation,
    required String notes,
    required double quantityAvailable,
    required String thermocolType,
    required double density,
    required String dimensions,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/thermocol-materials/update'),
      );

      // Add form fields
      request.fields['id'] = id.toString();
      request.fields['name'] = name;
      request.fields['storage_location'] = storageLocation;
      request.fields['notes'] = notes;
      request.fields['quantity_available'] = quantityAvailable.toString();
      request.fields['thermocol_type'] = thermocolType;
      request.fields['density'] = density.toString();
      request.fields['dimensions'] = dimensions;

      // Add image file if provided
      print('🔍 Debug Thermocol Materials Update API: itemImage = $itemImage');
      print(
          '🔍 Debug Thermocol Materials Update API: itemImagePath = $itemImagePath');
      print(
          '🔍 Debug Thermocol Materials Update API: itemImageBytes = ${itemImageBytes?.length} bytes');
      print(
          '🔍 Debug Thermocol Materials Update API: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print(
            '✅ Using itemImage file for thermocol materials update: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print(
            '🔍 Debug Thermocol Materials Update API: Checking if file exists: $itemImagePath');
        print(
            '🔍 Debug Thermocol Materials Update API: File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print(
              '✅ Using itemImagePath file for thermocol materials update: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print(
                '✅ MultipartFile created successfully for thermocol materials update');
          } catch (e) {
            print(
                '❌ Error creating MultipartFile for thermocol materials update: $e');
          }
        } else {
          print(
              '❌ File does not exist for thermocol materials update: $itemImagePath');
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print(
            '🔍 Debug Thermocol Materials Update API: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print(
              '✅ Created temporary file for thermocol materials update: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print(
              '❌ Error creating temporary file from bytes for thermocol materials update: $e');
        }
      } else {
        print(
            '❌ No image provided for thermocol materials update - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print(
          '🔍 Debug Thermocol Materials Update API: Request fields: ${request.fields}');
      print(
          '🔍 Debug Thermocol Materials Update API: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug Thermocol Materials Update API: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(
          '🔍 Debug Thermocol Materials Update API: Response status: ${response.statusCode}');
      print(
          '🔍 Debug Thermocol Materials Update API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ??
              'Failed to update thermocol materials item');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ??
            'Failed to update thermocol materials item');
      }
    } catch (e) {
      print('❌ Thermocol Materials Update API Error: $e');
      rethrow;
    }
  }

  // Update murti sets item with specific API endpoint
  Future<Map<String, dynamic>> updateMurtiSetsItem({
    required int id,
    required String name,
    required String storageLocation,
    required String notes,
    required double quantityAvailable,
    required String setNumber,
    required String material,
    required String dimensions,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/murti-sets/update'),
      );

      // Add form fields
      request.fields['id'] = id.toString();
      request.fields['name'] = name;
      request.fields['storage_location'] = storageLocation;
      request.fields['notes'] = notes;
      request.fields['quantity_available'] = quantityAvailable.toString();
      request.fields['set_number'] = setNumber;
      request.fields['material'] = material;
      request.fields['dimensions'] = dimensions;

      // Add image file if provided
      print('🔍 Debug Murti Sets Update API: itemImage = $itemImage');
      print('🔍 Debug Murti Sets Update API: itemImagePath = $itemImagePath');
      print(
          '🔍 Debug Murti Sets Update API: itemImageBytes = ${itemImageBytes?.length} bytes');
      print('🔍 Debug Murti Sets Update API: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print(
            '✅ Using itemImage file for murti sets update: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print(
            '🔍 Debug Murti Sets Update API: Checking if file exists: $itemImagePath');
        print(
            '🔍 Debug Murti Sets Update API: File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print(
              '✅ Using itemImagePath file for murti sets update: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print('✅ MultipartFile created successfully for murti sets update');
          } catch (e) {
            print('❌ Error creating MultipartFile for murti sets update: $e');
          }
        } else {
          print('❌ File does not exist for murti sets update: $itemImagePath');
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print(
            '🔍 Debug Murti Sets Update API: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print(
              '✅ Created temporary file for murti sets update: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print(
              '❌ Error creating temporary file from bytes for murti sets update: $e');
        }
      } else {
        print(
            '❌ No image provided for murti sets update - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print(
          '🔍 Debug Murti Sets Update API: Request fields: ${request.fields}');
      print(
          '🔍 Debug Murti Sets Update API: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug Murti Sets Update API: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(
          '🔍 Debug Murti Sets Update API: Response status: ${response.statusCode}');
      print('🔍 Debug Murti Sets Update API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to update murti sets item');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to update murti sets item');
      }
    } catch (e) {
      print('❌ Murti Sets Update API Error: $e');
      rethrow;
    }
  }

  // Update stationery item with specific API endpoint
  Future<Map<String, dynamic>> updateStationeryItem({
    required int id,
    required String name,
    required String storageLocation,
    required String notes,
    required double quantityAvailable,
    required String specifications,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/stationery/update'),
      );

      // Add form fields
      request.fields['id'] = id.toString();
      request.fields['name'] = name;
      request.fields['storage_location'] = storageLocation;
      request.fields['notes'] = notes;
      request.fields['quantity_available'] = quantityAvailable.toString();
      request.fields['specifications'] = specifications;

      // Add image file if provided
      print('🔍 Debug Stationery Update API: itemImage = $itemImage');
      print('🔍 Debug Stationery Update API: itemImagePath = $itemImagePath');
      print(
          '🔍 Debug Stationery Update API: itemImageBytes = ${itemImageBytes?.length} bytes');
      print('🔍 Debug Stationery Update API: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print(
            '✅ Using itemImage file for stationery update: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print(
            '🔍 Debug Stationery Update API: Checking if file exists: $itemImagePath');
        print(
            '🔍 Debug Stationery Update API: File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print(
              '✅ Using itemImagePath file for stationery update: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print('✅ MultipartFile created successfully for stationery update');
          } catch (e) {
            print('❌ Error creating MultipartFile for stationery update: $e');
          }
        } else {
          print('❌ File does not exist for stationery update: $itemImagePath');
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print(
            '🔍 Debug Stationery Update API: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print(
              '✅ Created temporary file for stationery update: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print(
              '❌ Error creating temporary file from bytes for stationery update: $e');
        }
      } else {
        print(
            '❌ No image provided for stationery update - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print(
          '🔍 Debug Stationery Update API: Request fields: ${request.fields}');
      print(
          '🔍 Debug Stationery Update API: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug Stationery Update API: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(
          '🔍 Debug Stationery Update API: Response status: ${response.statusCode}');
      print('🔍 Debug Stationery Update API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to update stationery item');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to update stationery item');
      }
    } catch (e) {
      print('❌ Stationery Update API Error: $e');
      rethrow;
    }
  }

  // Delete inventory item
  Future<Map<String, dynamic>> deleteInventoryItem({
    required int id,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/inventory/items/delete'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': id,
        }),
      );

      print('🔍 Debug Delete API: Response status: ${response.statusCode}');
      print('🔍 Debug Delete API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to delete inventory item');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to delete inventory item');
      }
    } catch (e) {
      print('❌ Delete API Error: $e');
      rethrow;
    }
  }

  // Issue inventory item to event
  Future<Map<String, dynamic>> issueInventoryToEvent({
    required int itemId,
    required int eventId,
    required double quantity,
    required String notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/inventory/issuances/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'item_id': itemId,
          'transaction_type': 'OUT',
          'quantity': quantity,
          'event_id': eventId,
          'notes': notes,
        }),
      );

      print(
          '🔍 Debug Issue to Event API: Response status: ${response.statusCode}');
      print('🔍 Debug Issue to Event API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to issue inventory to event');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to issue inventory to event');
      }
    } catch (e) {
      print('❌ Issue to Event API Error: $e');
      rethrow;
    }
  }

  // Get events list
  Future<Map<String, dynamic>> getEventsList() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/events/getList'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print(
          '🔍 Debug Events List API: Response status: ${response.statusCode}');
      print('🔍 Debug Events List API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to get events list');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get events list');
      }
    } catch (e) {
      print('❌ Events List API Error: $e');
      rethrow;
    }
  }

  // Get issuance history by item ID
  Future<Map<String, dynamic>> getIssuanceHistoryByItemId({
    required int itemId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/inventory/issuances/getHistoryByItemId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'item_id': itemId,
        }),
      );

      print(
          '🔍 Debug Issuance History API: Response status: ${response.statusCode}');
      print('🔍 Debug Issuance History API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to get issuance history');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to get issuance history');
      }
    } catch (e) {
      print('❌ Issuance History API Error: $e');
      rethrow;
    }
  }

  // Update issuance (for returns)
  Future<Map<String, dynamic>> updateIssuance({
    required int id,
    required int itemId,
    required String transactionType,
    required double quantity,
    required int eventId,
    required String notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/inventory/issuances/update'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': id,
          'item_id': itemId,
          'transaction_type': transactionType,
          // Use different field names based on transaction type
          if (transactionType == 'IN') 'return_quantity': quantity,
          if (transactionType == 'OUT') 'quantity': quantity,
          'event_id': eventId,
          'notes': notes,
        }),
      );

      print('🔍 Debug Update Issuance API: Request body: ${jsonEncode({
            'id': id,
            'item_id': itemId,
            'transaction_type': transactionType,
            if (transactionType == 'IN') 'return_quantity': quantity,
            if (transactionType == 'OUT') 'quantity': quantity,
            'event_id': eventId,
            'notes': notes,
          })}');
      print(
          '🔍 Debug Update Issuance API: Response status: ${response.statusCode}');
      print('🔍 Debug Update Issuance API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to update issuance');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update issuance');
      }
    } catch (e) {
      print('❌ Update Issuance API Error: $e');
      rethrow;
    }
  }

  // Get dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/dashboard/stats/'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print(
          '🔍 Debug Dashboard Stats API: Response status: ${response.statusCode}');
      print('🔍 Debug Dashboard Stats API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to get dashboard stats');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to get dashboard stats');
      }
    } catch (e) {
      print('❌ Dashboard Stats API Error: $e');
      rethrow;
    }
  }

  // Create frame structure item with specific API endpoint
  Future<Map<String, dynamic>> createFrameStructureItem({
    required String name,
    required String frameType,
    required String dimensions,
    required String storageLocation,
    required String notes,
    required double quantityAvailable,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/frame-structures/create'),
      );

      // Add form fields as per API specification
      request.fields['name'] = name;
      request.fields['frame_type'] = frameType;
      request.fields['dimensions'] = dimensions;
      request.fields['storage_location'] = storageLocation;
      request.fields['notes'] = notes;
      request.fields['quantity_available'] = quantityAvailable.toString();

      // Add image file if provided
      print('🔍 Debug Frame Structure API: itemImage = $itemImage');
      print('🔍 Debug Frame Structure API: itemImagePath = $itemImagePath');
      print(
          '🔍 Debug Frame Structure API: itemImageBytes = ${itemImageBytes?.length} bytes');
      print('🔍 Debug Frame Structure API: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print('✅ Using itemImage file for frame structure: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print(
            '🔍 Debug Frame Structure API: Checking if file exists: $itemImagePath');
        print(
            '🔍 Debug Frame Structure API: File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print(
              '✅ Using itemImagePath file for frame structure: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print('✅ MultipartFile created successfully for frame structure');
          } catch (e) {
            print('❌ Error creating MultipartFile for frame structure: $e');
          }
        } else {
          print('❌ File does not exist for frame structure: $itemImagePath');
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print(
            '🔍 Debug Frame Structure API: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print(
              '✅ Created temporary file for frame structure: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print(
              '❌ Error creating temporary file from bytes for frame structure: $e');
        }
      } else {
        print(
            '❌ No image provided for frame structure - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print('🔍 Debug Frame Structure API: Request fields: ${request.fields}');
      print(
          '🔍 Debug Frame Structure API: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug Frame Structure API: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print(
          '🔍 Debug Frame Structure API: Response status: ${response.statusCode}');
      print('🔍 Debug Frame Structure API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData =
            _parseJsonResponse(response, 'createFrameStructureItem');
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ??
              'Failed to create frame structure item');
        }
      } else {
        final errorData =
            _parseJsonResponse(response, 'createFrameStructureItem');
        throw Exception(
            errorData['message'] ?? 'Failed to create frame structure item');
      }
    } catch (e) {
      print('❌ Frame Structure API Error: $e');
      rethrow;
    }
  }

  // Create fabric item with specific API endpoint
  Future<Map<String, dynamic>> createFabricItem({
    required String name,
    required String fabricType,
    required String size,
    required String storageLocation,
    required String notes,
    required double quantityAvailable,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/fabric/create'),
      );

      // Add form fields as per API specification
      request.fields['name'] = name;
      request.fields['fabric_type'] = fabricType;
      request.fields['size'] = size;
      request.fields['storage_location'] = storageLocation;
      request.fields['notes'] = notes;
      request.fields['quantity_available'] = quantityAvailable.toString();

      // Add image file if provided
      print('🔍 Debug Fabric API: itemImage = $itemImage');
      print('🔍 Debug Fabric API: itemImagePath = $itemImagePath');
      print(
          '🔍 Debug Fabric API: itemImageBytes = ${itemImageBytes?.length} bytes');
      print('🔍 Debug Fabric API: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print('✅ Using itemImage file for fabric: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print('🔍 Debug Fabric API: Checking if file exists: $itemImagePath');
        print('🔍 Debug Fabric API: File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print('✅ Using itemImagePath file for fabric: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print('✅ MultipartFile created successfully for fabric');
          } catch (e) {
            print('❌ Error creating MultipartFile for fabric: $e');
          }
        } else {
          print('❌ File does not exist for fabric: $itemImagePath');
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print('🔍 Debug Fabric API: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print('✅ Created temporary file for fabric: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print('❌ Error creating temporary file from bytes for fabric: $e');
        }
      } else {
        print(
            '❌ No image provided for fabric - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print('🔍 Debug Fabric API: Request fields: ${request.fields}');
      print(
          '🔍 Debug Fabric API: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug Fabric API: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('🔍 Debug Fabric API: Response status: ${response.statusCode}');
      print('🔍 Debug Fabric API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = _parseJsonResponse(response, 'createFabricItem');
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to create fabric item');
        }
      } else {
        final errorData = _parseJsonResponse(response, 'createFabricItem');
        throw Exception(errorData['message'] ?? 'Failed to create fabric item');
      }
    } catch (e) {
      print('❌ Fabric API Error: $e');
      rethrow;
    }
  }

  // Create carpet item with specific API endpoint
  Future<Map<String, dynamic>> createCarpetItem({
    required String name,
    required String size,
    required String storageLocation,
    required String notes,
    required double quantityAvailable,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/carpets/create'),
      );

      // Add form fields - only the fields required by the API
      request.fields['name'] = name;
      request.fields['size'] = size;
      request.fields['storage_location'] = storageLocation;
      request.fields['notes'] = notes;
      request.fields['quantity_available'] = quantityAvailable.toString();

      // Add image file if provided
      print('🔍 Debug Carpet API: itemImage = $itemImage');
      print('🔍 Debug Carpet API: itemImagePath = $itemImagePath');
      print(
          '🔍 Debug Carpet API: itemImageBytes = ${itemImageBytes?.length} bytes');
      print('🔍 Debug Carpet API: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print('✅ Using itemImage file for carpet: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print('🔍 Debug Carpet API: Checking if file exists: $itemImagePath');
        print('🔍 Debug Carpet API: File exists: ${await imageFile.exists()}');

        if (await imageFile.exists()) {
          print('✅ Using itemImagePath file for carpet: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print('✅ MultipartFile created successfully for carpet');
          } catch (e) {
            print('❌ Error creating MultipartFile for carpet: $e');
          }
        } else {
          print('❌ File does not exist for carpet: $itemImagePath');
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print('🔍 Debug Carpet API: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print('✅ Created temporary file for carpet: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print('❌ Error creating temporary file from bytes for carpet: $e');
        }
      } else {
        print(
            '❌ No image provided for carpet - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print('🔍 Debug Carpet API: Request fields: ${request.fields}');
      print(
          '🔍 Debug Carpet API: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug Carpet API: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('🔍 Debug Carpet API: Response status: ${response.statusCode}');
      print('🔍 Debug Carpet API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = _parseJsonResponse(response, 'createCarpetItem');
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to create carpet item');
        }
      } else {
        final errorData = _parseJsonResponse(response, 'createCarpetItem');
        throw Exception(errorData['message'] ?? 'Failed to create carpet item');
      }
    } catch (e) {
      print('❌ Carpet API Error: $e');
      rethrow;
    }
  }

  // Create new inventory item with multipart form data
  Future<Map<String, dynamic>> createItem({
    required String name,
    required int categoryId,
    required String storageLocation,
    required String notes,
    required double quantityAvailable,
    File? itemImage,
    String? itemImagePath,
    Uint8List? itemImageBytes,
    String? itemImageName,
    required Map<String, dynamic> categoryDetails,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/inventory/items/create'),
      );

      // Add basic fields
      request.fields['name'] = name;
      request.fields['category_id'] = categoryId.toString();
      request.fields['storage_location'] = storageLocation;
      request.fields['notes'] = notes;
      request.fields['quantity_available'] = quantityAvailable.toString();

      // Add category details as JSON string
      request.fields['category_details'] = jsonEncode(categoryDetails);

      // Add image file if provided
      print('🔍 Debug: itemImage = $itemImage');
      print('🔍 Debug: itemImagePath = $itemImagePath');
      print('🔍 Debug: itemImageBytes = ${itemImageBytes?.length} bytes');
      print('🔍 Debug: itemImageName = $itemImageName');

      if (itemImage != null && await itemImage.exists()) {
        print('✅ Using itemImage file: ${itemImage.path}');
        request.files.add(
          await http.MultipartFile.fromPath(
            'item_image',
            itemImage.path,
            filename: itemImage.path.split('/').last,
          ),
        );
      } else if (itemImagePath != null) {
        final imageFile = File(itemImagePath);
        print('🔍 Debug: Checking if file exists: $itemImagePath');
        print('🔍 Debug: File exists: ${await imageFile.exists()}');
        print('🔍 Debug: File path length: ${itemImagePath.length}');
        print('🔍 Debug: File path segments: ${itemImagePath.split('/')}');

        if (await imageFile.exists()) {
          print('✅ Using itemImagePath file: $itemImagePath');
          try {
            final multipartFile = await http.MultipartFile.fromPath(
              'item_image',
              itemImagePath,
              filename: itemImagePath.split('/').last,
            );
            request.files.add(multipartFile);
            print('✅ MultipartFile created successfully');
          } catch (e) {
            print('❌ Error creating MultipartFile: $e');
          }
        } else {
          print('❌ File does not exist: $itemImagePath');
          // Try to list directory to see what's available
          try {
            final directory = Directory(
                itemImagePath.substring(0, itemImagePath.lastIndexOf('/')));
            if (await directory.exists()) {
              final files = await directory.list().toList();
              print(
                  '🔍 Debug: Files in directory: ${files.map((f) => f.path).toList()}');
            }
          } catch (e) {
            print('❌ Error listing directory: $e');
          }
        }
      } else if (itemImageBytes != null && itemImageName != null) {
        print('🔍 Debug: Creating temporary file from bytes');
        try {
          // Create temporary file from bytes
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/$itemImageName');
          await tempFile.writeAsBytes(itemImageBytes);

          print('✅ Created temporary file: ${tempFile.path}');
          request.files.add(
            await http.MultipartFile.fromPath(
              'item_image',
              tempFile.path,
              filename: itemImageName,
            ),
          );

          // Clean up temporary file after request
          tempFile.delete().catchError((e) {
            print('Warning: Could not delete temp file: $e');
            return tempFile;
          });
        } catch (e) {
          print('❌ Error creating temporary file from bytes: $e');
        }
      } else {
        print(
            '❌ No image provided - itemImage: $itemImage, itemImagePath: $itemImagePath, itemImageBytes: ${itemImageBytes?.length}');
      }

      // Debug: Print request details
      print('🔍 Debug: Request fields: ${request.fields}');
      print('🔍 Debug: Request files count: ${request.files.length}');
      for (var file in request.files) {
        print(
            '🔍 Debug: File field: ${file.field}, filename: ${file.filename}');
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('🔍 Debug: Response status: ${response.statusCode}');
      print('🔍 Debug: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          if (responseData['success'] == true) {
            return responseData;
          } else {
            throw Exception(responseData['message'] ?? 'Failed to create item');
          }
        } catch (e) {
          // If JSON parsing fails, it's likely HTML (server error page)
          throw Exception(
              'Server returned invalid response. Please check server configuration.');
        }
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to create item');
        } catch (e) {
          // If JSON parsing fails, it's likely HTML (404, 500 error page)
          String errorMessage = 'Server error (${response.statusCode})';
          if (response.statusCode == 404) {
            errorMessage =
                'API endpoint not found. Please check server configuration.';
          } else if (response.statusCode == 500) {
            errorMessage = 'Internal server error. Please try again later.';
          } else if (response.statusCode == 401) {
            errorMessage = 'Authentication required. Please login again.';
          } else if (response.statusCode == 403) {
            errorMessage =
                'Access denied. You do not have permission to perform this action.';
          }
          throw Exception(errorMessage);
        }
      }
    } catch (e) {
      print('❌ Error creating inventory item: $e');
      rethrow;
    }
  }

  // Get issuance history by event ID
  Future<Map<String, dynamic>> getIssuanceHistoryByEventId({
    required int eventId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/inventory/issuances/getHistoryByEventId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'event_id': eventId,
        }),
      );

      print(
          '🔍 Debug Event Issuance History API: Response status: ${response.statusCode}');
      print(
          '🔍 Debug Event Issuance History API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(responseData['message'] ??
              'Failed to get event issuance history');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to get event issuance history');
      }
    } catch (e) {
      print('❌ Event Issuance History API Error: $e');
      rethrow;
    }
  }

  // Get inventory items list for dropdown
  Future<Map<String, dynamic>> getInventoryItemsList() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/materials/inventory/getAll'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );

      print('🔍 Debug Inventory Items List API: Response status: ${response.statusCode}');
      print('🔍 Debug Inventory Items List API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        // The new API returns an array directly, so we need to wrap it
        return {
          'success': true,
          'message': 'Inventory items retrieved successfully',
          'data': responseData,
          'count': responseData.length,
        };
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to get inventory items list');
      }
    } catch (e) {
      print('❌ Inventory Items List API Error: $e');
      rethrow;
    }
  }

  // Create material issuance
  Future<Map<String, dynamic>> createMaterialIssuance({
    required int itemId,
    required String transactionType,
    required double quantity,
    required int eventId,
    required String notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/inventory/issuances/create'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'item_id': itemId,
          'transaction_type': transactionType,
          'quantity': quantity,
          'event_id': eventId,
          'notes': notes,
        }),
      );

      print(
          '🔍 Debug Create Material Issuance API: Response status: ${response.statusCode}');
      print(
          '🔍 Debug Create Material Issuance API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to create material issuance');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to create material issuance');
      }
    } catch (e) {
      print('❌ Create Material Issuance API Error: $e');
      rethrow;
    }
  }

  // Update material issuance (for returning items)
  Future<Map<String, dynamic>> updateMaterialIssuance({
    required int issuanceId,
    required int itemId,
    required String transactionType,
    required double quantity,
    required int eventId,
    required String notes,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/inventory/issuances/update'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': issuanceId,
          'item_id': itemId,
          'transaction_type': transactionType,
          // Use different field names based on transaction type
          if (transactionType == 'IN') 'return_quantity': quantity,
          if (transactionType == 'OUT') 'quantity': quantity,
          'event_id': eventId,
          'notes': notes,
        }),
      );

      print(
          '🔍 Debug Update Material Issuance API: Response status: ${response.statusCode}');
      print(
          '🔍 Debug Update Material Issuance API: Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return responseData;
        } else {
          throw Exception(
              responseData['message'] ?? 'Failed to update material issuance');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
            errorData['message'] ?? 'Failed to update material issuance');
      }
    } catch (e) {
      print('❌ Update Material Issuance API Error: $e');
      rethrow;
    }
  }
}
