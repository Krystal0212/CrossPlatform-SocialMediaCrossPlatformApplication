import 'package:socialapp/utils/import.dart';

import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import 'cubit/tab_cubit.dart';
import 'cubit/tab_state.dart';
import 'providers/user_notifier_provider.dart';
import 'widgets/home_appbar.dart';
import 'widgets/post_list_view.dart';

class WebsiteHomeScreen extends StatelessWidget {
  const WebsiteHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (context) => ExploreCubit(
                serviceLocator<PostRepository>(), context.read<HomeCubit>(), ViewMode.explore)),
        BlocProvider(
            create: (context) => TrendingCubit(
                serviceLocator<PostRepository>(), context.read<HomeCubit>(), ViewMode.trending)),
        BlocProvider(
            create: (context) => FollowingCubit(
                serviceLocator<PostRepository>(), context.read<HomeCubit>(), ViewMode.following)),
      ],
      child: const HomeBase(),
    );
  }
}

class HomeBase extends StatefulWidget {
  const HomeBase({super.key});

  @override
  State<HomeBase> createState() => _HomeBaseState();
}

// class _HomeScreenState extends State<HomeScreen>
//     with SingleTickerProviderStateMixin {
//   late List<dynamic> posts;
//   late double deviceWidth, deviceHeight, listBodyWidth;
//   late bool isCompactView;
//   late TabController tabController;
//   late UserModel? currentUser;
//
//   final ValueNotifier<bool> isLoading = ValueNotifier(true);
//   final ValueNotifier<UserModel?> currentUserNotifier = ValueNotifier(null);
//
//   @override
//   void initState() {
//     super.initState();
//     tabController = TabController(length: 3, vsync: this);
//     currentUser = context.read<HomeCubit>().getCurrentUser() ?? null;
//
//     FlutterNativeSplash.remove();
//   }
//
//   @override
//   void didChangeDependencies() async {
//     super.didChangeDependencies();
//
//     deviceWidth = MediaQuery.of(context).size.width;
//     deviceHeight = MediaQuery.of(context).size.height;
//     isCompactView = (deviceWidth < 530);
//     listBodyWidth = isCompactView ? 490 : 800;
//
//     if (isLoading.value) {
//       try {
//         final isUserSignedIn =
//             await context.read<HomeCubit>().checkCurrentUser();
//         if (isUserSignedIn) {
//           if (!context.mounted) return;
//           final currentUser = context.read<HomeCubit>().getCurrentUser();
//           currentUserNotifier.value = currentUser;
//         }
//       } catch (e) {
//         if (kDebugMode) {
//           print("Error fetching user: $e");
//         }
//       } finally {
//         isLoading.value = false; // Notify listeners that loading is complete
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     tabController.dispose();
//     isLoading.dispose();
//     currentUserNotifier.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (bool didPop, Object? result) async {
//         if (!kIsWeb) {
//           const bool shouldExit = true;
//           if (shouldExit == true) {
//             SystemNavigator.pop();
//           }
//         }
//       },
//       child: UserNotifierProvider(
//           notifier: currentUserNotifier,
//           child: ValueListenableBuilder<bool>(
//             valueListenable: isLoading,
//             builder: (context, isLoadingValue, child) {
//               if (isLoadingValue) {
//                 return const Scaffold(
//                   body: Center(
//                     child: CircularProgressIndicator(),
//                   ),
//                 );
//               }
//               return Scaffold(
//                 appBar: HomeScreenAppBar(
//                   deviceWidth: deviceWidth,
//                   currentUserNotifier: currentUserNotifier,
//                   tabController: tabController,
//                 ),
//                 body: BlocBuilder<HomeCubit, HomeState>(
//                   builder: (context, state) {
//                     if (state is HomeLoading) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (state is HomeLoadedPostsSuccess) {
//                       return Container(
//                         color: AppColors.lynxWhite,
//                         child: Center(
//                           child: Container(
//                             padding: const EdgeInsets.only(top: 20),
//                             width: listBodyWidth,
//                             child: TabBarView(
//                               controller: tabController,
//                               children: [
//                                 PostListView(
//                                   posts: state.postLists[0],
//                                   viewMode: ViewMode.explore,
//                                   listBodyWidth: listBodyWidth, currentUser: currentUser,
//                                 ),
//                                 PostListView(
//                                   posts: state.postLists[1],
//                                   viewMode: ViewMode.trending,
//                                   listBodyWidth: listBodyWidth, currentUser: currentUser,
//                                 ),
//                                 PostListView(
//                                   posts: state.postLists[2],
//                                   viewMode: ViewMode.following,
//                                   listBodyWidth: listBodyWidth, currentUser: currentUser,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     } else if (state is HomeFailure) {
//                       return Center(child: Text(state.errorMessage));
//                     } else {
//                       return const Center(child: Text('Fetching data'));
//                     }
//                   },
//                 ),
//               );
//             },
//           )),
//     );
//   }
// }

class _HomeBaseState extends State<HomeBase>
    with SingleTickerProviderStateMixin {
  late double deviceWidth, deviceHeight, listBodyWidth;
  late bool isCompactView;
  late TabController tabController;
  late UserModel? currentUser;

  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  final ValueNotifier<UserModel?> currentUserNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
    currentUser = context.read<HomeCubit>().getCurrentUser();

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
        final isUserSignedIn = await context.read<HomeCubit>().checkCurrentUser();
        if (isUserSignedIn) {
          if (!context.mounted) return;
          final currentUser = context.read<HomeCubit>().getCurrentUser();
          currentUserNotifier.value = currentUser;

          context.read<FollowingCubit>().loadPosts(isOffline: false);
        }
        if (!context.mounted) return;
        context.read<ExploreCubit>().loadPosts(isOffline: false);
        context.read<TrendingCubit>().loadPosts(isOffline: false);
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
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!kIsWeb) {
          const bool shouldExit = true;
          if (shouldExit == true) {
            SystemNavigator.pop();
          }
        }
      },
      child: HomePropertiesProvider(
        homeProperties: HomeProperties(currentUserNotifier: currentUserNotifier, user: currentUserNotifier.value, listBodyWidth: listBodyWidth),
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
                              );
                            } else if (state is TabError) {
                              return Center(child: Text(state.error));
                            } else {
                              return const Center(child: Text('Fetching data'));
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
                              );
                            } else if (state is TabError) {
                              return Center(child: Text(state.error));
                            } else {
                              return const Center(child: Text('Fetching data'));
                            }
                          },
                        ),
                        // Following Tab
                        BlocBuilder<FollowingCubit, TabState>(
                          builder: (context, state) {
                            if (state is TabLoading) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }else if(state is TabNotSignIn){
                              return SignInPagePlaceholder(width: listBodyWidth,);
                            }
                            else if (state is TabLoaded) {
                              return PostListView(
                                posts: state.posts,
                                viewMode: ViewMode.following,
                              );
                            } else if (state is TabError) {
                              return Center(child: Text(state.error));
                            } else {
                              return const Center(child: Text('Fetching data'));
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
