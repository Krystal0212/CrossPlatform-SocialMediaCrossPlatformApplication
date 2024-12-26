

import 'package:socialapp/utils/import.dart';

import 'collection_grid_view.dart';

class CollectionTab extends StatefulWidget {
  final List<CollectionModel> collections;

  const CollectionTab({super.key, required this.collections});

  @override
  State<CollectionTab> createState() => _CollectionTabState();
}

class _CollectionTabState extends State<CollectionTab> {
  late CollectionRepository collectionRepository;
  late PostRepository postRepository;
  late Map<String, List<String?>> collectionImagesMap;

  @override
  void initState() {
    super.initState();
    collectionRepository = CollectionRepositoryImpl();
    postRepository = PostRepositoryImpl();
    collectionImagesMap = {};
    fetchAllCollectionImages();
  }

  Future<void> fetchAllCollectionImages() async {
    for (var collection in widget.collections) {
      List<String?> collectionPostImages = await getImagesOfCollection(collection.collectionId);
      setState(() {
        collectionImagesMap[collection.collectionId] = collectionPostImages;
      });
    }
  }

  Future<List<String?>> getImagesOfCollection(String collectionID) async {
    List<String?> collectionPostImages = [];
    List<String> collectionPostsID = await collectionRepository.getCollectionPostsID(collectionID);
    for (String postId in collectionPostsID) {
      String? imageUrls = await postRepository.getPostImageById(postId);
      collectionPostImages.add(imageUrls);
    }
    return collectionPostImages;
  }

  SliverGridDelegateWithFixedCrossAxisCount get collectionDelegates =>
      const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Adjust the number of columns as needed
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
      );

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: collectionDelegates,
      itemCount: widget.collections.length,
      itemBuilder: (context, index) {
        final collection = widget.collections[index];

        return FutureBuilder<List<String?>>(
          future: Future.value(
              collectionImagesMap[collection.collectionId] ?? []), // Ensure non-null value
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading images'));
            }

            List<String?>? collectionPostImages = snapshot.data ?? [];

            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: GridTile(
                    child: RadiusContainer(imageUrls: collectionPostImages),
                  ),
                ),
                Center(
                  child: Text(collection.name, style: AppTheme.gridItemStyle),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
