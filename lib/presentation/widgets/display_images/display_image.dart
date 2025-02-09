import 'dart:ui';

import 'package:socialapp/utils/import.dart';

class ImageDisplayerWidget extends StatelessWidget {
  final String imageUrl;
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
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: width / height,
      // Maintains the correct width/height ratio
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
    );
  }
}
