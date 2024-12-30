import 'package:socialapp/utils/import.dart';

import 'cubit/home_cubit.dart';
import 'cubit/home_state.dart';
import 'widgets/home_header_custom.dart';
import 'widgets/custom_post.dart';
import 'widgets/tab_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<dynamic> posts;
  late CollectionReference<Map<String, dynamic>> postCollection;

  // late CollectionReference<Map<String, dynamic>> commentPostCollection;
  late double deviceWidth, deviceHeight, bodyWidth;
  late dynamic userInfo;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    bodyWidth = deviceWidth * 0.45;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const HomeHeaderCustom(),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    color: AppColors.white,
                    // color: Colors.green.shade100,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: BlocBuilder<HomeCubit, HomeState>(
                        builder: (context, state) {
                      return TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: AppColors.iric.withOpacity(0.1),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        labelColor: AppColors.iric,
                        unselectedLabelColor:
                            AppColors.dynamicBlack.withOpacity(0.5),
                        onTap: (index) {
                          ViewMode selectedMode;
                          switch (index) {
                            case 0:
                              selectedMode = ViewMode.popular;
                              break;
                            case 1:
                              selectedMode = ViewMode.trending;
                              break;
                            case 2:
                              selectedMode = ViewMode.fol;
                              break;
                            default:
                              selectedMode = ViewMode.popular;
                          }
                          context.read<HomeCubit>().setViewMode(selectedMode);
                        },
                        tabs: const [
                          TabItem(
                            title: 'Popular',
                          ),
                          TabItem(title: 'Trending'),
                          TabItem(title: 'Following'),
                        ],
                      );
                    }),
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
                  color: AppColors.lynxWhite,
                  child: Center(
                      child: Container(
                        padding: const EdgeInsets.only(top: 20),
                    width: bodyWidth,
                    child: TabBarView(
                      children: [
                        PostListView(
                          posts: state.posts,
                          viewMode: ViewMode.popular,
                          bodyWidth: bodyWidth,
                        ),
                        PostListView(
                          posts: state.posts,
                          viewMode: ViewMode.trending,
                          bodyWidth: bodyWidth,
                        ),
                        PostListView(
                          posts: state.posts,
                          viewMode: ViewMode.fol,
                          bodyWidth: bodyWidth,
                        ),
                      ],
                    ),
                  )),
                );
              } else if (state is HomeFailure) {
                return Center(child: Text(state.errorMessage));
              } else {
                return const Center(child: Text('Select a view mode'));
              }
            },
          ),
        ),
      ),
    );
  }
}

class PostListView extends StatelessWidget {
  final List<PostModel> posts;
  final ViewMode viewMode;
  final double bodyWidth;

  const PostListView(
      {super.key,
      required this.posts,
      required this.viewMode,
      required this.bodyWidth});

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    if (kDebugMode) {
      print(deviceWidth * 0.35);
      print(deviceWidth);
    }

    return ListView.builder(
      itemCount: posts.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return CustomPost(
          post: posts[index],
          bodyWidth: bodyWidth,
        );
      },
    );
  }
}
