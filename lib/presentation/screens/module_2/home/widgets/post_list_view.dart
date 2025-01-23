import 'package:socialapp/presentation/screens/module_2/home/cubit/tab_cubit.dart';
import 'package:socialapp/utils/import.dart';

import '../cubit/home_state.dart';
import '../providers/home_properties_provider.dart';
import 'post_header.dart';
import 'post_bottom.dart';
import 'post_assets.dart';

class PostListView extends StatefulWidget {
  final List<OnlinePostModel> posts;
  final ViewMode viewMode;
  final TabCubit tabCubit;

  const PostListView({
    super.key,
    required this.posts,
    required this.viewMode,
    required this.tabCubit,
  });

  @override
  State<PostListView> createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView>
    with AutomaticKeepAliveClientMixin {
  late final ValueNotifier<List<OnlinePostModel>> postListNotifier;
  late final ValueNotifier<bool> isLoadingNotifier;
  late bool canBeFetched;
  late double postWidth;

  final double horizontalPadding = 125;
  final double smallHorizontalPadding = 10;

  late double deviceWidth, deviceHeight, listBodyWidth;
  late bool isCompactView, isSignedIn, isWeb;

  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(loadMore);
    postListNotifier = ValueNotifier(widget.posts);
    isLoadingNotifier = ValueNotifier(false);
    canBeFetched = true; // Initialize as true
  }

  void loadMore() async {
    if (scrollController.offset >=
        scrollController.position.maxScrollExtent - 100 &&
        !scrollController.position.outOfRange &&
        !isLoadingNotifier.value &&
        canBeFetched) {
      // Set loading state to true
      isLoadingNotifier.value = true;

      try {
        List<OnlinePostModel> morePosts =
        await widget.tabCubit.loadMorePosts();
        if (morePosts.isNotEmpty) {
          postListNotifier.value = [...postListNotifier.value, ...morePosts];
        } else {
          canBeFetched = false; // No more data available
        }
      } finally {
        isLoadingNotifier.value = false;
      }
    }
  }

  @override
  void didChangeDependencies() async {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    isSignedIn = HomePropertiesProvider.of(context)?.user != null;
    listBodyWidth =
        HomePropertiesProvider.of(context)?.listBodyWidth ?? deviceWidth;

    isWeb = PlatformConfig.of(context)?.isWeb ?? false;

    isCompactView = (deviceWidth < 530 || !isWeb) ? true : false;
    postWidth = isCompactView
        ? listBodyWidth - smallHorizontalPadding * 2
        : listBodyWidth - horizontalPadding * 2;

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    scrollController.removeListener(loadMore);
    postListNotifier.dispose();
    isLoadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ValueListenableBuilder<List<OnlinePostModel>>(
          valueListenable: postListNotifier,
          builder: (context, postList, child) {
            return ValueListenableBuilder<bool>(
              valueListenable: isLoadingNotifier,
              builder: (context, isLoading, child) {
                return ListView.builder(
                  controller: scrollController,
                  itemCount: postList.length +
                      (isLoading ? 1 : 0) +
                      (canBeFetched ? 0 : 1),
                  itemBuilder: (context, index) {
                    if (index == postList.length) {
                      if (isLoading) {
                        // Show loading indicator
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.iris,),
                          ),
                        );
                      } else if (!canBeFetched) {
                        return  NoMorePostsPlaceholder(width: postWidth,);
                      }
                    }

                    final postDetail = postList[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Container(
                        padding: AppTheme.homeListPostPaddingEdgeInsets(
                            isCompactView
                                ? smallHorizontalPadding
                                : horizontalPadding),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PostHeader(post: postDetail),
                              PostAsset(
                                post: postDetail,
                                postWidth: postWidth,
                              ),
                              PostBottom(
                                post: postDetail,
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
