import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/api_provider.dart';

class CachedNetworkOrFileImage extends ConsumerWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedNetworkOrFileImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? const SizedBox.shrink();
    }

    final imageCache = ref.read(imageCacheServiceProvider);

    return FutureBuilder<String?>(
      future: imageCache.getCachedPath(imageUrl),
      builder: (context, cachedSnap) {
        final cachedPath = cachedSnap.data;
        // If we already have it cached, show instantly from file
        if (cachedPath != null && File(cachedPath).existsSync()) {
          return Image.file(File(cachedPath), fit: fit);
        }

        // Start download in background; immediately show network with placeholder
        imageCache.ensureCached(imageUrl);

        return Image.network(
          imageUrl,
          fit: fit,
          errorBuilder: (_, __, ___) => errorWidget ?? const Icon(Icons.broken_image),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return placeholder ?? child;
          },
        );
      },
    );
  }
}


