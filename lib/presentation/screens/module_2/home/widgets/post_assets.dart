import 'dart:async';
import 'dart:ui' as ui;
import 'package:socialapp/utils/import.dart';

class PostAsset extends StatelessWidget {
  final PostModel post;
  final double postWidth;

  const PostAsset({super.key, required this.post, required this.postWidth});

  @override
  Widget build(BuildContext context) {
    switch (post.media.length) {
      case 0:
        return const ImageErrorPlaceholder();
      case 1:
        return PostSimpleImage(image: post.media[0], postWidth: postWidth,);
      case 2:
        return GridView.builder(
            itemCount: post.media.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              return PostSimpleImage(
                image: post.media[index], postWidth: postWidth,
              );
            });
      case 3:
        return GridView.builder(
            itemCount: post.media.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              return PostSimpleImage(
                image: post.media[index], postWidth: postWidth,
              );
            });
      default:
        List<Map<String, String>> allAssets = post.media;
        List<Map<String, String>> collapsedAssets =
            allAssets.getRange(0, min(4, post.media.length)).toList();
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280.0, maxWidth: 580.0),
          child: GridView.custom(
            semanticChildCount: 4,
            gridDelegate: SliverQuiltedGridDelegate(
              crossAxisCount: 4,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              repeatPattern: QuiltedGridRepeatPattern.inverted,
              pattern: [
                const QuiltedGridTile(2, 2),
                const QuiltedGridTile(1, 1),
                const QuiltedGridTile(1, 1),
                const QuiltedGridTile(1, 2),
              ],
            ),
            childrenDelegate: SliverChildBuilderDelegate(
              (context, index) {
                int? otherAssets;
                if (index == collapsedAssets.length - 1 &&
                    index != post.media.length - 1) {
                  otherAssets = allAssets.length - collapsedAssets.length;
                }
                return PostMultipleImage(
                  image: collapsedAssets[index],
                  otherAssets: otherAssets ?? 0,
                );
              },
              childCount: collapsedAssets.length,
            ),
          ),
        );
    }
  }
}

class PostMultipleImage extends StatelessWidget {
  final Map<String, String> image;
  final int? otherAssets;

  const PostMultipleImage({super.key, this.otherAssets, required this.image});

  @override
  Widget build(BuildContext context) {
    final Color dominantColor = Color(
      int.parse((image['dominantColor'] ?? '#FFCDD2').replaceFirst('#', '0xFF')),
    );

    return InkWell(
      onTap: () {},
      child: Stack(
        children: [
          Container(
            color: dominantColor,
            width: double.infinity,
            child: CachedNetworkImage(
              fit: BoxFit.fitWidth,
              imageUrl: image['url'] ?? '',
            ),
          ),
          if (otherAssets != null && otherAssets! > 0)
            Container(
              color: Colors.black.withOpacity(0.5),
              alignment: Alignment.center,
              child: Text(
                "+$otherAssets",
                style: AppTheme.topicLabelStyle,
              ),
            ),
        ],
      ),
    );
  }
}


class PostSimpleImage extends StatelessWidget {
  final Map<String, String> image;
  late double mediaWidth;
  final double postWidth;

  final ValueNotifier<double> containerHeight = ValueNotifier<double>(400);
  final double maxHeight = 400;
  final double horizontalPadding = 10;

  PostSimpleImage({super.key, required this.image, required this.postWidth});

  Future<ui.Image> _getImageInfo(String imageUrl) async {
    final image = NetworkImage(imageUrl);
    final imageStream = image.resolve(const ImageConfiguration());
    final completer = Completer<ui.Image>();
    imageStream.addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }),
    );
    return completer.future;
  }

  void _updateHeight(String imageUrl) async {
    final ui.Image image = await _getImageInfo(imageUrl);
    final double aspectRatio = image.width / image.height;

    if (aspectRatio > 1) {
      containerHeight.value = image.height.toDouble() * (mediaWidth / image.width) ;
    } else {
      containerHeight.value = maxHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    String imageUrl = image['url'] ?? '';
    mediaWidth = postWidth - horizontalPadding*2;
    final Color dominantColor = Color(
      int.parse((image['dominantColor'] ?? '#FFCDD2').replaceFirst('#', '0xFF')),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHeight(imageUrl);
    });

    return Padding(
      padding: AppTheme.horizontalPostContentPaddingEdgeInsets(horizontalPadding),
      child: InkWell(
        onTap: () {},
        child: ValueListenableBuilder<double>(
          valueListenable: containerHeight,
          builder: (context, height, child) {
            return Container(
              color: dominantColor,
              height: height,
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                errorWidget: (context, url, error) => const Icon(Icons.error),
                imageBuilder: (context, imageProvider) {
                  return FutureBuilder<ui.Image>(
                    future: _getImageInfo(imageUrl), // Fetch image dimensions
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return const Icon(Icons.error);
                      } else {
                        final ui.Image image = snapshot.data!;
                        final double aspectRatio = image.width / image.height;

                        if (aspectRatio > 1) {
                          return AspectRatio(
                            aspectRatio: aspectRatio,
                            child: Image(
                              image: imageProvider,
                              fit: BoxFit.fitWidth,
                            ),
                          );
                        } else {
                          return Container(
                            constraints: BoxConstraints(maxHeight: maxHeight),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.fitWidth,
                                )),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}