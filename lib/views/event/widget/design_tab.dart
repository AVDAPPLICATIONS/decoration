import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';

import '../../../themes/app_theme.dart';
import '../../../services/gallery_service.dart';
import '../../../services/local_storage_service.dart';
import '../../../utils/constants.dart';
import '../../../utils/snackbar_manager.dart';
import 'fullscreen_image_viewer.dart';

class DesignTab extends StatefulWidget {
  final Map<String, dynamic> event;
  final bool isAdmin;

  const DesignTab({Key? key, required this.event, required this.isAdmin})
      : super(key: key);

  @override
  State<DesignTab> createState() => _DesignTabState();
}

class _DesignTabState extends State<DesignTab> {
  final ImagePicker _picker = ImagePicker();
  GalleryService? _galleryService;
  LocalStorageService? _localStorageService;

  // Local state for images
  List<Map<String, dynamic>> _designImages = [];
  List<Map<String, dynamic>> _finalDecorationImages = [];

  // Loading states
  bool _isLoadingImages = false;
  bool _hasLoadedImages = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() async {
    try {
      _localStorageService = LocalStorageService();
      _galleryService = GalleryService(apiBaseUrl, _localStorageService!);
      print('Services initialized successfully');

      // Load images from server after services are initialized
      _loadImagesFromServer();
    } catch (e) {
      print('Error initializing services: $e');
      // Retry initialization after a short delay
      await Future.delayed(const Duration(milliseconds: 1000));
      try {
        _localStorageService = LocalStorageService();
        _galleryService = GalleryService(apiBaseUrl, _localStorageService!);
        print('Services initialized successfully on retry');

        // Load images from server after services are initialized
        _loadImagesFromServer();
      } catch (retryError) {
        print('Failed to initialize services on retry: $retryError');
        // Set to null to indicate failure
        _galleryService = null;
        _localStorageService = null;
      }
    }
  }

  bool _areServicesReady() {
    return _galleryService != null && _localStorageService != null;
  }

  /// Load images from server
  Future<void> _loadImagesFromServer() async {
    if (!_areServicesReady() || _isLoadingImages) return;

    setState(() {
      _isLoadingImages = true;
    });

    try {
      print('🔄 Loading images from server for event: ${widget.event['id']}');

      // Fetch all event images in a single API call
      final eventData =
          await _galleryService!.getEventImages(widget.event['id'].toString());

      if (mounted) {
        setState(() {
          _isLoadingImages = false;
          _hasLoadedImages = true;
        });

        // Process the event data based on the API response structure
        List<Map<String, dynamic>> newDesignImages = [];
        List<Map<String, dynamic>> newFinalDecorationImages = [];

        print('🔍 Processing event data: $eventData');

        // Process design images from gallery.design array
        if (eventData['gallery'] != null &&
            eventData['gallery']['design'] is List) {
          final designImages = eventData['gallery']['design'];
          print('🔍 Found ${designImages.length} design images');

          for (int i = 0; i < designImages.length; i++) {
            var item = designImages[i];
            print('🔍 Design image $i: $item');

            if (item is Map<String, dynamic>) {
              // Convert relative URL to full URL
              String imageUrl = item['image_url'] ?? '';
              if (imageUrl.startsWith('/')) {
                imageUrl = '${apiBaseUrl}$imageUrl';
              }

              newDesignImages.add({
                'image_path': imageUrl,
                'notes': item['notes'] ?? '',
                'api_data': item,
                'id': item['id'], // Store ID directly for easier access
              });
              print('🔍 Added design image: $imageUrl');
            }
          }
        }

        // Process final decoration images from gallery.final array
        if (eventData['gallery'] != null &&
            eventData['gallery']['final'] is List) {
          final finalImages = eventData['gallery']['final'];
          print('🔍 Found ${finalImages.length} final decoration images');

          for (int i = 0; i < finalImages.length; i++) {
            var item = finalImages[i];
            print('🔍 Final decoration image $i: $item');

            if (item is Map<String, dynamic>) {
              // Convert relative URL to full URL
              String imageUrl = item['image_url'] ?? '';
              if (imageUrl.startsWith('/')) {
                imageUrl = '${apiBaseUrl}$imageUrl';
              }

              newFinalDecorationImages.add({
                'image_path': imageUrl,
                'description': item['notes'] ?? '',
                'api_data': item,
                'id': item['id'], // Store ID directly for easier access
              });
              print('🔍 Added final decoration image: $imageUrl');
            }
          }
        }

        print('🔍 Total design images found: ${newDesignImages.length}');
        print(
            '🔍 Total final decoration images found: ${newFinalDecorationImages.length}');

        setState(() {
          _designImages = newDesignImages;
          _finalDecorationImages = newFinalDecorationImages;
        });

        print(
            '✅ Loaded ${_designImages.length} design images and ${_finalDecorationImages.length} final decoration images');
      }
    } catch (e) {
      print('❌ Error loading images from server: $e');
      if (mounted) {
        setState(() {
          _isLoadingImages = false;
          _hasLoadedImages = true;
        });

        SnackBarManager.showWarning(
          context: context,
          message: 'Failed to load images: ${e.toString()}',
        );
      }
    }
  }

  /// Refresh images from server
  Future<void> _refreshImages() async {
    await _loadImagesFromServer();
  }

  /// Build image widget that handles both local files and network images
  Widget _buildImageWidget(String imagePath) {
    // Check if it's a network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.fill,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey.shade200,
                  Colors.grey.shade100,
                ],
              ),
            ),
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
              ],
            ),
          ),
          child: Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.grey.shade400,
          ),
        ),
      );
    } else {
      // Local file
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade100,
              ],
            ),
          ),
          child: Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }
  }

  /// Show success dialog for image upload
  void _showUploadSuccessDialog(
      BuildContext context, int successCount, String imageType) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green.shade600,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Upload Successful!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Successfully uploaded $successCount $imageType image${successCount > 1 ? 's' : ''} to the gallery.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your images are now available in the gallery and can be viewed by other team members.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Close add dialog
                // Refresh images from server to show the newly uploaded images
                _refreshImages();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Great!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final designImages = _designImages;
    final finalDecorationImages = _finalDecorationImages;
    print('grid images ${designImages.toList()}');
    return Container(
      height: MediaQuery.of(context).size.height -
          kToolbarHeight -
          kBottomNavigationBarHeight -
          100, // Ensure proper height
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.grey.shade50],
          stops: const [0.0, 0.3],
        ),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Enhanced Tab Bar with Refresh Button
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (_isLoadingImages)
                              Container(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Text(
                              '${_designImages.length + _finalDecorationImages.length} images',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Tab Bar
                  TabBar(
                    labelColor: AppColors.primary,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: AppColors.primary,
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Design Images',
                              style: TextStyle(fontSize: 14),
                            ),
                            if (_designImages.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_designImages.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Final Decoration',
                              style: TextStyle(fontSize: 14),
                            ),
                            if (_finalDecorationImages.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${_finalDecorationImages.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  RefreshIndicator(
                    onRefresh: _refreshImages,
                    color: AppColors.primary,
                    backgroundColor: Colors.white,
                    strokeWidth: 2.5,
                    displacement: 40,
                    child: _buildImageGrid(context, widget.isAdmin,
                        'Add Design Image', true, designImages),
                  ),
                  RefreshIndicator(
                    onRefresh: _refreshImages,
                    color: AppColors.primary,
                    backgroundColor: Colors.white,
                    strokeWidth: 2.5,
                    displacement: 40,
                    child: _buildImageGrid(context, widget.isAdmin,
                        'Add Final Decoration', false, finalDecorationImages),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid(BuildContext context, bool isAdmin, String label,
      bool isDesignTab, List<Map<String, dynamic>> images) {
    print('grid images ${images.toList()}');
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: _isLoadingImages && !_hasLoadedImages
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Loading images...',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Fetching images from server',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : images.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.primary.withOpacity(0.1),
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
                                isDesignTab
                                    ? Icons.design_services
                                    : Icons.celebration,
                                size: 60,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              isDesignTab
                                  ? 'No Design Images'
                                  : 'No Final Decoration Images',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isDesignTab
                                  ? 'Add design images to showcase your creative process'
                                  : 'Add final decoration images to show the completed work',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Pull down to refresh',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: List.generate(
                          images.length,
                          (index) => GestureDetector(
                            onLongPress: () {
                              final imagePath =
                                  images[index]['image_path'] ?? '';
                              if (imagePath.isNotEmpty) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImageViewer(
                                      imageUrl: imagePath,
                                      title: 'Image ${index + 1}',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 25,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(20)),
                                      child: images[index]['image_path'] !=
                                                  null &&
                                              images[index]['image_path']
                                                  .toString()
                                                  .isNotEmpty
                                          ? _buildImageWidget(
                                              images[index]['image_path'])
                                          : Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Colors.grey.shade200,
                                                    Colors.grey.shade100,
                                                  ],
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.image,
                                                size: 48,
                                                color: Colors.grey.shade400,
                                              ),
                                            ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primary.withOpacity(0.9),
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.vertical(
                                          bottom: Radius.circular(24)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.3),
                                          blurRadius: 15,
                                          spreadRadius: 0,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Center(
                                            child: Text(
                                              isDesignTab
                                                  ? (images[index]['notes'] ??
                                                      '')
                                                  : (images[index]
                                                          ['description'] ??
                                                      ''),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        // Container(
                                        //   height: 35,
                                        //   width: 35,
                                        //   decoration: BoxDecoration(
                                        //     color: Colors.white.withOpacity(0.2),
                                        //     borderRadius: BorderRadius.circular(10),
                                        //   ),
                                        //   child: IconButton(
                                        //     icon: const Icon(
                                        //       Icons.share_outlined,
                                        //       color: Colors.white,
                                        //       size: 20,
                                        //     ),
                                        //     tooltip: 'Share',
                                        //     onPressed: () => _shareImage(images[index]),
                                        //   ),
                                        // ),
                                        const SizedBox(width: 8),
                                        Container(
                                          // margin: const EdgeInsets.only(left: 8),
                                          height: 35,
                                          width: 35,
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            tooltip: 'Delete',
                                            onPressed: () async {
                                              // Show confirmation dialog
                                              final confirmed =
                                                  await showDialog<bool>(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  backgroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  title: const Text(
                                                    'Delete Image',
                                                    style: TextStyle(
                                                      color: AppColors.primary,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  content: const Text(
                                                    'Are you sure you want to delete this image?',
                                                    style: TextStyle(
                                                        color: Colors.black87),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                      child: Text(
                                                        'Cancel',
                                                        style: TextStyle(
                                                            color: Colors
                                                                .grey.shade600),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(true),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                      ),
                                                      child:
                                                          const Text('Delete'),
                                                    ),
                                                  ],
                                                ),
                                              );

                                              if (confirmed == true) {
                                                // Check if image has API data (was uploaded to server)
                                                final imageData = images[index];
                                                print(
                                                    'Image data is ${imageData}');
                                                if (imageData['id'] != null) {
                                                  // Show loading indicator
                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (context) =>
                                                        const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                    ),
                                                  );

                                                  try {
                                                    if (!_areServicesReady()) {
                                                      Navigator.of(context)
                                                          .pop(); // Close loading dialog
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Services are still initializing. Please wait a moment and try again.'),
                                                          backgroundColor:
                                                              Colors.orange,
                                                          duration: Duration(
                                                              seconds: 3),
                                                        ),
                                                      );
                                                      return;
                                                    }

                                                    Map<String, dynamic> result;
                                                    if (isDesignTab) {
                                                      print(
                                                          'Deleting design image with ID: ${imageData['id']}');
                                                      result =
                                                          await _galleryService!
                                                              .deleteDesignImage(
                                                        imageId: imageData['id']
                                                            .toString(),
                                                        eventId: widget.event['id']
                                                            .toString(),
                                                      );
                                                    } else {
                                                      print(
                                                          'Deleting final decoration image with ID: ${imageData['id']}');
                                                      result =
                                                          await _galleryService!
                                                              .deleteFinalDecorationImage(
                                                        imageId: imageData['id']
                                                            .toString(),
                                                        eventId: widget.event['id']
                                                            .toString(),
                                                      );
                                                    }

                                                    // Close loading dialog
                                                    Navigator.of(context).pop();

                                                    if (result['success']) {
                                                      // Remove from local state
                                                      if (isDesignTab) {
                                                        _designImages
                                                            .removeAt(index);
                                                        setState(() {});
                                                      } else {
                                                        _finalDecorationImages
                                                            .removeAt(index);
                                                        setState(() {});
                                                      }

                                                      // Show success message
                                                      SnackBarManager
                                                          .showSuccess(
                                                        context: context,
                                                        message:
                                                            'Image deleted successfully',
                                                      );
                                                    } else {
                                                      // Show error message
                                                      SnackBarManager.showError(
                                                        context: context,
                                                        message: result[
                                                                'message'] ??
                                                            'Failed to delete image',
                                                      );
                                                    }
                                                  } catch (e) {
                                                    // Close loading dialog
                                                    Navigator.of(context).pop();

                                                    // Show error message
                                                    SnackBarManager.showError(
                                                      context: context,
                                                      message:
                                                          'An error occurred: ${e.toString()}',
                                                    );
                                                  }
                                                } else {
                                                  // Image was not uploaded to server, just remove from local state
                                                  if (isDesignTab) {
                                                    _designImages
                                                        .removeAt(index);
                                                    setState(() {});
                                                  } else {
                                                    _finalDecorationImages
                                                        .removeAt(index);
                                                    setState(() {});
                                                  }
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
          ),
          if (isAdmin)
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
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
                child: FloatingActionButton.extended(
                  heroTag: "design_tab_add_button", // Added unique hero tag
                  onPressed: () => _showAddDialog(context, label, isDesignTab),
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add_a_photo,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  label: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, String label, bool isDesignTab) {
    final _formKey = GlobalKey<FormState>();
    List<XFile> pickedImages = [];
    String notesOrDesc = '';
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      spreadRadius: 0,
                      offset: const Offset(0, 15),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      spreadRadius: 0,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.primary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(24)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                isDesignTab
                                    ? Icons.design_services
                                    : Icons.celebration,
                                color: AppColors.primary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Form Content
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Image Preview
                              if (pickedImages.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Selected Images (${pickedImages.length})',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      SizedBox(
                                        height: 120,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: pickedImages.length,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              margin: const EdgeInsets.only(
                                                  right: 12),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.1),
                                                    blurRadius: 15,
                                                    spreadRadius: 0,
                                                    offset: const Offset(0, 6),
                                                  ),
                                                ],
                                              ),
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    child: Image.file(
                                                      File(pickedImages[index]
                                                          .path),
                                                      height: 120,
                                                      width: 120,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    right: 8,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setStateDialog(() {
                                                          pickedImages
                                                              .removeAt(index);
                                                        });
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.red
                                                              .withOpacity(0.8),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: const Icon(
                                                          Icons.close,
                                                          color: Colors.white,
                                                          size: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              // Browse Button
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary.withOpacity(0.1),
                                      AppColors.primary.withOpacity(0.05),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: AppColors.primary.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    final List<XFile> images =
                                        await _picker.pickMultiImage(
                                      maxWidth: 1920,
                                      maxHeight: 1080,
                                      imageQuality: 85,
                                    );
                                    if (images.isNotEmpty) {
                                      setStateDialog(() {
                                        pickedImages.addAll(images);
                                      });
                                    }
                                  },
                                  icon: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.browse_gallery,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  label: Text(
                                    'Select Images (${pickedImages.length})',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: AppColors.primary,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Year Selection Field
                              // AnimatedYearDropdown(
                              //   selectedYear: selectedYear,
                              //   onYearSelected: (year) {
                              //     setStateDialog(() {
                              //       selectedYear = year;
                              //     });
                              //   },
                              //   hintText: 'Select Year',
                              //   enabled: true,
                              // ),
                              const SizedBox(height: 20),
                              // Notes/Description Field
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white,
                                      Colors.grey.shade50,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 15,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: TextFormField(
                                  maxLines: 2,
                                  decoration: InputDecoration(
                                    labelText: isDesignTab
                                        ? 'Notes (Optional)'
                                        : 'Description (Optional)',
                                    labelStyle: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                    prefixIcon: Container(
                                      margin: const EdgeInsets.all(10),
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.primary.withOpacity(0.15),
                                            AppColors.primary.withOpacity(0.08),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.primary
                                              .withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        isDesignTab
                                            ? Icons.note
                                            : Icons.description,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        color: AppColors.primary,
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade200,
                                        width: 1,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 18,
                                      horizontal: 20,
                                    ),
                                    hintText: isDesignTab
                                        ? 'Enter design notes...'
                                        : 'Enter decoration description...',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade400,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onSaved: (value) =>
                                      notesOrDesc = value?.trim() ?? '',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Actions
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 1,
                                  ),
                                ),
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
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
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 15,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (pickedImages.isEmpty) {
                                      SnackBarManager.showError(
                                        context: context,
                                        message:
                                            'Please select at least one image.',
                                      );
                                      return;
                                    }
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();

                                      // Show loading dialog with progress
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) =>
                                            _buildUploadProgressDialog(
                                                context,
                                                pickedImages.length,
                                                isDesignTab),
                                      );

                                      try {
                                        if (!_areServicesReady()) {
                                          Navigator.of(context)
                                              .pop(); // Close loading dialog
                                          SnackBarManager.showWarning(
                                            context: context,
                                            message:
                                                'Services are still initializing. Please wait a moment and try again.',
                                          );
                                          return;
                                        }

                                        int successCount = 0;
                                        int failCount = 0;
                                        List<String> errorMessages = [];

                                        for (int i = 0;
                                            i < pickedImages.length;
                                            i++) {
                                          try {
                                            Map<String, dynamic> result;

                                            if (isDesignTab) {
                                              print(
                                                  'Uploading design image with event ID: ${widget.event['id']}');
                                              result = await _galleryService!
                                                  .uploadDesignImage(
                                                imagePath: pickedImages[i].path,
                                                description: notesOrDesc,
                                                eventId: widget.event['id']
                                                    .toString(),
                                              );
                                            } else {
                                              print(
                                                  'Uploading final decoration image with event ID: ${widget.event['id']}');
                                              result = await _galleryService!
                                                  .uploadFinalDecorationImage(
                                                imagePath: pickedImages[i].path,
                                                description: notesOrDesc,
                                                eventId: widget.event['id']
                                                    .toString(),
                                              );
                                            }

                                            if (result['success']) {
                                              successCount++;
                                              // Add image to local state
                                              if (isDesignTab) {
                                                _designImages.add({
                                                  'image_path':
                                                      pickedImages[i].path,
                                                  'notes': notesOrDesc,
                                                  'api_data': result['data'],
                                                });
                                                setState(() {});
                                              } else {
                                                _finalDecorationImages.add({
                                                  'image_path':
                                                      pickedImages[i].path,
                                                  'description': notesOrDesc,
                                                  'api_data': result['data'],
                                                });
                                                setState(() {});
                                              }
                                            } else {
                                              failCount++;
                                              errorMessages.add(
                                                  'Image ${i + 1}: ${result['message'] ?? 'Upload failed'}');
                                            }
                                          } catch (e) {
                                            failCount++;
                                            errorMessages.add(
                                                'Image ${i + 1}: ${e.toString()}');
                                          }
                                        }

                                        // Close loading dialog
                                        Navigator.of(context).pop();

                                        // Show result message
                                        if (successCount > 0 &&
                                            failCount == 0) {
                                          // Show success dialog
                                          String imageType = isDesignTab
                                              ? 'design'
                                              : 'final decoration';
                                          _showUploadSuccessDialog(
                                              context, successCount, imageType);
                                        } else if (successCount > 0 &&
                                            failCount > 0) {
                                          SnackBarManager.showWarning(
                                            context: context,
                                            message:
                                                'Uploaded $successCount image(s), $failCount failed',
                                            duration:
                                                const Duration(seconds: 4),
                                          );
                                          Navigator.of(context)
                                              .pop(); // Close add dialog
                                          // Refresh images from server to show the newly uploaded images
                                          _refreshImages();
                                        } else {
                                          SnackBarManager.showError(
                                            context: context,
                                            message:
                                                'Failed to upload all images. ${errorMessages.first}',
                                            duration:
                                                const Duration(seconds: 5),
                                          );
                                        }
                                      } catch (e) {
                                        // Close loading dialog
                                        Navigator.of(context).pop();

                                        // Show error message
                                        SnackBarManager.showError(
                                          context: context,
                                          message:
                                              'An error occurred: ${e.toString()}',
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    // mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // const Icon(
                                      //   Icons.add,
                                      //   color: Colors.white,
                                      //   size: 20,
                                      // ),
                                      const SizedBox(width: 8),
                                      const Flexible(
                                        child: Text(
                                          'Upload Images',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUploadProgressDialog(
      BuildContext context, int totalImages, bool isDesignTab) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isDesignTab ? Icons.design_services : Icons.celebration,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Uploading Images...',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Progress indicator
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Uploading $totalImages image(s) to server...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we process your images',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
