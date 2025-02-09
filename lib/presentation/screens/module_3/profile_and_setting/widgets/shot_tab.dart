import 'dart:ui';

import 'package:socialapp/utils/import.dart';

import '../../../../widgets/display_images/display_image.dart';
import '../cubit/shot_cubit.dart';
import '../cubit/shot_state.dart';

class ShotTab1 extends StatefulWidget {
  final String userId;

  const ShotTab1({super.key, required this.userId});

  @override
  State<ShotTab1> createState() => _ShotTab1State();
}

class _ShotTab1State extends State<ShotTab1>
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

    return BlocProvider(
      create: (context) => ShotPostCubit(userId: widget.userId),
      child: Padding(
        padding: EdgeInsets.only(
          top: 30,
          left: deviceWidth * 0.07,
          right: deviceWidth * 0.07,
        ),
        child: SingleChildScrollView(
          child: BlocBuilder<ShotPostCubit, ShotPostState>(
            builder: (context, state) {
              if (state is ShotPostLoaded) {
                return StreamBuilder<List<PreviewAssetPostModel>?>(
                    stream: state.postStreams,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: deviceHeight * 0.3,
                          child: const Center(
                              child: CircularProgressIndicator(
                            color: AppColors.iris,
                          )),
                        );
                      }

                      if (snapshot.hasError ||
                          !snapshot.hasData ||
                          snapshot.data!.isEmpty) {
                        return NoPublicDataAvailablePlaceholder(
                          width: deviceWidth * 0.9,
                        );
                      }

                      List<PreviewAssetPostModel> imagePreviews =
                          snapshot.data!;

                      return FutureBuilder<UserModel?>(
                          future: serviceLocator<UserRepository>()
                              .getCurrentUserData(),
                          builder: (context, userSnapshot) {
                            UserModel? currentUser = userSnapshot.data;

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
                                SizedBox(
                                  height: deviceHeight * 0.02,
                                )
                              ],
                            );
                          });
                    });
              }
              return Center(child: SvgPicture.asset(AppImages.empty));
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Keep the widget alive
}
