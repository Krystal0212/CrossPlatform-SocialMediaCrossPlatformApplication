import 'dart:ui';

import 'package:socialapp/utils/import.dart';

import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import 'cubit/search_cubit.dart';
import 'cubit/search_state.dart';
import 'cubit/tab_cubit.dart';
import 'cubit/tab_state.dart';
import 'providers/home_properties_provider.dart';
import 'widgets/post_list_view.dart';
import '../../../widgets/general/custom_search_bar.dart';
import 'widgets/home_appbar_segmented_tab_controller.dart';
import 'widgets/search_post_list_view.dart';

class MobileHomeScreen extends StatelessWidget {
  const MobileHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(homeContext: context),
      child: MultiBlocProvider(providers: [
        BlocProvider(
            create: (context) => ExploreCubit(serviceLocator<PostRepository>(),
                context.read<HomeCubit>(), ViewMode.explore)),
        BlocProvider(
            create: (context) => TrendingCubit(serviceLocator<PostRepository>(),
                context.read<HomeCubit>(), ViewMode.trending)),
        BlocProvider(
            create: (context) => FollowingCubit(
                serviceLocator<PostRepository>(),
                context.read<HomeCubit>(),
                ViewMode.following)),
        BlocProvider(create: (context) => SearchCubit()),
      ], child: const MobileHomeBase()),
    );
  }
}

class MobileHomeBase extends StatefulWidget {
  const MobileHomeBase({super.key});

  @override
  State<MobileHomeBase> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MobileHomeBase>
    with SingleTickerProviderStateMixin {
  late List<dynamic> posts;
  late CollectionReference<Map<String, dynamic>> postCollection;
  late double deviceWidth, deviceHeight;
  late TabController tabController;
  late double compactActionButtonsWidth;
  late UserModel? currentUser = UserModel.empty();
  late double listBodyWidth = 490;
  late int previousIndex = 0;

  final ValueNotifier<UserModel?> currentUserNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isSearchHiddenNotifier = ValueNotifier(true);
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(() {
      if(isSearchHiddenNotifier.value && !tabController.indexIsChanging) {
        previousIndex = tabController.index;
      }
    });
    FlutterNativeSplash.remove();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final flutterView = PlatformDispatcher.instance.views.first;
    deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    deviceHeight = flutterView.physicalSize.height;

    listBodyWidth = deviceWidth;

    compactActionButtonsWidth = deviceWidth * 0.075;

    try {
      final isUserSignedIn =
          context.read<HomeCubit>().checkCurrentUserSignedIn();
      if (isUserSignedIn) {
        if (context.mounted) {
          await context.read<HomeCubit>().checkCurrentUser();
          final UserModel? currentUser =
              context.read<HomeCubit>().getCurrentUser();
          currentUserNotifier.value = currentUser;

          context.read<FollowingCubit>().initialLoadPosts(isOffline: false);
        }
      }
      if (!context.mounted) return;
      context.read<ExploreCubit>().initialLoadPosts(isOffline: false);
      context.read<TrendingCubit>().initialLoadPosts(isOffline: false);
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user: $e");
      }
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    currentUserNotifier.dispose();
    isSearchHiddenNotifier.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> refreshExplore() async {
    context.read<HomeCubit>().triggerSync();
    await context.read<ExploreCubit>().refresh();
  }

  Future<void> refreshTrending() async {
    context.read<HomeCubit>().triggerSync();
    await context.read<TrendingCubit>().refresh();
  }

  Future<void> refreshFollowing() async {
    context.read<HomeCubit>().triggerSync();
    await context.read<FollowingCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!kIsWeb) {
          SystemNavigator.pop();
        }
      },
      child: ValueListenableBuilder(
          valueListenable: currentUserNotifier,
          builder: (context, value, _) {
            return HomePropertiesProvider(
              homeProperties: HomeProperties(
                isSearchHiddenNotifier: isSearchHiddenNotifier,
                  currentUserNotifier: currentUserNotifier,
                  currentUser: currentUserNotifier.value,
                  listBodyWidth: listBodyWidth,
                searchController: searchController
              ),
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: AppBar(
                  backgroundColor: AppColors.white,
                  automaticallyImplyLeading: false,
                  flexibleSpace: BlocBuilder<HomeCubit, HomeState>(
                      builder: (context, state) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Left Section
                          CustomSearchBar(
                            searchBarWidth: deviceWidth * 0.8,
                            searchBarHeight: 55,
                            onSearchDebounce: (text) {
                              if (text.isNotEmpty) {
                                isSearchHiddenNotifier.value = false;
                                context.read<SearchCubit>().searchPosts(text);
                                tabController
                                    .animateTo(2); // Switch to Search Tab
                              } else {
                                isSearchHiddenNotifier.value = true;
                                tabController
                                    .animateTo(previousIndex);
                              }
                            },
                            controller: searchController,
                          ),
                          const Spacer(),
                          ValueListenableBuilder(
                              valueListenable: isSearchHiddenNotifier,
                              builder: (context, isHidden, _) {
                                if (!isHidden) {
                                  return IconButton(
                                    onPressed: () {
                                      searchController.clear();
                                      FocusScope.of(context).unfocus();
                                      tabController.animateTo(previousIndex);

                                      isSearchHiddenNotifier.value = true;
                                    },
                                    icon: const Icon(
                                      Icons.cancel,
                                      size: 45,
                                      color: AppColors.iris,
                                    ),
                                  );
                                } else if (value != null) {
                                  return IconButton(
                                    onPressed: () {},
                                    icon: Icon(
                                      Icons.circle_rounded,
                                      size: 45,
                                      color: AppColors.iris.withOpacity(0.4),
                                    ),
                                  );
                                }
                                return SizedBox(
                                  height: compactActionButtonsWidth,
                                  width: compactActionButtonsWidth,
                                  child: ElevatedButton(
                                    onPressed: () => context.push('/sign-in'),
                                    style: AppTheme
                                        .actionNoEffectCircleButtonStyle
                                        .copyWith(
                                      backgroundColor:
                                          const WidgetStatePropertyAll(
                                        AppColors.systemShockBlue,
                                      ),
                                    ),
                                    child: Image.asset(AppIcons.userSignIn,
                                        width: 25, height: 25),
                                  ),
                                );
                              })
                        ],
                      ),
                    );
                  }),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Container(
                        width: deviceWidth,
                        // Ensure bottom also takes full width
                        height: 50,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.tropicalBreeze,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ValueListenableBuilder(
                                  valueListenable: isSearchHiddenNotifier,
                                  builder: (context, isHidden, _) {
                                    return SegmentedTabControl(
                                      controller: tabController,
                                      splashColor: Colors.transparent,
                                      tabTextColor: AppColors.iris,
                                      selectedTabTextColor: AppColors.white,
                                      squeezeIntensity: 2.0,
                                      indicatorPadding: EdgeInsets.zero,
                                      barDecoration: const BoxDecoration(
                                        color: AppColors.tropicalBreeze,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                      ),
                                      tabs: [
                                        SegmentTab(
                                          label: 'Explore',
                                          color: AppColors.bneiBrakBay,
                                          backgroundColor: AppColors.bneiBrakBay
                                              .withOpacity(0.1),
                                        ),
                                        SegmentTab(
                                          label: 'Trending',
                                          color: AppColors.officeNeonLight,
                                          backgroundColor: AppColors
                                              .officeNeonLight
                                              .withOpacity(0.1),
                                        ),
                                        isHidden
                                            ? SegmentTab(
                                                label: 'Following',
                                                color: AppColors.bneiBrakBay,
                                                backgroundColor: AppColors
                                                    .bneiBrakBay
                                                    .withOpacity(0.1),
                                              )
                                            : SegmentTab(
                                                label: 'Result',
                                                color: AppColors.lightIris,
                                                backgroundColor: AppColors
                                                    .lightIris
                                                    .withOpacity(0.1),
                                              ),
                                      ],
                                    );
                                  })),
                        ),
                      ),
                    ),
                  ),
                ),
                body: Container(
                  padding: const EdgeInsets.only(bottom: 40),
                  color: AppColors.lynxWhite,
                  child: Center(
                      child: Container(
                    padding: const EdgeInsets.only(top: 20),
                    width: listBodyWidth,
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        // Explore Tab
                        BlocBuilder<ExploreCubit, TabState>(
                          builder: (context, state) {
                            if (state is TabLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              return RefreshIndicator(
                                onRefresh: () => refreshExplore(),
                                child: PostListView(
                                  homeCubit: BlocProvider.of<HomeCubit>(context),
                                  posts:
                                      (state is TabLoaded) ? state.posts : [],
                                  tabCubit:
                                      BlocProvider.of<ExploreCubit>(context),
                                ),
                              );
                            }
                          },
                        ),
                        // Trending Tab
                        BlocBuilder<TrendingCubit, TabState>(
                          builder: (context, state) {
                            if (state is TabLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              return RefreshIndicator(
                                onRefresh: () => refreshTrending(),
                                child: PostListView(
                                  homeCubit: BlocProvider.of<HomeCubit>(context),
                                  posts:
                                      (state is TabLoaded) ? state.posts : [],
                                  tabCubit:
                                      BlocProvider.of<TrendingCubit>(context),
                                ),
                              );
                            }
                          },
                        ),
                        // Following Tab
                        ValueListenableBuilder(
                            valueListenable: isSearchHiddenNotifier,
                            builder: (context, isHidden, _) {
                              if (isHidden) {
                                return BlocBuilder<FollowingCubit, TabState>(
                                  builder: (context, state) {
                                    if (state is TabLoading) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (state is TabNotSignIn) {
                                      return SignInPagePlaceholder(
                                        width: listBodyWidth,
                                      );
                                    } else {
                                      return RefreshIndicator(
                                        onRefresh: () => refreshFollowing(),
                                        child: PostListView(
                                          homeCubit: BlocProvider.of<HomeCubit>(context),
                                          posts: (state is TabLoaded)
                                              ? state.posts
                                              : [],
                                          tabCubit:
                                              BlocProvider.of<FollowingCubit>(
                                                  context),
                                        ),
                                      );
                                    }
                                  },
                                );
                              }
                              return BlocBuilder<SearchCubit, SearchState>(
                                  builder: (context, state) {
                                if (state is SearchFinding) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                return SearchPostListView(
                                  homeCubit: BlocProvider.of<HomeCubit>(context),
                                  posts: (state is SearchLoaded)
                                      ? state.posts
                                      : [],
                                  searchCubit:
                                      BlocProvider.of<SearchCubit>(context),
                                );
                              });
                            }),
                      ],
                    ),
                  )),
                ),
              ),
            );
          }),
    );
  }
}
