import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GalleryService {
  final String baseUrl;
  final dynamic localStorageService;

  GalleryService(this.baseUrl, this.localStorageService);

  static final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // Pick image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  // Show image source selection dialog
  static Future<File?> showImageSourceDialog() async {
    // This would typically show a dialog to choose between camera and gallery
    // For now, we'll default to gallery
    return await pickImageFromGallery();
  }

  // Get event images
  Future<Map<String, dynamic>> getEventImages(String eventId) async {
    try {
      print('🔄 Getting event images for event ID: $eventId');
      final response = await http.get(
        Uri.parse('$baseUrl/api/events/$eventId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('🔄 Response status: ${response.statusCode}');
      print('🔄 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'];
        }
      }
      return {};
    } catch (e) {
      print('❌ Error getting event images: $e');
      return {};
    }
  }

  // Upload design image
  Future<Map<String, dynamic>> uploadDesignImage({
    required String eventId,
    required String imagePath,
    required String description,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/events/$eventId/design-images'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      request.fields['description'] = description;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      return data;
    } catch (e) {
      print('Error uploading design image: $e');
      return {'success': false, 'message': 'Upload failed'};
    }
  }

  // Upload final decoration image
  Future<Map<String, dynamic>> uploadFinalDecorationImage({
    required String eventId,
    required String imagePath,
    required String description,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/events/$eventId/final-images'),
      );

      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      request.fields['description'] = description;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      return data;
    } catch (e) {
      print('Error uploading final decoration image: $e');
      return {'success': false, 'message': 'Upload failed'};
    }
  }

  // Delete design image
  Future<Map<String, dynamic>> deleteDesignImage({
    required String imageId,
    required String eventId,
  }) async {
    try {
      print('🗑️ Deleting design image with ID: $imageId for event: $eventId');
      print('🗑️ API URL: $baseUrl/api/gallery/design/delete');

      final response = await http.post(
        Uri.parse('$baseUrl/api/gallery/design/delete'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': int.parse(imageId),
        }),
      );

      print('🗑️ Response status: ${response.statusCode}');
      print('🗑️ Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        return {
          'success': false, 
          'message': 'Delete endpoint not available. Image deletion may not be supported yet.'
        };
      } else {
        return {'success': false, 'message': 'Delete failed with status ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Error deleting design image: $e');
      if (e.toString().contains('SyntaxError') || e.toString().contains('<!DOCTYPE')) {
        return {
          'success': false, 
          'message': 'Delete endpoint not available. Image deletion may not be supported yet.'
        };
      }
      return {'success': false, 'message': 'Delete failed: $e'};
    }
  }

  // Delete final decoration image
  Future<Map<String, dynamic>> deleteFinalDecorationImage({
    required String imageId,
    required String eventId,
  }) async {
    try {
      print('🗑️ Deleting final decoration image with ID: $imageId for event: $eventId');
      print('🗑️ API URL: $baseUrl/api/gallery/final/delete');

      final response = await http.post(
        Uri.parse('$baseUrl/api/gallery/final/delete'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'id': int.parse(imageId),
        }),
      );

      print('🗑️ Response status: ${response.statusCode}');
      print('🗑️ Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        return {
          'success': false, 
          'message': 'Delete endpoint not available. Image deletion may not be supported yet.'
        };
      } else {
        return {'success': false, 'message': 'Delete failed with status ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Error deleting final decoration image: $e');
      if (e.toString().contains('SyntaxError') || e.toString().contains('<!DOCTYPE')) {
        return {
          'success': false, 
          'message': 'Delete endpoint not available. Image deletion may not be supported yet.'
        };
      }
      return {'success': false, 'message': 'Delete failed: $e'};
    }
  }

  // Upload multiple images
  Future<Map<String, dynamic>> uploadMultipleImages({
    required String eventId,
    required List<File> imageFiles,
    required String description,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/events/$eventId/multiple-images'),
      );

      for (int i = 0; i < imageFiles.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'images[$i]',
          imageFiles[i].path,
        ));
      }
      request.fields['description'] = description;

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      return data;
    } catch (e) {
      print('Error uploading multiple images: $e');
      return {'success': false, 'message': 'Upload failed'};
    }
  }

  // Upload design images (multiple images with notes)
  Future<Map<String, dynamic>> uploadDesignImages({
    required String eventId,
    required List<File> imageFiles,
    required String notes,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/gallery/design'),
      );

      // Add multiple image files
      for (int i = 0; i < imageFiles.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'images',
          imageFiles[i].path,
        ));
      }

      // Add form fields
      request.fields['event_id'] = eventId;
      request.fields['notes'] = notes;

      print('Uploading ${imageFiles.length} design images for event $eventId');
      print('Notes: $notes');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      print('Design images upload response: $data');

      return data;
    } catch (e) {
      print('Error uploading design images: $e');
      return {'success': false, 'message': 'Upload failed: $e'};
    }
  }

  // Upload final decoration images (multiple images with notes)
  Future<Map<String, dynamic>> uploadFinalDecorationImages({
    required String eventId,
    required List<File> imageFiles,
    required String notes,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/gallery/final'),
      );

      // Add multiple image files
      for (int i = 0; i < imageFiles.length; i++) {
        request.files.add(await http.MultipartFile.fromPath(
          'images',
          imageFiles[i].path,
        ));
      }

      // Add form fields
      request.fields['event_id'] = eventId;
      request.fields['notes'] = notes;

      print(
          'Uploading ${imageFiles.length} final decoration images for event $eventId');
      print('Notes: $notes');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);

      print('Final decoration images upload response: $data');

      return data;
    } catch (e) {
      print('Error uploading final decoration images: $e');
      return {'success': false, 'message': 'Upload failed: $e'};
    }
  }
}
