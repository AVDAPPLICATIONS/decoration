import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_view/photo_view.dart';
import '../../../providers/api_provider.dart';
import '../../../services/sharing_service.dart';

class FullScreenImageViewer extends ConsumerWidget {
  final String imageUrl;
  final String? title;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageCache = ref.read(imageCacheServiceProvider);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title ?? 'Image',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareImage(context),
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: imageCache.getCachedPath(imageUrl),
        builder: (context, snapshot) {
          final cachedPath = snapshot.data;
          final ImageProvider provider;
          if (cachedPath != null && File(cachedPath).existsSync()) {
            provider = FileImage(File(cachedPath));
          } else {
            // Kick off background caching for next time
            imageCache.ensureCached(imageUrl);
            provider = NetworkImage(imageUrl);
          }

          return PhotoView(
            imageProvider: provider,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
            backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 64,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _shareImage(BuildContext context) async {
    try {
      // Use the sharing service
      await SharingService.shareImage(
        imageUrl: imageUrl,
        fileName: title ?? 'Image',
        context: context,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

}
