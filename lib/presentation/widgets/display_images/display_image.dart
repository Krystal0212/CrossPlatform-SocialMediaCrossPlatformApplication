import 'dart:ui';

import 'package:socialapp/utils/import.dart';

class ImageDisplayerWidget extends StatelessWidget {
  final String imageUrl;
  final String? videoUrl;
  final bool isVideo;
  final bool isNSFWAllowed;
  final Color dominantColor;
  final double width, height;


  const ImageDisplayerWidget({
    super.key,
    required this.imageUrl,
    required this.isVideo,
    required this.isNSFWAllowed,
    required this.dominantColor,
    required this.width,
    required this.height,
    required this.videoUrl,
  });

  void showImageDialog(
      BuildContext context,
      String imageUrl,
      Color dominantColor,
      String? videoUrl,
      ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final flutterView = PlatformDispatcher.instance.views.first;
        final deviceWidth =
            flutterView.physicalSize.width / flutterView.devicePixelRatio;
        final deviceHeight =
            flutterView.physicalSize.height / flutterView.devicePixelRatio;

        double scaleRatio = 0.75;

        // Calculate the aspect ratio (width/height)
        double imageAspectRatio = width / height; // Replace with actual image's width/height

        // Padding based on aspect ratio, ensuring the image fits the dialog
        double horizontalPadding = (deviceWidth * scaleRatio) * 0.1;
        double verticalPadding = horizontalPadding;

        // If image is landscape (aspect ratio > 1), adjust the padding so it doesn't overflow
        if (imageAspectRatio > 1) {
          verticalPadding = deviceHeight * scaleRatio * 0.1;
        } else {
          horizontalPadding = deviceWidth * scaleRatio * 0.1;
        }

        return Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: (isVideo) ? VideoPlayerWidget(
                videoUrl: videoUrl,
                height: height,
                width: width,
                dominantColor: dominantColor,
                isNSFWAllowed: isNSFWAllowed,
              ) : ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    color: dominantColor,
                  ),
                  errorWidget: (context, url, error) =>
                  const Icon(Icons.error),
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if(!isNSFWAllowed) {
          showImageDialog(context, imageUrl, dominantColor, videoUrl);
        }
      },
      child: AspectRatio(
        aspectRatio: width / height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.blackOak,
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),

            // Show Play Icon if it's a video
            if (isVideo)
              const Icon(
                Icons.play_circle_fill,
                size: 50,
                color: Colors.white,
              ),

            if (isNSFWAllowed)
              Stack(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 4300),
                    opacity: 1.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10.0,
                          sigmaY: 10.0,
                        ),
                        child: Container(
                            color: dominantColor.withOpacity(0.7),
                            alignment: Alignment.center,
                            child: Text(
                              'NSFW Content',
                              style: AppTheme.nsfwWhiteText,
                              textAlign: TextAlign.center,
                            )),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
