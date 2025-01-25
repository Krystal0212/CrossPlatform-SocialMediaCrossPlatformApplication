import 'package:socialapp/utils/import.dart';

import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import 'cubit/tab_cubit.dart';
import 'cubit/tab_state.dart';
import 'providers/home_properties_provider.dart';
import 'widgets/home_appbar.dart';
import 'widgets/post_list_view.dart';

class WebsiteHomeScreen extends StatelessWidget {
  const WebsiteHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (context) => ExploreCubit(
                  serviceLocator<PostRepository>(),
                  context.read<HomeCubit>(),
                  ViewMode.explore)),
          BlocProvider(
              create: (context) => TrendingCubit(
                  serviceLocator<PostRepository>(),
                  context.read<HomeCubit>(),
                  ViewMode.trending)),
          BlocProvider(
              create: (context) => FollowingCubit(
                  serviceLocator<PostRepository>(),
                  context.read<HomeCubit>(),
                  ViewMode.following)),
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

  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  final ValueNotifier<UserModel?> currentUserNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);

    FlutterNativeSplash.remove();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();

    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {},
      child: HomePropertiesProvider(
        homeProperties: HomeProperties(
            currentUserNotifier: currentUserNotifier,
            user: currentUserNotifier.value,
            listBodyWidth: listBodyWidth),
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
            return Scaffold(
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
                            } else if (state is TabLoaded) {
                              return PostListView(
                                posts: state.posts,
                                viewMode: ViewMode.explore,
                                tabCubit:
                                    BlocProvider.of<ExploreCubit>(context),
                              );
                            }  else {
                              return NoMorePostsPlaceholder(width: listBodyWidth,);
                            }
                          },
                        ),
                        // Trending Tab
                        BlocBuilder<TrendingCubit, TabState>(
                          builder: (context, state) {
                            if (state is TabLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (state is TabLoaded) {
                              return PostListView(
                                posts: state.posts,
                                viewMode: ViewMode.trending,
                                tabCubit:
                                    BlocProvider.of<TrendingCubit>(context),
                              );
                            } else {
                              return NoMorePostsPlaceholder(
                                width: listBodyWidth,
                              );
                            }
                          },
                        ),
                        // Following Tab
                        BlocBuilder<FollowingCubit, TabState>(
                          builder: (context, state) {
                            if (state is TabLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else if (state is TabNotSignIn) {
                              return SignInPagePlaceholder(
                                width: listBodyWidth,
                              );
                            } else if (state is TabLoaded) {
                              return PostListView(
                                posts: state.posts,
                                viewMode: ViewMode.following,
                                tabCubit:
                                    BlocProvider.of<FollowingCubit>(context),
                              );
                            } else {
                              return NoMorePostsPlaceholder(
                                width: listBodyWidth,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
