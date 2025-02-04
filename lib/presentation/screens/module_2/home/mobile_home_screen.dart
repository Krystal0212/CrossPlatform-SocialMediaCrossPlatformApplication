import 'dart:ui';

import 'package:socialapp/utils/import.dart';

import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import 'cubit/tab_cubit.dart';
import 'cubit/tab_state.dart';
import 'providers/home_properties_provider.dart';
import 'widgets/post_list_view.dart';
import '../../../widgets/general/custom_search_bar.dart';
import 'widgets/home_appbar_segmented_tab_controller.dart';

class MobileHomeScreen extends StatelessWidget {
  const MobileHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
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
    super.dispose();
  }

  Future<void> refreshExplore() async {
    await context.read<ExploreCubit>().refresh();
  }

  Future<void> refreshTrending() async {
    await context.read<TrendingCubit>().refresh();
  }

  Future<void> refreshFollowing() async {
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
                  currentUserNotifier: currentUserNotifier,
                  user: currentUserNotifier.value,
                  listBodyWidth: listBodyWidth),
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
                            onSearchDebounce: (text) {},
                          ),
                          const Spacer(),

                          if (value != null)
                            SizedBox(
                                child: CircleAvatar(
                              radius: 25,
                              backgroundImage: CachedNetworkImageProvider(
                                currentUserNotifier.value!.avatar,
                              ),
                            ))
                          else
                            SizedBox(
                              height: compactActionButtonsWidth,
                              width: compactActionButtonsWidth,
                              child: ElevatedButton(
                                onPressed: () => context.push('/sign-in'),
                                style: AppTheme.actionNoEffectCircleButtonStyle
                                    .copyWith(
                                  backgroundColor: const WidgetStatePropertyAll(
                                    AppColors.systemShockBlue,
                                  ),
                                ),
                                child: Image.asset(AppIcons.userSignIn,
                                    width: 25, height: 25),
                              ),
                            ),
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
                              child: SegmentedTabControl(
                                controller: tabController,
                                splashColor: Colors.transparent,
                                tabTextColor: AppColors.iris,
                                selectedTabTextColor: AppColors.white,
                                squeezeIntensity: 2.0,
                                indicatorPadding: EdgeInsets.zero,
                                barDecoration: const BoxDecoration(
                                  color: AppColors.tropicalBreeze,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                tabs: [
                                  SegmentTab(
                                    label: 'Explore',
                                    color: AppColors.bneiBrakBay,
                                    backgroundColor:
                                        AppColors.bneiBrakBay.withOpacity(0.1),
                                  ),
                                  SegmentTab(
                                    label: 'Trending',
                                    color: AppColors.officeNeonLight,
                                    backgroundColor: AppColors.officeNeonLight
                                        .withOpacity(0.1),
                                  ),
                                  SegmentTab(
                                    label: 'Following',
                                    color: AppColors.limeShot,
                                    backgroundColor:
                                        AppColors.limeShot.withOpacity(0.1),
                                  ),
                                ],
                              )),
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
                        BlocBuilder<FollowingCubit, TabState>(
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
                                  posts:
                                      (state is TabLoaded) ? state.posts : [],
                                  tabCubit:
                                      BlocProvider.of<FollowingCubit>(context),
                                ),
                              );
                            }
                          },
                        ),
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

// class _HomeScreenState extends State<MobileHomeBase>
//     with SingleTickerProviderStateMixin {
//   late double deviceWidth, deviceHeight;
//   late TabController _tabController;
//   late double compactActionButtonsWidth;
//   late UserModel? currentUser = UserModel.empty();
//
//   final ValueNotifier<UserModel?> currentUserNotifier = ValueNotifier(null);
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     FlutterNativeSplash.remove();
//   }
//
//   @override
//   void didChangeDependencies() async {
//     super.didChangeDependencies();
//     deviceWidth = MediaQuery.of(context).size.width;
//     deviceHeight = MediaQuery.of(context).size.height;
//     compactActionButtonsWidth = deviceWidth * 0.075;
//
//     try {
//       final isUserSignedIn = await context.read<HomeCubit>().checkCurrentUser();
//       if (isUserSignedIn) {
//         if (!context.mounted) return;
//         currentUser = context.read<HomeCubit>().getCurrentUser();
//         currentUserNotifier.value = currentUser;
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Error fetching user: $e");
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider(create: (context) => ExploreCubit(serviceLocator<PostRepository>(), context.read<HomeCubit>())),
//         BlocProvider(create: (context) => TrendingCubit(serviceLocator<PostRepository>(), context.read<HomeCubit>())),
//         BlocProvider(create: (context) => FollowingCubit(serviceLocator<PostRepository>(), context.read<HomeCubit>())),
//       ],
//       child: UserNotifierProvider(
//         notifier: currentUserNotifier,
//         child: DefaultTabController(
//           length: 3,
//           child: Scaffold(
//             appBar: AppBar(
//               backgroundColor: AppColors.white,
//               automaticallyImplyLeading: false,
//               flexibleSpace: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 height: 60,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     CustomSearchBar(searchBarWidth: deviceWidth * 0.8),
//                     const Spacer(),
//                     if (currentUserNotifier.value != null)
//                       SizedBox(
//                           width: 38,
//                           height: 38,
//                           child: CircleAvatar(
//                             radius: 17,
//                             backgroundImage: CachedNetworkImageProvider(
//                               currentUserNotifier.value!.avatar,
//                               maxWidth: 20,
//                               maxHeight: 20,
//                             ),
//                           ))
//                     else
//                       SizedBox(
//                         height: compactActionButtonsWidth,
//                         width: compactActionButtonsWidth,
//                         child: ElevatedButton(
//                           onPressed: () => context.push('/sign-in'),
//                           style: AppTheme.actionNoEffectCircleButtonStyle.copyWith(
//                             backgroundColor: const WidgetStatePropertyAll(
//                               AppColors.systemShockBlue,
//                             ),
//                           ),
//                           child: Image.asset(AppIcons.userSignIn, width: 25, height: 25),
//                         ),
//                       )
//                   ],
//                 ),
//               ),
//               bottom: PreferredSize(
//                 preferredSize: const Size.fromHeight(50),
//                 child: ClipRRect(
//                   borderRadius: const BorderRadius.all(Radius.circular(10)),
//                   child: SizedBox(
//                     width: deviceWidth,
//                     height: 50,
//                     child: SegmentedTabControl(
//                       splashColor: Colors.transparent,
//                       tabTextColor: AppColors.iris,
//                       selectedTabTextColor: AppColors.white,
//                       squeezeIntensity: 2.0,
//                       indicatorPadding: EdgeInsets.zero,
//                       barDecoration: const BoxDecoration(
//                         color: AppColors.tropicalBreeze,
//                         borderRadius: BorderRadius.all(Radius.circular(10)),
//                       ),
//                       tabs: [
//                         SegmentTab(
//                           label: 'Explore',
//                           color: AppColors.bneiBrakBay,
//                           backgroundColor: AppColors.bneiBrakBay.withOpacity(0.1),
//                         ),
//                         SegmentTab(
//                           label: 'Trending',
//                           color: AppColors.officeNeonLight,
//                           backgroundColor: AppColors.officeNeonLight.withOpacity(0.1),
//                         ),
//                         SegmentTab(
//                           label: 'Following',
//                           color: AppColors.limeShot,
//                           backgroundColor: AppColors.limeShot.withOpacity(0.1),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             body: TabBarView(
//               controller: _tabController,
//               children: [
//                 BlocBuilder<ExploreCubit, TabState>(
//                   builder: (context, state) {
//                     if (state is TabLoading) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (state is TabLoaded) {
//                       return PostListView(
//                         posts: state.posts,
//                         viewMode: ViewMode.explore,
//                         listBodyWidth: deviceWidth,
//                         currentUser: currentUser,
//                       );
//                     } else if (state is TabError) {
//                       return Center(child: Text(state.error));
//                     } else {
//                       return const Center(child: Text('Fetching data'));
//                     }
//                   },
//                 ),
//                 BlocBuilder<TrendingCubit, TabState>(
//                   builder: (context, state) {
//                     if (state is TabLoading) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (state is TabLoaded) {
//                       return PostListView(
//                         posts: state.posts,
//                         viewMode: ViewMode.trending,
//                         listBodyWidth: deviceWidth,
//                         currentUser: currentUser,
//                       );
//                     } else if (state is TabError) {
//                       return Center(child: Text(state.error));
//                     } else {
//                       return const Center(child: Text('Fetching data'));
//                     }
//                   },
//                 ),
//                 BlocBuilder<FollowingCubit, TabState>(
//                   builder: (context, state) {
//                     if (state is TabLoading) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (state is TabLoaded) {
//                       return PostListView(
//                         posts: state.posts,
//                         viewMode: ViewMode.following,
//                         listBodyWidth: deviceWidth,
//                         currentUser: currentUser,
//                       );
//                     } else if (state is TabError) {
//                       return Center(child: Text(state.error));
//                     } else {
//                       return const Center(child: Text('Fetching data'));
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
