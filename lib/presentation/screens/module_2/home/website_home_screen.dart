import 'package:socialapp/utils/import.dart';

import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import 'cubit/search_cubit.dart';
import 'cubit/search_state.dart';
import 'cubit/tab_cubit.dart';
import 'cubit/tab_state.dart';
import 'providers/home_properties_provider.dart';
import 'widgets/home_appbar.dart';
import 'widgets/post_list_view.dart';
import 'widgets/search_post_list_view.dart';

class WebsiteHomeScreen extends StatelessWidget {
  const WebsiteHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) =>
                  ExploreCubit(
                      serviceLocator<PostRepository>(),
                      context.read<HomeCubit>(),
                      ViewMode.explore
                  )),
          BlocProvider(
              create: (context) =>
                  TrendingCubit(
                      serviceLocator<PostRepository>(),
                      context.read<HomeCubit>(),
                      ViewMode.trending)),
          BlocProvider(
              create: (context) =>
                  FollowingCubit(
                      serviceLocator<PostRepository>(),
                      context.read<HomeCubit>(),
                      ViewMode.following)),
          BlocProvider(create: (context) => SearchCubit()),
        ],
        child: const WebsiteHomeBase(),
      ),
    );
  }
}

class WebsiteHomeBase extends StatefulWidget {
  const WebsiteHomeBase({super.key});

  @override
  State<WebsiteHomeBase> createState() => _WebsiteHomeBaseState();
}

class _WebsiteHomeBaseState extends State<WebsiteHomeBase>
    with SingleTickerProviderStateMixin {
  late double deviceWidth, deviceHeight, listBodyWidth;
  late bool isCompactView;
  late TabController tabController;
  late int previousIndex = 0;

  final ValueNotifier<bool> isLoading = ValueNotifier(true);
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

    deviceWidth = MediaQuery
        .of(context)
        .size
        .width;
    deviceHeight = MediaQuery
        .of(context)
        .size
        .height;
    isCompactView = (deviceWidth < 530);
    listBodyWidth = isCompactView ? 490 : 800;

    if (isLoading.value) {
      try {
        final isUserSignedIn =
        await context.read<HomeCubit>().checkCurrentUser();
        if (isUserSignedIn) {
          if (!context.mounted) return;
          final currentUser = context.read<HomeCubit>().getCurrentUser();
          currentUserNotifier.value = currentUser;

          context.read<FollowingCubit>().initialLoadPosts(isOffline: false);
        }
        if (!context.mounted) return;
        context.read<ExploreCubit>().initialLoadPosts(isOffline: false);
        context.read<TrendingCubit>().initialLoadPosts(isOffline: false);
      } catch (e) {
        if (kDebugMode) {
          print("Error fetching user: $e");
        }
      } finally {
        isLoading.value = false; // Notify listeners that loading is complete
      }
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    isLoading.dispose();
    currentUserNotifier.dispose();
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
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {},
      child: ValueListenableBuilder<bool>(
        valueListenable: isLoading,
        builder: (context, isLoadingValue, child) {
          if (isLoadingValue) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return HomePropertiesProvider(
            homeProperties: HomeProperties(
              searchController: searchController,
                currentUserNotifier: currentUserNotifier,
                currentUser: currentUserNotifier.value,
                listBodyWidth: listBodyWidth, isSearchHiddenNotifier: isSearchHiddenNotifier),
            child: Scaffold(
              appBar: HomeScreenAppBar(
                deviceWidth: deviceWidth,
                currentUserNotifier: currentUserNotifier,
                tabController: tabController,
              ),
              body: Container(
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
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
