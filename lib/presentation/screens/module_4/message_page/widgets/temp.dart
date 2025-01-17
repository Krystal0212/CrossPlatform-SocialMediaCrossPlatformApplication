import 'dart:ui';
import 'package:socialapp/utils/import.dart';

class ImageDisplayGrid extends StatelessWidget with AppDialogs {
  final Map<String, dynamic> rawMediaData;

  const ImageDisplayGrid({super.key, required this.rawMediaData});

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    int mediaCount = rawMediaData.length;
    double maxWidth = deviceWidth * 0.7;

    if (mediaCount == 0) {
      return const SizedBox.shrink();
    } else if (mediaCount == 1) {
      final imageData = rawMediaData.entries.elementAt(0).value;
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: () => showImageDialog(context, imageData['imageUrl']),
          child:
              imageData['imageUrl'] != null && imageData['imageUrl'].isNotEmpty
                  ? Stack(
                      children: [
                        CachedNetworkImage(
                          imageUrl: imageData["imageUrl"],
                          fit: BoxFit.fitWidth,
                          placeholder: (context, url) => ChatImagePlaceholder(
                            maxWidth: maxWidth,
                            width: imageData['width'],
                            height: imageData['height'],
                            dominantColor: imageData['dominantColor'],
                            isLandscape: imageData['isLandscape'],
                          ),
                          errorWidget: (context, url, error) =>
                              const ImageErrorPlaceholder(),
                        ),
                        // if (imageData['isNSFW'] == true)
                        //   BlurredPlaceholder(
                        //     maxWidth: maxWidth,
                        //     width: imageData['width'],
                        //     height: imageData['height'],
                        //     dominantColor: imageData['dominantColor'],
                        //     isLandscape: imageData['isLandscape'],)
                      ],
                    )
                  : ChatImagePlaceholder(
                      maxWidth: deviceWidth * 0.7,
                      width: imageData['width'],
                      height: imageData['height'],
                      dominantColor: imageData['dominantColor'],
                      isLandscape: imageData['isLandscape'],
                    ),
        ),
      );
    } else {
      const crossAxisCount = 2;

      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: mediaCount,
        itemBuilder: (context, index) {
          final entry = rawMediaData.entries.elementAt(index);
          final imageData = entry.value;
          if (imageData['imageUrl'] != null &&
              imageData['imageUrl'].isNotEmpty) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: InkWell(
                onTap: () => showImageDialog(context, imageData['imageUrl']),
                child: Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageData['imageUrl'],
                      fit: BoxFit.fill,
                      placeholder: (context, url) => ChatImagePlaceholder(
                        width: deviceWidth * 0.3,
                        height: deviceWidth * 0.3,
                        isLandscape: imageData['isLandscape'],
                        dominantColor: imageData['dominantColor'],
                        maxWidth: null,
                      ),
                      errorWidget: (context, url, error) =>
                          const ImageErrorPlaceholder(),
                    ),
                    if (imageData['isNSFW'] == true)
                      BlurredPlaceholder(
                        maxWidth: maxWidth,
                        width: deviceWidth * 0.3,
                        height: deviceWidth * 0.3,
                        dominantColor: imageData['dominantColor'],
                        isLandscape: imageData['isLandscape'],
                      )
                  ],
                ),
              ),
            );
          } else if (imageData['dominantColor'] != null &&
              imageData['dominantColor'].isNotEmpty) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: ChatImagePlaceholder(
                width: deviceWidth * 0.3,
                height: deviceWidth * 0.3,
                isLandscape: imageData['isLandscape'],
                dominantColor: imageData['dominantColor'],
                maxWidth: null,
              ),
            );
          } else {
            return const ImageErrorPlaceholder();
          }
        },
      );
    }
  }
}

class ChatImagePlaceholder extends StatelessWidget {
  final double width, height;
  final double? maxWidth;
  final bool isLandscape;
  final String dominantColor;

  const ChatImagePlaceholder({
    super.key,
    this.width = 0.3,
    required this.dominantColor,
    required this.isLandscape,
    required this.height,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Color(int.parse('0x$dominantColor')),
      highlightColor: AppColors.white,
      child: Container(
        color: AppColors.corona,
        width: (width != height && maxWidth != null) ? maxWidth : width,
        height: (width != height && maxWidth != null)
            ? maxWidth! / (width / height)
            : height,
      ),
    );
  }
}

class BlurredPlaceholder extends StatelessWidget {
  final double width, height;
  final double? maxWidth;
  final bool isLandscape;
  final String dominantColor;

  const BlurredPlaceholder({
    super.key,
    this.width = 0.3,
    required this.dominantColor,
    required this.isLandscape,
    required this.height,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: maxWidth != null ? maxWidth! / (width / height) : height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              color: Color(int.parse('0x$dominantColor')).withOpacity(0.9),
              child: Center(
                child: Text('NSFW Content', style: AppTheme.nsfwWhiteText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
