import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';

class SharingService {
  static Future<void> shareImage({
    required String imageUrl,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      print('🔍 SharingService: Starting to share image: $imageUrl');
      
      // Show loading indicator
      _showLoadingSnackBar(context, 'Downloading and sharing...');
      
      // Download the image
      final response = await http.get(Uri.parse(imageUrl));
      
      if (response.statusCode == 200) {
        print('🔍 SharingService: Image downloaded successfully');
        
        // Get the temporary directory
        final tempDir = await getTemporaryDirectory();
        
        // Create a unique filename
        final fileExtension = imageUrl.split('.').last.toLowerCase();
        final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName.$fileExtension';
        final filePath = '${tempDir.path}/$uniqueFileName';
        
        // Save the image to temporary file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        
        print('🔍 SharingService: Image saved to: $filePath');
        
        // Check if file exists and has content
        if (await file.exists() && await file.length() > 0) {
          print('🔍 SharingService: File exists and has content, sharing...');
          
          // Share the downloaded file
          await Share.shareXFiles(
            [XFile(filePath)],
            subject: fileName,
            text: 'Check out this design image!',
          );
          
          print('🔍 SharingService: Image shared successfully');
          
          _showSuccessSnackBar(context, 'Image shared successfully');
        } else {
          throw Exception('Downloaded file is empty or does not exist');
        }
      } else {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
    } catch (e) {
      print('🔍 SharingService: Error sharing image: $e');
      
      // Fallback: try sharing the URL directly
      try {
        print('🔍 SharingService: Trying fallback: sharing URL directly');
        await Share.share(
          imageUrl,
          subject: fileName,
        );
        print('🔍 SharingService: URL shared successfully as fallback');
        _showSuccessSnackBar(context, 'Image URL shared successfully');
      } catch (fallbackError) {
        print('🔍 SharingService: Fallback also failed: $fallbackError');
        _showErrorSnackBar(context, 'Error sharing image: $fallbackError');
      }
    }
  }

  static Future<void> sharePDF({
    required Uint8List pdfData,
    required String fileName,
    required BuildContext context,
  }) async {
    try {
      print('🔍 SharingService: Starting to share PDF: $fileName');
      
      // Show loading indicator
      _showLoadingSnackBar(context, 'Preparing PDF for sharing...');
      
      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();
      
      // Create a unique filename
      final uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}_$fileName.pdf';
      final filePath = '${tempDir.path}/$uniqueFileName';
      
      // Save the PDF data to temporary file
      final file = File(filePath);
      await file.writeAsBytes(pdfData);
      
      print('🔍 SharingService: PDF saved to: $filePath');
      
      // Check if file exists and has content
      if (await file.exists() && await file.length() > 0) {
        print('🔍 SharingService: PDF file exists and has content, sharing...');
        
        // Share the downloaded file
        await Share.shareXFiles(
          [XFile(filePath)],
          subject: fileName,
          text: 'Check out this PDF document!',
        );
        
        print('🔍 SharingService: PDF shared successfully');
        _showSuccessSnackBar(context, 'PDF shared successfully');
      } else {
        throw Exception('PDF file is empty or does not exist');
      }
    } catch (e) {
      print('🔍 SharingService: Error sharing PDF: $e');
      _showErrorSnackBar(context, 'Error sharing PDF: $e');
    }
  }

  static void _showLoadingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text(message),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
