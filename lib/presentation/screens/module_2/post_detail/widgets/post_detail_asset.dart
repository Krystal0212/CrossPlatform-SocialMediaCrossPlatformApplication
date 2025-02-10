import 'package:socialapp/utils/import.dart';

import '../../../../widgets/display_images/display_image.dart';
import '../../home/providers/home_properties_provider.dart';

class PostDetailAsset extends StatelessWidget {
  final OnlinePostModel post;

  const PostDetailAsset({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    bool isNSFWFilterTurnOn = true;
    UserModel? currentUser = HomePropertiesProvider.of(context)?.currentUser;
    if (currentUser != null) {
      isNSFWFilterTurnOn = currentUser.isNSFWFilterTurnOn;
    }

    if (post.media != null && post.media!.isNotEmpty) {
      if (post.media!.length == 1) {
        final OnlineMediaItem media = post.media!.values.toList()[0];
        Color dominantColor = Color(int.parse('0x${media.dominantColor}'));
        bool isNSFW = media.isNSFW;

        UserModel? currentUser = HomePropertiesProvider.of(context)?.currentUser;
        final flutterView = PlatformDispatcher.instance.views.first;
        double deviceHeight = flutterView.physicalSize.height;

        return LayoutBuilder(builder: (context, constraints) {
          double maxWidth = constraints.maxWidth * 0.9;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 18),
            constraints: media.width / media.height > 1
                ? BoxConstraints(maxWidth: maxWidth)
                : BoxConstraints(maxHeight: deviceHeight*0.3),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (media.type == 'video')
                    ? AspectRatio(
                        aspectRatio: media.width / media.height,
                        child: VideoPlayerWidget(
                          isNSFWAllowed: isNSFWFilterTurnOn,
                          thumbnailUrl: media.thumbnailUrl,
                          videoUrl: media.imageUrl,
                          height: media.height,
                          width: media.width,
                          dominantColor:
                              Color(int.parse('0x${media.dominantColor}')),
                        ),
                      )
                    : ImageDisplayerWidget(
                        videoUrl: null,
                        width: media.width,
                        height: media.height,
                        imageUrl: media.imageUrl,
                        isVideo: false,
                        isNSFWAllowed: (isNSFW &&
                            (currentUser?.isNSFWFilterTurnOn ?? true)),
                        dominantColor: dominantColor,
                      )),
          );
        });
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
            Color dominantColor = Color(int.parse('0x${media.dominantColor}'));
            bool isNSFW = media.isNSFW;

            bool isNSFWAllowed = isNSFW && isNSFWFilterTurnOn;

            return Container(
              key: ValueKey(media.imageUrl), // Prevent unnecessary rebuilds
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (media.type == 'video')
                      ? VideoPlayerWidget(
                          isNSFWAllowed: isNSFWAllowed,
                          thumbnailUrl: media.thumbnailUrl,
                          videoUrl: media.imageUrl,
                          height: media.height,
                          width: media.width,
                          dominantColor: dominantColor,
                        )
                      : ImageDisplayerWidget(
                    videoUrl: null,
                          width: media.width,
                          height: media.height,
                          imageUrl: media.imageUrl,
                          isVideo: false,
                          isNSFWAllowed: isNSFWAllowed,
                          dominantColor: dominantColor,
                        )),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
