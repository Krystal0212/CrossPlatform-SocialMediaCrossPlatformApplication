

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:socialapp/utils/import.dart';

class ShotTab extends StatefulWidget {
  final List<String> imageUrls;

  const ShotTab({super.key, required this.imageUrls});

  @override
  State<ShotTab> createState() => _ShotTabState();
}

class _ShotTabState extends State<ShotTab> {
  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Center(child: SvgPicture.asset(AppImages.empty));
    } else {

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child:
        // StaggeredGridView.countBuilder(
        //   physics: const NeverScrollableScrollPhysics(),
        //   crossAxisCount: 2,
        //   itemCount: imageUrls.length,
        //   shrinkWrap: true,
        //   itemBuilder: (context, index) {
        //     return ClipRRect(
        //       borderRadius: BorderRadius.circular(10),
        //       child: CachedNetworkImage(
        //       imageUrl: imageUrls[index],
        //       fit: BoxFit.cover,
        //       placeholder: (context, url) =>
        //       const Center(child: CircularProgressIndicator()),
        //       errorWidget: (context, url, error) => const Icon(
        //           Icons.error), // Error widget if image fails to load
        //                         ),
        //     );
        //   },
        //   staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
        //   mainAxisSpacing: 16.0,
        //   crossAxisSpacing: 16.0, // Horizontal space between items
        // ),

        // GridView.custom(
        //   gridDelegate: SliverQuiltedGridDelegate(
        //     crossAxisCount: 2, // Changed to 2
        //     mainAxisSpacing: 16.0, // Space between rows
        //     crossAxisSpacing: 16.0, // Space between columns
        //     repeatPattern: QuiltedGridRepeatPattern.inverted,
        //     pattern: [
        //       QuiltedGridTile(2, 1),
        //       QuiltedGridTile(1, 1),
        //       QuiltedGridTile(1, 1),
        //       QuiltedGridTile(1, 2),
        //     ],
        //   ),
        //   childrenDelegate: SliverChildBuilderDelegate(
        //         (context, index) {
        //       return ClipRRect(
        //         borderRadius: BorderRadius.circular(10),
        //         child: CachedNetworkImage(
        //           imageUrl: imageUrls[index],
        //           fit: BoxFit.cover,
        //           placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
        //           errorWidget: (context, url, error) => const Icon(Icons.error), // Error widget if image fails to load
        //         ),
        //       );
        //     },
        //     childCount: imageUrls.length, // Total number of images
        //   ),)


        MasonryGridView.count(
          crossAxisCount: 2, // Updated crossAxisCount to 2
          mainAxisSpacing: 16.0, // Space between items vertically
          crossAxisSpacing: 16.0, // Space between items horizontally
          itemBuilder: (context, index) {
            if (index < widget.imageUrls.length) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: widget.imageUrls[index],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              );
            } else {
              return const SizedBox(); // Return an empty widget if index is out of bounds
            }
          },
        )


      );
    }
  }
}