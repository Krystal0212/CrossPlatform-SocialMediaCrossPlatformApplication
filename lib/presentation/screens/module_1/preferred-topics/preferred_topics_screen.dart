import 'package:socialapp/presentation/screens/module_1/preferred-topics/widgets/topic_image_option.dart';
import 'package:socialapp/presentation/widgets/auth/auth_container.dart';
import 'package:socialapp/presentation/widgets/edit_profile/bottom_rounded_appbar.dart';
import 'package:socialapp/utils/import.dart';
import '../../../widgets/general/custom_placeholder.dart';
import 'cubit/preferred_topic_cubit.dart';
import 'cubit/preferred_topic_state.dart';

class PreferredTopicsScreen extends StatefulWidget {
  const PreferredTopicsScreen({super.key});

  @override
  State<PreferredTopicsScreen> createState() => _PreferredTopicsScreenState();
}

class _PreferredTopicsScreenState extends State<PreferredTopicsScreen> {
  late double deviceWidth, deviceHeight;
  late ValueNotifier<List<Map<TopicModel, bool>>> chosenTopics;
  late bool _isWeb, isSmallScreen;
  late int currentCount;
  late double tileSizeWidthRatio;
  late ValueNotifier<bool> isButtonEnable;

  final int minCount = 2;
  final double outerPaddingHorizontalRatio = 0.2;
  final double outerPaddingVerticalRatio = 0.05;
  final double innerPaddingHorizontalRatio = 0.075;
  final double innerPaddingVerticalRatio = 0.025;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    chosenTopics = ValueNotifier([]);
    isButtonEnable = ValueNotifier<bool>(false);
    fetchTopicData();
  }

  void fetchTopicData() async {
    final topics = await context.read<PreferredTopicCubit>().fetchTopicsData();
    chosenTopics.value = topics;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    _isWeb = PlatformConfig.of(context)?.isWeb ?? false;

    isSmallScreen = ((_isWeb && deviceWidth < 550) || (!_isWeb));

    if (deviceWidth < 530) {
      tileSizeWidthRatio = 0.275;
    } else if (deviceWidth < 800) {
      tileSizeWidthRatio = 0.17;
    } else {
      tileSizeWidthRatio = 0.124;
    }

    currentCount = ((1 -
                outerPaddingHorizontalRatio * 2 -
                innerPaddingVerticalRatio * 2) ~/
            tileSizeWidthRatio)
        .toInt();
  }

  @override
  void dispose() {
    chosenTopics.dispose();
    super.dispose();
  }

  bool is5ItemsChosen() {
    return chosenTopics.value
            .where((topicMap) => topicMap.values.first == true)
            .length ==
        5;
  }

  void handleTopicSelection(
      List<Map<TopicModel, bool>> value,
      TopicModel topic,
      ValueNotifier<List<Map<TopicModel, bool>>> chosenTopics,
      bool Function() is5ItemsChosen) {
    final updatedTopics = List<Map<TopicModel, bool>>.from(value);
    bool changeToFalse = updatedTopics.any((topicElement) {
      if (topicElement.keys.first == topic && topicElement[topic] == true) {
        return true;
      }
      return false;
    });

    if (!is5ItemsChosen() || changeToFalse) {
      for (Map<TopicModel, bool> topicElement in updatedTopics) {
        if (topicElement.keys.first == topic) {
          topicElement[topic] = !(topicElement[topic] ?? false);
        }
      }
      isButtonEnable.value = is5ItemsChosen();
      chosenTopics.value = updatedTopics;
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
            outerPaddingVerticalRatio,
          ),
          child: Stack(
            children: [
              Container(
                padding: isSmallScreen
                    ? AppTheme.preferredTopicMobilePaddingEdgeInsets
                    : AppTheme.preferredTopicWebsitePaddingEdgeInsets(
                        deviceWidth,
                        deviceHeight,
                        innerPaddingHorizontalRatio,
                        innerPaddingVerticalRatio,
                      ),
                decoration: BoxDecoration(
                  borderRadius: AppTheme.smallBorderRadius,
                  color: AppColors.white,
                ),
                width: deviceWidth,
                height: deviceHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    LinearGradientTitle(
                      text: AppStrings.titlePreferredTopicMessage,
                      textStyle: AppTheme.topicLabelStyle,
                    ),
                    const SizedBox(height: 20),
                    BlocBuilder<PreferredTopicCubit, PreferredTopicState>(
                      builder: (context, state) {
                        if (state is GetTopicLoading) {
                          return const Expanded(
                            child: Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: AppColors.iris,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        } else if (state is GetTopicSuccess ||
                            state is AddUserFailure) {
                          return Expanded(
                            child: ValueListenableBuilder<
                                List<Map<TopicModel, bool>>>(
                              valueListenable: chosenTopics,
                              builder: (context, value, child) {
                                return GridView.builder(
                                  key: ValueKey(chosenTopics.value),
                                  shrinkWrap: true,
                                  itemCount: value.length,
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
                                        value[index];
                                    TopicModel topic =
                                        currentTopicMap.entries.first.key;
                                    return GestureDetector(
                                      onTap: () {
                                        handleTopicSelection(value, topic,
                                            chosenTopics, is5ItemsChosen);
                                      },
                                      child: TopicImageOption(
                                        currentTopicMap: currentTopicMap,
                                        topic: topic,
                                        optionSize:
                                            tileSizeWidthRatio * deviceWidth,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        } else {
                          return const AppPlaceHolder();
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                    ValueListenableBuilder<bool>(
                        valueListenable: isButtonEnable,
                        builder: (context, value, child) {
                          return BlocBuilder<PreferredTopicCubit,
                              PreferredTopicState>(builder: (context, state) {
                            return AuthElevatedButton(
                              isDisable: !isButtonEnable.value,
                              width: deviceWidth,
                              height: 42,
                              inputText: (!isButtonEnable.value)
                                  ? AppStrings.pick5ToContinue
                                  : AppStrings.exploreNow,
                              isLoading: state is AddUserLoading,
                              onPressed: (!isButtonEnable.value)
                                  ? () {}
                                  : () {
                                      context
                                          .read<PreferredTopicCubit>()
                                          .addCurrentUserData(
                                              context, chosenTopics.value);
                                    },
                            );
                          });
                        }),
                  ],
                ),
              ),
              if (isSmallScreen)
                const BottomRoundedAppBar(
                  bannerPath: AppImages.editProfileAppbarBackground,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
