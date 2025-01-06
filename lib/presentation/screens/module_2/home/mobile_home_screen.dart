import 'package:socialapp/utils/import.dart';

import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import 'widgets/app_post.dart';
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

  late double listBodyWidth = 490;

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
    compactActionButtonsWidth = deviceWidth * 0.08;
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    context.read<HomeCubit>().close();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
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
                      searchBarWidth: deviceWidth * 0.77,
                    ),
                    const Spacer(),
                    SizedBox(
                      height: compactActionButtonsWidth,
                      width: compactActionButtonsWidth,
                      child: ElevatedButton(
                        onPressed: () => context.go('/sign-in'),
                        style:
                            AppTheme.actionNoEffectCircleButtonStyle.copyWith(
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
                              indicatorPadding:  EdgeInsets.zero,
                              barDecoration: const BoxDecoration(
                                color: AppColors.tropicalBreeze,
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              tabs: [
                                SegmentTab(
                                  label: 'Explore',
                                  color: AppColors.bneiBrakBay,
                                  backgroundColor: AppColors.bneiBrakBay.withOpacity(0.1),
                                ),
                                SegmentTab(
                                  label: 'Trending',
                                  color: AppColors.officeNeonLight,
                                  backgroundColor: AppColors.officeNeonLight.withOpacity(0.1),
                                ),
                                SegmentTab(
                                  label: 'Following',
                                  color: AppColors.limeShot,
                                  backgroundColor: AppColors.limeShot.withOpacity(0.1),
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
    );
  }
}
