import 'package:socialapp/presentation/screens/module_2/home/cubit/home_cubit.dart';
import 'package:socialapp/utils/import.dart';

import '../cubit/home_state.dart';
import 'post_header.dart';
import 'post_bottom.dart';
import 'post_assets.dart';

class PostListView extends StatefulWidget {
  final List<PostModel> posts;
  final ViewMode viewMode;
  final double listBodyWidth;
  final UserModel? currentUser;

  const PostListView(
      {super.key,
      required this.posts,
      required this.viewMode,
      required this.listBodyWidth, required this.currentUser});

  @override
  State<PostListView> createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView>
    with AutomaticKeepAliveClientMixin {
  late final List<PostModel> postList;
  late double postWidth;
  late ViewMode viewMode;

  final double horizontalPadding = 125;
  final double smallHorizontalPadding = 10;

  late double deviceWidth, deviceHeight;
  late bool isCompactView, isSignedIn, isWeb;

  @override
  void initState() {
    super.initState();
    postList = widget.posts;
    viewMode = widget.viewMode;
    isSignedIn = context.read<HomeCubit>().checkCurrentUserSignedIn();
  }

  @override
  void didChangeDependencies() async {
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    isWeb = PlatformConfig.of(context)?.isWeb ?? false;


    isCompactView = (deviceWidth < 530 || !isWeb) ? true : false;
    postWidth = isCompactView
        ? widget.listBodyWidth - smallHorizontalPadding * 2
        : widget.listBodyWidth - horizontalPadding * 2;

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if(isSignedIn || (!isSignedIn && viewMode != ViewMode.following)) {
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
                      PostBottom(post: postDetail, currentUser: widget.currentUser,)
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
    return SignInPagePlaceholder(width: widget.listBodyWidth,);
  }

  @override
  bool get wantKeepAlive => true;
}
