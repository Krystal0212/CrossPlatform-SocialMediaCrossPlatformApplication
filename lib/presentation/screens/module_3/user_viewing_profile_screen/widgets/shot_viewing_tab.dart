import 'dart:ui';

import 'package:socialapp/utils/import.dart';

import '../../../../widgets/display_images/display_image.dart';
import '../../../module_2/home/providers/home_properties_provider.dart';
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

                UserModel? currentUser = HomePropertiesProvider.of(context)?.currentUser;


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
                          double imageWidth =
                          imagePreviews[index].width.toDouble();
                          double imageHeight = imagePreviews[index]
                              .height
                              .toDouble();
                          bool isVideo =
                              imagePreviews[index].isVideo;
                          bool isNSFW = imagePreviews[index].isNSFW;
                          Color dominantColor = Color(int.parse(
                              '0x${imagePreviews[index].dominantColor}'));

                          return ImageDisplayerWidget(
                            width: imageWidth,
                            height: imageHeight,
                            imageUrl: imagePreviews[index]
                                .mediasOrThumbnailUrl,
                            isVideo: isVideo,
                            isNSFWAllowed: (isNSFW &&
                                (currentUser?.isNSFWFilterTurnOn ??
                                    true)),
                            dominantColor: dominantColor,
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
