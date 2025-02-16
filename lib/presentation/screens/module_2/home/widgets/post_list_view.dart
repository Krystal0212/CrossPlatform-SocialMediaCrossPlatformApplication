import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:socialapp/presentation/screens/module_2/home/cubit/tab_cubit.dart';
import 'package:socialapp/utils/import.dart';

import '../cubit/home_cubit.dart';
import '../providers/home_properties_provider.dart';
import 'post_header.dart';
import 'post_bottom.dart';
import 'post_assets.dart';

class PostListView extends StatefulWidget {
  final List<OnlinePostModel> posts;
  final TabCubit tabCubit;
  final HomeCubit homeCubit;

  const PostListView({
    super.key,
    required this.posts,
    required this.tabCubit,
    required this.homeCubit,
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

  final Map<String, Timer?> _viewTimers = {};


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
      isLoadingNotifier.value = true;

      try {
        List<OnlinePostModel> morePosts = await widget.tabCubit.loadMorePosts();
        if (morePosts.isNotEmpty) {
          postListNotifier.value =
              ([...postListNotifier.value, ...morePosts]).toSet().toList();
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
    isSignedIn = HomePropertiesProvider.of(context)?.currentUser != null;
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

    for (final timer in _viewTimers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  void _startViewTimer(String postId, bool viewCounted) {
    if (viewCounted) return;

    _viewTimers[postId]?.cancel();

    _viewTimers[postId] = Timer(const Duration(seconds: 15), () {
      if (mounted) {
        widget.homeCubit.addViewCount(postId);
        _viewTimers.remove(postId);
      }
    });
  }

  void _stopViewTimer(String postId) {
    _viewTimers[postId]?.cancel();
    _viewTimers.remove(postId);
  }

  void removePostFromList(String postId) {
    final List<OnlinePostModel> updatedPostList = List.from(postListNotifier.value);
    updatedPostList.removeWhere((post) => post.postId == postId);
    postListNotifier.value = List.from(updatedPostList);
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
                if (postList.isEmpty) {
                  return ListView(
                    children: [
                      Padding(
                        padding: AppTheme.homeListPostPaddingEdgeInsets(
                          isCompactView ? smallHorizontalPadding : horizontalPadding,
                        ),
                        child: NoMorePostsPlaceholder(width: postWidth),
                      ),
                    ],
                  );
                }
                return InViewNotifierList(
                  controller: scrollController,
                  itemCount: postList.length + (isLoading ? 1 : 0) + (canBeFetched ? 0 : 1),
                  isInViewPortCondition: (double deltaTop, double deltaBottom, double viewPortDimension) {
                    bool isValid = deltaTop < (0.4 * viewPortDimension) &&
                    deltaBottom > (0.4 * viewPortDimension);

                    return isValid;
                  },
                  builder: (BuildContext context, int index) {
                    // Handle footer items for loading/no-more-posts as needed.
                    if (index == postList.length) {
                      if (isLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.iris),
                          ),
                        );
                      } else if (!canBeFetched) {
                        return Column(
                          children: [
                            const SizedBox(height: 5),
                            Padding(
                              padding: AppTheme.homeListPostPaddingEdgeInsets(
                                isCompactView ? smallHorizontalPadding : horizontalPadding,
                              ),
                              child: NoMorePostsPlaceholder(width: postWidth),
                            ),
                          ],
                        );
                      }
                    }

                    final postDetail = postList[index];
                    bool viewCounted = false;
                    final ValueNotifier<bool> isObserving = ValueNotifier<bool>(false);

                    return InViewNotifierWidget(
                      id: postDetail.postId,
                      builder: (BuildContext context, bool isInView, Widget? child) {
                        if (isInView) {
                          // if (kDebugMode) {
                          //   print('Post ${postDetail.postId} is in view.');
                          // }
                          _startViewTimer(postDetail.postId, viewCounted);
                        } else {
                          _stopViewTimer( postDetail.postId);
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Container(
                            padding: AppTheme.homeListPostPaddingEdgeInsets(
                              isCompactView ? smallHorizontalPadding : horizontalPadding,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 4),
                                )]
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PostHeader(post: postDetail, postWidth:  postWidth, onDeletePost: removePostFromList,),
                                  PostAsset(
                                    post: postDetail,
                                    postWidth: postWidth,
                                  ),
                                  PostBottom(post: postDetail),
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
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
