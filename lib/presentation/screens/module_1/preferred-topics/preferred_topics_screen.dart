// import '../../../widgets/edit_profile/bottom_rounded_appbar.dart';
import 'package:socialapp/presentation/screens/module_1/preferred-topics/widgets/topic_image_option.dart';
import 'package:socialapp/presentation/widgets/auth/auth_container.dart';
import 'package:socialapp/presentation/widgets/edit_profile/bottom_rounded_appbar.dart';
import 'package:socialapp/utils/import.dart';
import 'cubit/preferred_topic_cubit.dart';
import 'cubit/preferred_topic_state.dart';

class PreferredTopicsScreen extends StatefulWidget {
  const PreferredTopicsScreen({super.key});

  @override
  State<PreferredTopicsScreen> createState() => _PreferredTopicsScreenState();
}

class _PreferredTopicsScreenState extends State<PreferredTopicsScreen> {
  late double deviceWidth, deviceHeight;
  late List<Map<TopicModel, bool>> chosenTopics = [];
  late bool _isWeb, isSmallScreen;
  late int currentCount;
  late double tileSizeWidthRatio;

  final int minCount = 2;
  final double outerPaddingHorizontalRatio = 0.2;
  final double outerPaddingVerticalRatio = 0.05;
  final double innerPaddingHorizontalRatio = 0.075;
  final double innerPaddingVerticalRatio = 0.025;

  @override
  void initState() {
    FlutterNativeSplash.remove();
    super.initState();
    fetchTopicData();
  }

  void fetchTopicData() async {
    chosenTopics = await context.read<PreferredTopicCubit>().fetchTopicsData();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    _isWeb = PlatformConfig.of(context)?.isWeb ?? false;

    isSmallScreen = ((_isWeb && deviceWidth < 550) || (!_isWeb));
    tileSizeWidthRatio = deviceWidth < 800 ? (260 / 1530) : (190 / 1530);

    currentCount = ((1 -
                outerPaddingHorizontalRatio * 2 -
                innerPaddingVerticalRatio * 2) ~/
            tileSizeWidthRatio)
        .toInt();

    if (kDebugMode) {
      print(
          "$isSmallScreen $deviceWidth Have $currentCount chose ${max(currentCount, minCount)}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: BackgroundContainer(
      center: AuthContainer(
        isSmallView: isSmallScreen,
        deviceWidth: deviceWidth,
        deviceHeight: deviceHeight,
        padding: AppTheme.preferredTopicWebsitePaddingEdgeInsets(
            deviceWidth,
            deviceHeight,
            outerPaddingHorizontalRatio,
            outerPaddingVerticalRatio),
        child: Stack(
          children: [
            Container(
              padding: (isSmallScreen)
                  ? AppTheme.preferredTopicMobilePaddingEdgeInsets
                  : AppTheme.preferredTopicWebsitePaddingEdgeInsets(
                      deviceWidth,
                      deviceHeight,
                      innerPaddingHorizontalRatio,
                      innerPaddingVerticalRatio),
              width: deviceWidth,
              height: deviceHeight,
              color: AppColors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.titlePreferredTopicMessage,
                    style: AppTheme.categoryLabelStyle,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  BlocBuilder<PreferredTopicCubit, PreferredTopicState>(
                      builder: (context, state) {
                    if (state is GetTopicLoading) {
                      return const Expanded(
                        child: Center(
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: AppColors.blueDeFrance,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      );
                    } else if (state is GetTopicSuccess) {
                      return Expanded(
                        child: GridView.builder(
                          itemCount: chosenTopics.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isSmallScreen
                                ? minCount
                                : max(currentCount, minCount),
                            mainAxisSpacing: isSmallScreen ? 20 : 28,
                            crossAxisSpacing: isSmallScreen ? 20 : 28,
                            childAspectRatio: 1,
                          ),
                          itemBuilder: (context, index) {
                            Map<TopicModel, bool> currentTopicMap =
                                chosenTopics[index];
                            TopicModel topic =
                                currentTopicMap.entries.first.key;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  chosenTopics
                                      .where((topicElement) =>
                                          topicElement.keys.first == topic)
                                      .forEach((topicElement) {
                                    topicElement[topic] =
                                        !(topicElement[topic] ?? false);
                                  });
                                });
                                if (kDebugMode) {
                                  print(
                                      "Category ID pressed: ${topic.topicId}");
                                }
                              },
                              child: TopicImageOption(
                                currentTopicMap: currentTopicMap,
                                topic: topic,
                              ),
                            );
                          },
                        ),
                      );
                    } else {
                      return const AppPlaceHolder();
                    }
                  }),
                  const SizedBox(
                    height: 40,
                  ),
                  BlocBuilder<PreferredTopicCubit, PreferredTopicState>(
                      builder: (context, state) {
                    return state is GetTopicSuccess
                        ? AuthElevatedButton(
                            width: deviceWidth,
                            height: 42,
                            inputText: "EXPLORE NOW",
                            isLoading: state is AddUserLoading,
                            onPressed: () => context
                                .read<PreferredTopicCubit>()
                                .addCurrentUserData(context, chosenTopics))
                        : Opacity(
                            opacity: 0.5,
                            child: AuthElevatedButton(
                                width: deviceWidth,
                                height: 42,
                                inputText: "EXPLORE NOW",
                                isLoading: false,
                                onPressed: () {}));
                  })
                ],
              ),
            ),
            if (isSmallScreen)
              const BottomRoundedAppBar(
                  bannerPath: AppImages.editProfileAppbarBackground),
          ],
        ),
      ),
    ));
  }
}
