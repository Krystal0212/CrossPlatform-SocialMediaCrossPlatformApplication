import 'package:socialapp/utils/import.dart';

import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import 'providers/user_notifier_provider.dart';
import 'widgets/post_list_view.dart';
import 'widgets/search_bar.dart';
import 'widgets/segmented_tab_controller.dart';

class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({super.key});

  @override
  State<MobileHomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<MobileHomeScreen>
    with SingleTickerProviderStateMixin {
  late List<dynamic> posts;
  late CollectionReference<Map<String, dynamic>> postCollection;
  late double deviceWidth, deviceHeight;
  late TabController _tabController;
  late double compactActionButtonsWidth;
  late UserModel? currentUser;

  late double listBodyWidth = 490;

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
    listBodyWidth = deviceWidth;

    compactActionButtonsWidth = deviceWidth * 0.075;

    try {
      final isUserSignedIn = await context.read<HomeCubit>().checkCurrentUser();
      if (isUserSignedIn) {
        if (!context.mounted) return;
        currentUser = context.read<HomeCubit>().getCurrentUser() ?? null;
        currentUserNotifier.value = currentUser;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching user: $e");
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: UserNotifierProvider(
        notifier: currentUserNotifier,
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.white,
              automaticallyImplyLeading: false,
              flexibleSpace:
                  BlocBuilder<HomeCubit, HomeState>(builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  height: 60,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomSearchBar(
                        searchBarWidth: deviceWidth * 0.8,
                      ),
                      const Spacer(),
                      if (currentUserNotifier.value != null)
                        SizedBox(
                            width: 38,
                            height: 38,
                            child: CircleAvatar(
                              radius: 17,
                              backgroundImage: CachedNetworkImageProvider(
                                  currentUserNotifier.value!.avatar,
                                  maxWidth: 20,
                                  maxHeight: 20),
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
                        )
                    ],
                  ),
                );
              }),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Container(
                    width: deviceWidth, // Ensure bottom also takes full width
                    height: 50,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: BlocBuilder<HomeCubit, HomeState>(
                        builder: (context, state) {
                          return Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.tropicalBreeze,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: SegmentedTabControl(
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
                              ));
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
            body: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HomeLoadedPostsSuccess) {
                  return Container(
                    padding: const EdgeInsets.only(bottom: 40),
                    color: AppColors.lynxWhite,
                    child: Center(
                        child: Container(
                      padding: const EdgeInsets.only(top: 20),
                      width: listBodyWidth,
                      child: TabBarView(
                        children: [
                          PostListView(
                            posts: state.postLists[0],
                            viewMode: ViewMode.explore,
                            listBodyWidth: listBodyWidth, currentUser: currentUser,
                          ),
                          PostListView(
                            posts: state.postLists[1],
                            viewMode: ViewMode.trending,
                            listBodyWidth: listBodyWidth, currentUser: currentUser,
                          ),
                          PostListView(
                            posts: state.postLists[2],
                            viewMode: ViewMode.following,
                            listBodyWidth: listBodyWidth, currentUser: currentUser,
                          ),
                        ],
                      ),
                    )),
                  );
                } else if (state is HomeFailure) {
                  return Center(child: Text(state.errorMessage));
                } else {
                  return const Center(child: Text('Fetching data'));
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
