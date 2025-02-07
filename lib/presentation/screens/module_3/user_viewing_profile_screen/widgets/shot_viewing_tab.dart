import 'dart:ui';

import 'package:socialapp/utils/import.dart';

import '../cubit/shot_viewing_state.dart';
import '../cubit/shot_viewing_cubit.dart';

class ShotViewingTab extends StatefulWidget {
  final String userId;

  const ShotViewingTab({super.key, required this.userId});

  @override
  State<ShotViewingTab> createState() => _ShotViewingTabState();
}

class _ShotViewingTabState extends State<ShotViewingTab>
    with AutomaticKeepAliveClientMixin {
  late double deviceHeight = 0, deviceWidth = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return BlocProvider(
      create: (context) => ShotViewingPostCubit(userId: widget.userId),
      child: Padding(
        padding: EdgeInsets.only(
            top: 30, left: deviceWidth * 0.07, right: deviceWidth * 0.07,

        ),
        child: SingleChildScrollView(
          child: BlocBuilder<ShotViewingPostCubit, ShotViewingPostState>(
            builder: (context, state) {
              if(state is ShotViewingPostLoading || state is ShotViewingPostInitial){
                return  SizedBox(
                  height: deviceHeight*0.3,
                  child: const Center(child: CircularProgressIndicator(
                    color: AppColors.iris,
                  )),
                );
              } else
              if (state is ShotViewingPostLoaded) {
                List<PreviewAssetPostModel> imagePreviews = state.posts;

                return Column(
                  children: [
                    MasonryGridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: imagePreviews.length,
                      mainAxisSpacing: 16.0,
                      crossAxisSpacing: 16.0,
                      itemBuilder: (context, index) {
                        if (index < imagePreviews.length) {
                          double imageWidth = imagePreviews[index].width.toDouble();
                          double imageHeight =
                              imagePreviews[index].height.toDouble();
                          double aspectRatio = imageWidth / imageHeight;
                          bool isVideo = imagePreviews[index].isVideo;
                          bool isNSFW = imagePreviews[index].isNSFW;
                          Color dominantColor = Color(
                              int.parse('0x${imagePreviews[index].dominantColor}'));

                          final ValueNotifier<bool> isBlurredNotifier =
                              ValueNotifier<bool>(true);

                          return AspectRatio(
                            aspectRatio: aspectRatio,
                            // Maintains the correct width/height ratio
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        imagePreviews[index].mediasOrThumbnailUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: AppColors.blackOak,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),

                                // Show Play Icon if it's a video
                                if (isVideo)
                                  const Icon(
                                    Icons.play_circle_fill,
                                    size: 50,
                                    color: Colors.white,
                                  ),

                                if (isNSFW)
                                  ValueListenableBuilder<bool>(
                                    valueListenable: isBlurredNotifier,
                                    builder: (context, isBlurred, child) {
                                      return GestureDetector(
                                        onTap: () =>
                                            isBlurredNotifier.value = false,
                                        // Toggle blur
                                        child: Stack(
                                          children: [
                                            TweenAnimationBuilder<double>(
                                              duration:
                                                  const Duration(milliseconds: 500),
                                              // Smooth transition
                                              tween: Tween<double>(
                                                  begin: isBlurred ? 10.0 : 10.0,
                                                  end: isBlurred ? 10.0 : 0.0),
                                              builder: (context, blurValue, child) {
                                                return AnimatedOpacity(
                                                  duration: const Duration(
                                                      milliseconds: 4300),
                                                  opacity: isBlurred ? 1.0 : 0.0,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(10),
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                        sigmaX: blurValue,
                                                        sigmaY: blurValue,
                                                      ),
                                                      child: Container(
                                                        color: dominantColor
                                                            .withOpacity(isBlurred
                                                                ? 0.7
                                                                : 0.0),
                                                        alignment: Alignment.center,
                                                        child: isBlurred
                                                            ? Text(
                                                                'NSFW Content',
                                                                style: AppTheme
                                                                    .nsfwWhiteText,
                                                                textAlign: TextAlign
                                                                    .center,
                                                              )
                                                            : null,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                    SizedBox(height: deviceHeight*0.02,)
                  ],
                );
              }
              return NoPublicDataAvailablePlaceholder(width: deviceWidth*0.9,);
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Keep the widget alive
}
