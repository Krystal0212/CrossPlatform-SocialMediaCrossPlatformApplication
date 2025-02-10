import 'package:socialapp/utils/import.dart';

import '../../../../widgets/display_images/display_image.dart';
import '../providers/home_properties_provider.dart';

class PostAsset extends StatefulWidget {
  final OnlinePostModel post;
  final double postWidth;

  const PostAsset({super.key, required this.post, required this.postWidth,});

  @override
  State<PostAsset> createState() => _PostAssetState();
}

class _PostAssetState extends State<PostAsset> with FlashMessage {
  late ValueNotifier<double> gridHeightNotifier;
  late double gridHeight = 280.0, deviceWidth = 0, deviceHeight = 0;
  late int mediaLength;
  late bool isWeb, isCachedData = false, isNSFWFilterTurnOn = true;

  late Map<String, OnlineMediaItem> media;

  @override
  void initState() {
    super.initState();

    mediaLength = widget.post.media?.length ?? 0;
    media = widget.post.media ?? {};

    if (widget.post.media?.isNotEmpty ?? false) {
      mediaLength = widget.post.media?.length ?? 0;
      media = widget.post.media ?? {};
      // isCachedData = widget.post.mediaOffline == null;
    }
    // else if (widget.post.mediaOffline != null && widget.post.mediaOffline!.isNotEmpty && !isWeb) {
    //   mediaLength = widget.post.media?.length ?? 0;
    //   media = widget.post.mediaOffline;
    //   isCachedData = true;
    // }
    else {
      mediaLength = 0;
      media = {};
      isCachedData = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isWeb = PlatformConfig.of(context)?.isWeb ?? false;

    gridHeight = isWeb ? gridHeight : 250;

    final flutterView = PlatformDispatcher.instance.views.first;
    deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    deviceHeight = flutterView.physicalSize.height;
  }

  @override
  Widget build(BuildContext context) {
    UserModel? currentUser = HomePropertiesProvider.of(context)?.currentUser;
    TextEditingController searchController = HomePropertiesProvider.of(context)!.searchController;
    if (currentUser != null) {
      isNSFWFilterTurnOn = currentUser.isNSFWFilterTurnOn;
    }

    switch (mediaLength) {
      case 0:
        if (widget.post.record != null) {
          return GestureDetector(
            onLongPress: (){
              UserModel? user =
                  HomePropertiesProvider.of(context)?.currentUser;

              if (user != null) {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => PostDetailScreen(
                      post: widget.post,
                      currentUser: user, searchController: searchController,
                    )));
              } else {
                showNotSignedInMessage(
                    context: context,
                    description:
                    AppStrings.notSignedInCollectionDescription);
              }
            },
            child: PostSimpleRecordWebsite(
              recordUrl: widget.post.record!,
            ),
          );
        } else {
          return NoPublicDataAvailablePlaceholder(width: deviceWidth);
        }
      case 1:
        OnlineMediaItem theAsset = media.values.first;
        Color dominantColor = Color(int.parse('0x${theAsset.dominantColor}'));

        bool isNSFW = theAsset.isNSFW;
        bool isNSFWAllowed = isNSFW && isNSFWFilterTurnOn;

        return GestureDetector(
          onLongPress: (){
            UserModel? user =
                HomePropertiesProvider.of(context)?.currentUser;

            if (user != null) {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => PostDetailScreen(
                    searchController: searchController,
                    post: widget.post,
                    currentUser: user,
                  )));
            } else {
              showNotSignedInMessage(
                  context: context,
                  description:
                  AppStrings.notSignedInCollectionDescription);
            }
          },
          child: Container(
            constraints: theAsset.width / theAsset.height > 1
                ? BoxConstraints(maxWidth: deviceWidth)
                : BoxConstraints(maxHeight: deviceHeight*0.3),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (theAsset.type == 'video')
                    ? AspectRatio(
                        aspectRatio: theAsset.width / theAsset.height,
                        child: VideoPlayerWidget(
                          isNSFWAllowed: isNSFWFilterTurnOn,
                          thumbnailUrl: theAsset.thumbnailUrl,
                          videoUrl: theAsset.imageUrl,
                          height: theAsset.height,
                          width: theAsset.width,
                          dominantColor: dominantColor,
                        ),
                      )
                    : ImageDisplayerWidget(

                        width: theAsset.width,
                        height: theAsset.height,
                        imageUrl: theAsset.imageUrl,
                        isVideo: false,
                        isNSFWAllowed: isNSFWAllowed,
                        dominantColor: dominantColor, videoUrl: null,
                      )),
          ),
        );
      default:
        final mediaList = media.values.toList();

        return SizedBox(
          height: 500,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: mediaList.length,
            itemBuilder: (context, index) {
              final media = mediaList[index];
              Color dominantColor =
                  Color(int.parse('0x${media.dominantColor}'));
              bool isNSFW = media.isNSFW;

              bool isNSFWAllowed = isNSFW && isNSFWFilterTurnOn;

              return GestureDetector(
                onLongPress: (){
                  UserModel? user =
                      HomePropertiesProvider.of(context)?.currentUser;

                  if (user != null) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PostDetailScreen(
                          post: widget.post,
                          currentUser: user, searchController: searchController,
                        )));
                  } else {
                    showNotSignedInMessage(
                        context: context,
                        description:
                        AppStrings.notSignedInCollectionDescription);
                  }
                },
                child: Container(
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
                              dominantColor:
                                  Color(int.parse('0x${media.dominantColor}')),
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
                ),
              );
            },
          ),
        );
    }
  }
}
