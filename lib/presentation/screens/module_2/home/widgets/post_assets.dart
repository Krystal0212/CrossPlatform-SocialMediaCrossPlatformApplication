import 'dart:async';
import 'dart:ui' as ui;
import 'package:socialapp/utils/import.dart';

class PostAsset extends StatefulWidget {
  final PostModel post;
  final double postWidth;

  const PostAsset({super.key, required this.post, required this.postWidth});

  @override
  State<PostAsset> createState() => _PostAssetState();
}

class _PostAssetState extends State<PostAsset> {
  late GlobalKey _gridKey;
  late ValueNotifier<double> gridHeightNotifier;
  double gridHeight = 280.0;
  late int mediaLength;
  late bool isWeb, isCachedData;

  late List<Map<String, String>>? media;

  @override
  void initState() {
    super.initState();

    mediaLength = widget.post.media!.length;
    media = widget.post.media;

    if (widget.post.media != null && widget.post.media!.isNotEmpty) {
      mediaLength = widget.post.media?.length ?? 0;
      media = widget.post.media;
      isCachedData = widget.post.mediaOffline == null;
    } else if (widget.post.mediaOffline != null && widget.post.mediaOffline!.isNotEmpty && !isWeb) {
      mediaLength = widget.post.media?.length ?? 0;
      media = widget.post.mediaOffline;
      isCachedData = true;
    } else {
      mediaLength = 0;
      media = null;
      isCachedData = false;
    }

    _gridKey = GlobalKey();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    isWeb = PlatformConfig.of(context)?.isWeb ?? false;
    gridHeight = isWeb ? gridHeight : 178;
  }

  @override
  Widget build(BuildContext context) {
    switch (mediaLength) {
      case 0:
        return const ImageErrorPlaceholder();
      case 1:
        return PostSimpleImage(
            image: media?[0] ?? {}, postWidth: widget.postWidth, isCachedData: isCachedData,);
      case 2:
        return GridView.builder(
            itemCount: mediaLength,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              return PostSimpleImage(
                image: media?[index] ?? {},
                postWidth: widget.postWidth, isCachedData: isCachedData,
              );
            });
      case 3:
        return GridView.builder(
            itemCount: mediaLength,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              return PostSimpleImage(
                image: media?[index] ?? {},
                postWidth: widget.postWidth, isCachedData: isCachedData,
              );
            });
      default:
        List<Map<String, String>> allAssets = media ?? [];
        List<Map<String, String>> collapsedAssets =
            allAssets.getRange(0, min(4, mediaLength)).toList();
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: gridHeight, maxWidth: 580.0),
          child: GridView.custom(
            key: _gridKey,
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
                    index != mediaLength - 1) {
                  otherAssets = allAssets.length - collapsedAssets.length;
                }
                return PostMultipleImage(
                  image: collapsedAssets[index],
                  otherAssets: otherAssets ?? 0, isCachedData: isCachedData,
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
  final bool isCachedData;

  const PostMultipleImage({
    super.key,
    this.otherAssets,
    required this.image, required this.isCachedData,
  });

  @override
  Widget build(BuildContext context) {
    final Color dominantColor = Color(
      int.parse(
          (image['dominantColor'] ?? '#FFCDD2').replaceFirst('#', '0xFF')),
    );

    return InkWell(
      onTap: () {},
      child: Stack(
        children: [
          Container(
              color: dominantColor,
              width: double.infinity,
              child: isCachedData ? Image.file(File(image['uri'] ?? '')):
          CachedNetworkImage(imageUrl: image['url']?? '')),
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
  final Map<String, dynamic> image;
  final double postWidth;
  final bool isCachedData;

  final ValueNotifier<double> containerHeight = ValueNotifier<double>(400);
  final double maxHeight = 370;
  final double horizontalPadding = 10;

  PostSimpleImage(
      {super.key,
      required this.image,
      required this.postWidth,
      required this.isCachedData});

  void _updateHeight(ImageProvider imageProvider, double mediaWidth) async {
    try {
      final int imageWidth = image['width']!;
      final int imageHeight = image['height'];
      final double aspectRatio = imageWidth / imageHeight;

      if (aspectRatio > 1) {
        containerHeight.value =
            imageHeight.toDouble() * (mediaWidth / imageWidth);
      } else {
        containerHeight.value = maxHeight;
      }
    } catch (error) {
      containerHeight.value = maxHeight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double mediaWidth = postWidth - horizontalPadding * 2;
    final String imageUrl = isCachedData? (image['uri'] ?? '') : (image['url'] ?? '') ;

    final Color dominantColor = Color(
      int.parse(
          (image['dominantColor'] ?? '#FFCDD2').replaceFirst('#', '0xFF')),
    );

    final ImageProvider imageProvider = isCachedData
        ? FileImage(File(imageUrl))
        : CachedNetworkImageProvider(imageUrl);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHeight(imageProvider, mediaWidth);
    });

    return Padding(
      padding:
          AppTheme.horizontalPostContentPaddingEdgeInsets(horizontalPadding),
      child: InkWell(
        onTap: () {},
        child: ValueListenableBuilder<double>(
          valueListenable: containerHeight,
          builder: (context, height, child) {
            return Container(
              color: dominantColor,
              height: height,
              width: double.infinity,
              child: Image(
                image: imageProvider,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.error),
              ),
            );
          },
        ),
      ),
    );
  }
}
