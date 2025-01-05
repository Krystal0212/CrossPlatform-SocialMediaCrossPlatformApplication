import 'package:socialapp/utils/import.dart';

import '../cubit/home_state.dart';
import 'post_header.dart';
import 'post_bottom.dart';
import 'post_assets.dart';

class PostListView extends StatefulWidget {
  final List<PostModel> posts;
  final ViewMode viewMode;
  final double listBodyWidth;

  const PostListView(
      {super.key,
      required this.posts,
      required this.viewMode,
      required this.listBodyWidth});

  @override
  State<PostListView> createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView>
    with AutomaticKeepAliveClientMixin {
  late final List<PostModel> postList;
  late  double postWidth;
  final double horizontalPadding = 125;
  final double smallHorizontalPadding = 10;

  late double deviceWidth, deviceHeight;
  late bool isCompactView;

  @override
  void initState() {
    super.initState();
    postList = widget.posts;
  }

  @override
  void didChangeDependencies() {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    isCompactView = (deviceWidth < 530) ? true : false;
    postWidth = isCompactView
        ? widget.listBodyWidth - smallHorizontalPadding * 2
        : widget.listBodyWidth - horizontalPadding * 2;

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
        child: ListView.builder(
          itemCount: postList.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            PostModel postDetail = postList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Container(
                padding:
                    AppTheme.homeListPostPaddingEdgeInsets( isCompactView ? smallHorizontalPadding :horizontalPadding),
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
                      PostBottom(post: postDetail)
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
