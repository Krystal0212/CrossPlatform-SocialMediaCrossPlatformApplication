import 'package:socialapp/utils/import.dart';

import '../cubit/home_state.dart';
import '../providers/home_properties_provider.dart';
import 'post_header.dart';
import 'post_bottom.dart';
import 'post_assets.dart';

class PostListView extends StatefulWidget {
  final List<OnlinePostModel> posts;
  final ViewMode viewMode;

  const PostListView({
    super.key,
    required this.posts,
    required this.viewMode,
  });

  @override
  State<PostListView> createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView>
    with AutomaticKeepAliveClientMixin {
  late final List<OnlinePostModel> postList;
  late double postWidth;

  final double horizontalPadding = 125;
  final double smallHorizontalPadding = 10;

  late double deviceWidth, deviceHeight, listBodyWidth;
  late bool isCompactView, isSignedIn, isWeb;

  @override
  void initState() {
    super.initState();
    postList = widget.posts;
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
  Widget build(BuildContext context) {
    super.build(context);

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowIndicator();
          return true;
        },
        child: ListView(
          children: postList.map((postDetail) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Container(
                padding: AppTheme.homeListPostPaddingEdgeInsets(
                    isCompactView ? smallHorizontalPadding : horizontalPadding),
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
          }).toList(),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
