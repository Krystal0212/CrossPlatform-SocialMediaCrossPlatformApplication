import 'dart:ui';

import 'package:socialapp/utils/import.dart';

class ImageDisplayGrid extends StatelessWidget with AppDialogs {
  final Map<String, dynamic> rawMediaData;

  const ImageDisplayGrid({super.key, required this.rawMediaData});

  @override
  Widget build(BuildContext context) {
    int mediaCount = rawMediaData.length;

    if (mediaCount == 1) {
      return SingleImageDisplay(
        rawMediaData: rawMediaData,
      );
    } else if (mediaCount >= 2) {
      return ImageGridview(
        mediaCount: mediaCount,
        rawMediaData: rawMediaData,
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

class SingleImageDisplay extends StatelessWidget with AppDialogs {
  final Map<String, dynamic> rawMediaData;

  const SingleImageDisplay({super.key, required this.rawMediaData});

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double maxWidth = deviceWidth * 0.6;
    final imageData = rawMediaData.entries.elementAt(0).value;
    final imageWidth = maxWidth;
    // final imageWidth = (maxWidth < imageData['width']) ? maxWidth : imageData['width'];
    final imageHeight = (maxWidth < imageData['width'])
        ? maxWidth / (imageData['width'] / imageData['height'])
        : imageData['height'];

    return SizedBox(
      width: imageWidth,
      child: ClipRRect(
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
                            width: imageWidth,
                            height: imageHeight,
                            dominantColor: imageData['dominantColor'],
                            isLandscape: imageData['isLandscape'],
                          ),
                          errorWidget: (context, url, error) =>
                              const ImageErrorPlaceholder(),
                        ),
                        if (imageData['isNSFW'] == true)
                          Center(
                            child: BlurredPlaceholder(
                              // maxWidth: maxWidth,
                              width: imageWidth,
                              height: imageHeight,
                              dominantColor: imageData['dominantColor'],
                              isLandscape: imageData['isLandscape'],
                            ),
                          )
                      ],
                    )
                  : ChatImagePlaceholder(
                      width: imageWidth,
                      height: imageHeight,
                      dominantColor: imageData['dominantColor'],
                      isLandscape: imageData['isLandscape'],
                    ),
        ),
      ),
    );
  }
}

class ImageGridview extends StatelessWidget with AppDialogs {
  final int mediaCount;
  final Map<String, dynamic> rawMediaData;

  const ImageGridview(
      {super.key, required this.mediaCount, required this.rawMediaData});

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    final imageWidth = deviceWidth * 0.26;
    final imageHeight = deviceWidth * 0.26;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: mediaCount,
      itemBuilder: (context, index) {
        final entry = rawMediaData.entries.elementAt(index);
        final imageData = entry.value;
        if (imageData['imageUrl'] != null && imageData['imageUrl'].isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: InkWell(
              onTap: () => showImageDialog(context, imageData['imageUrl']),
              child: Container(
                color: Colors.blue,
                width: imageWidth,
                height: imageHeight,
                child: Stack(
                  // Ensure the children expand to fill the Stack
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imageData['imageUrl'],
                      fit: BoxFit.cover, // Cover the entire container
                      placeholder: (context, url) => ChatImagePlaceholder(
                        width: imageWidth,
                        height: imageHeight,
                        isLandscape: imageData['isLandscape'],
                        dominantColor: imageData['dominantColor'],
                      ),
                      errorWidget: (context, url, error) =>
                          const ImageErrorPlaceholder(),
                    ),
                    if (imageData['isNSFW'] == true)
                      BlurredPlaceholder(
                        width: imageWidth,
                        height: imageHeight,
                        dominantColor: imageData['dominantColor'],
                        isLandscape: imageData['isLandscape'],
                      )
                  ],
                ),
              ),
            ),
          );
        } else if (imageData['dominantColor'] != null &&
            imageData['dominantColor'].isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: ChatImagePlaceholder(
              width: imageWidth,
              height: imageHeight,
              isLandscape: imageData['isLandscape'],
              dominantColor: imageData['dominantColor'],
            ),
          );
        } else {
          return const ImageErrorPlaceholder();
        }
      },

      //   itemBuilder: (context, index) {
      //     final entry = rawMediaData.entries.elementAt(index);
      //     final imageData = entry.value;
      //     if (imageData['imageUrl'] != null &&
      //         imageData['imageUrl'].isNotEmpty) {
      //       return ClipRRect(
      //         borderRadius: BorderRadius.circular(12.0),
      //         child: InkWell(
      //           onTap: () => showImageDialog(context, imageData['imageUrl']),
      //           child: CachedNetworkImage(
      //             imageUrl: imageData['imageUrl'],
      //             fit: BoxFit.cover,
      //             placeholder: (context, url) => ChatImagePlaceholder(
      //               width: deviceWidth * 0.3,
      //               height: deviceWidth * 0.3,
      //               isLandscape: imageData['isLandscape'],
      //               dominantColor: imageData['dominantColor'],
      //             ),
      //             errorWidget: (context, url, error) =>
      //                 const ImageErrorPlaceholder(),
      //           ),
      //         ),
      //       );
      //     }
      //     else if (imageData['dominantColor'] != null &&
      //         imageData['dominantColor'].isNotEmpty) {
      //       return ClipRRect(
      //         borderRadius: BorderRadius.circular(12.0),
      //         child: ChatImagePlaceholder(
      //           width: deviceWidth * 0.3,
      //           height: deviceWidth * 0.3,
      //           isLandscape: imageData['isLandscape'],
      //           dominantColor: imageData['dominantColor'],
      //         ),
      //       );
      //     }
      //     else {
      //       return const ImageErrorPlaceholder();
      //     }
      //   },
    );
  }
}

class ChatImagePlaceholder extends StatelessWidget {
  final double width, height;
  final bool isLandscape;
  final String dominantColor;

  const ChatImagePlaceholder({
    super.key,
    this.width = 0.3,
    required this.dominantColor,
    required this.isLandscape,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Color(int.parse('0x$dominantColor')),
        highlightColor: AppColors.white,
        child: Container(
          color: AppColors.corona,
          width: width,
          height: height,
        ));
  }
}

class BlurredPlaceholder extends StatelessWidget {
  final double width, height;
  final bool isLandscape;
  final String dominantColor;

  const BlurredPlaceholder({
    super.key,
    this.width = 0.3,
    required this.dominantColor,
    required this.isLandscape,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
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
