import 'package:socialapp/utils/import.dart';

import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import 'widgets/custom_appbar.dart';
import 'widgets/app_post.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late List<dynamic> posts;
  late double deviceWidth, deviceHeight, listBodyWidth;
  late bool isCompactView;
  late TabController _tabController;

  final ValueNotifier<bool> isLoading = ValueNotifier(true);
  final ValueNotifier<UserModel?> currentUserNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
          if(!context.mounted) return;
          final currentUser = context.read<HomeCubit>().getCurrentUser();
          currentUserNotifier.value = currentUser;
        }
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
    _tabController.dispose();
    isLoading.dispose();
    currentUserNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (context, isLoadingValue, child) {
        if (isLoadingValue) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar:  HomeScreenAppBar(
                  deviceWidth: deviceWidth,
              currentUserNotifier: currentUserNotifier,
            ),
            body: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HomeLoadedPostsSuccess) {
                  return Container(
                    color: AppColors.lynxWhite,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.only(top: 20),
                        width: listBodyWidth,
                        child: TabBarView(
                          children: [
                            PostListView(
                              posts: state.posts,
                              viewMode: ViewMode.explore,
                              listBodyWidth: listBodyWidth,
                            ),
                            PostListView(
                              posts: state.posts,
                              viewMode: ViewMode.trending,
                              listBodyWidth: listBodyWidth,
                            ),
                            PostListView(
                              posts: state.posts,
                              viewMode: ViewMode.following,
                              listBodyWidth: listBodyWidth,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else if (state is HomeFailure) {
                  return Center(child: Text(state.errorMessage));
                } else {
                  return const Center(child: Text('Select a view mode'));
                }
              },
            ),
          ),
        );
      },
    );
  }
}
