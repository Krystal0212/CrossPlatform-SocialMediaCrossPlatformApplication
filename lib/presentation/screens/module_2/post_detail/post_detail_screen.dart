import 'package:socialapp/presentation/screens/module_2/post_detail/widgets/post_detail_info.dart';
import 'package:socialapp/utils/import.dart';

import 'cubit/post_detail_cubit.dart';
import 'widgets/post_detail_asset.dart';
import 'widgets/post_detail_comments_list_view.dart';
import 'widgets/post_detail_edit_text_field.dart';
import 'widgets/post_detail_content.dart';
import 'widgets/post_detail_stat.dart';

const double iconSize = 50;

class PostDetailScreen extends StatelessWidget {
  final OnlinePostModel post;
  final UserModel currentUser;

  const PostDetailScreen(
      {super.key, required this.post, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => PostDetailCubit(post.postId),
        child: PostDetailBase(
          currentUser: currentUser,
          post: post,
        ));
  }
}

class PostDetailBase extends StatefulWidget {
  final OnlinePostModel post;
  final UserModel currentUser;

  const PostDetailBase(
      {super.key, required this.post, required this.currentUser});

  @override
  State<PostDetailBase> createState() => _PostDetailBaseState();
}

class _PostDetailBaseState extends State<PostDetailBase> with FlashMessage {
  late ValueNotifier<int> commentAmountNotifier;

  @override
  void initState() {
    super.initState();

    commentAmountNotifier = ValueNotifier(widget.post.commentAmount);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PostDetailInfo(post: widget.post,),
              PostDetailContent(
                post: widget.post,
                user: widget.currentUser,
              ),
              PostDetailAsset(post: widget.post),
              PostStatsBar(
                post: widget.post,
                currentUser: widget.currentUser,
                commentAmountNotifier: commentAmountNotifier,
              ),
              PostDetailEditTextField(
                post: widget.post,
                commentAmountNotifier: commentAmountNotifier,
              ),
              PostDetailCommentsListView(

                post: widget.post,
                currentUser: widget.currentUser,
              )
            ]),
      ),
    )));
  }
}
