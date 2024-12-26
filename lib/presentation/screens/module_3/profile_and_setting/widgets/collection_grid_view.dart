import 'package:socialapp/utils/import.dart';

class RadiusContainer extends StatefulWidget {
  final List<String?> imageUrls;

  const RadiusContainer({super.key, required this.imageUrls});

  @override
  State<RadiusContainer> createState() => _RadiusContainerState();
}

class _RadiusContainerState extends State<RadiusContainer> {
  late Future<List<String?>> _imageLoadFuture;

  @override
  void initState() {
    super.initState();
    _imageLoadFuture = _loadImages(widget.imageUrls);
  }

  Future<List<String?>> _loadImages(List<String?> imageUrls) async {
    // Simulate loading images (you can replace this with actual loading logic)
    await Future.delayed(const Duration(seconds: 2)); // Simulate network delay
    return imageUrls; // Return the imageUrls after loading
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: FutureBuilder<List<String?>>(
        future: _imageLoadFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading indicator
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading images')); // Handle error
          }

          // Get the actual image URLs after loading
          List<String?> loadedImages = snapshot.data ?? [];

          // Use ImageTilesGrid to display images
          return ImageTilesGrid(imageUrls: loadedImages);
        },
      ),
    );
  }
}

class ImageTilesGrid extends StatelessWidget {
  final List<String?> imageUrls;

  const ImageTilesGrid({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    // Case 1: No images
    if (imageUrls.isEmpty) {
      return const SingleTile(tile: AppColors.white);
    }

    // Case 2: 1 or 2 images
    if (imageUrls.length <= 2) {
      return SingleTile(tile: imageUrls.first);
    }

    // Case 3: 3 or more images
    return SizedBox(
      height: 200, // Set fixed height to prevent stretching
      child: GridView.builder(
        itemCount: 4,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 4.0, // Optional: Adjust spacing between grid items
          crossAxisSpacing: 4.0, // Optional: Adjust spacing between grid items
        ),
        itemBuilder: (context, index) {
          if (index < imageUrls.length) {
            return ImageTile(imageUrl: imageUrls[index]);
          } else {
            return const SingleTile(tile: AppColors.white);
          }
        },
        shrinkWrap: true, // Prevent GridView from taking infinite height
        physics: const NeverScrollableScrollPhysics(), // Disable scrolling
      ),
    );
  }
}

class ImageTile extends StatelessWidget {
  final String? imageUrl;

  const ImageTile({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.trolleyGrey,
        borderRadius: BorderRadius.circular(20), // Match the border radius
        image: imageUrl != null
            ? DecorationImage(
          image: CachedNetworkImageProvider(imageUrl!),
          fit: BoxFit.cover,
        )
            : null,
      ),
      clipBehavior: Clip.hardEdge, // Ensure the border radius is applied
    );
  }
}

class SingleTile extends StatelessWidget {
  final dynamic tile;

  const SingleTile({super.key, required this.tile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: tile is Color ? tile : AppColors.trolleyGrey,
        borderRadius: BorderRadius.circular(20),
        image: tile is String
            ? DecorationImage(
          image: CachedNetworkImageProvider(tile!),
          fit: BoxFit.cover,
        )
            : null,
      ),
    );
  }
}
