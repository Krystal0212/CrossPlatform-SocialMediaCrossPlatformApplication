import 'package:socialapp/utils/import.dart';

class PostDetailAsset extends StatelessWidget {
  final OnlinePostModel post;

  const PostDetailAsset({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    if (post.media != null && post.media!.isNotEmpty) {
      if (post.media!.length == 1) {
        final OnlineMediaItem media = post.media!.values.toList()[0];
        return LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth * 0.9;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 18),
              constraints: media.width / media.height > 1
                  ? BoxConstraints(maxWidth: maxWidth)
                  : null,
              child: AspectRatio(
                aspectRatio: media.width / media.height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: media.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Color(int.parse('0x${media.dominantColor}')),
                    ),
                    errorWidget: (context, url, error) =>
                        const ImageErrorPlaceholder(),
                  ),
                ),
              ),
            );
          },
        );
      }

      final mediaList = post.media!.values.toList();

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        height: 500,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: mediaList.length + 2,
          itemBuilder: (context, index) {
            if (index == 0 || index == mediaList.length + 1) {
              return const SizedBox(width: 130);
            }
            final media = mediaList[index - 1];
            return Container(
              key: ValueKey(media.imageUrl), // Prevent unnecessary rebuilds
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AspectRatio(
                aspectRatio: media.width / media.height,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CachedNetworkImage(
                          imageUrl: media.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Color(int.parse('0x${media.dominantColor}')),
                          ),
                          errorWidget: (context, url, error) =>
                              const ImageErrorPlaceholder(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}