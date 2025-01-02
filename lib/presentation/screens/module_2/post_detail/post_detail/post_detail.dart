import 'package:socialapp/utils/import.dart';

import '../../comment/comment_screen.dart';

class PostDetail extends StatelessWidget {
  const PostDetail({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // PostUserInfo(post: post),
            PostImage(post: post),
            // PostImage(post: post),
            // PostImage(post: post),
            // PostImage(post: post),
            PostStatsBar(post: post),
            PostContent(post: post),
            // Expanded(
            //   child: FutureBuilder(
            //     future: serviceLocator<PostRepository>().getCommentPost(post),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return Center(child: CircularProgressIndicator());
            //       }
            //       if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //         return Center(child: Text('There is no comment.'));
            //       }

            //       return ListView.builder(
            //         // shrinkWrap: true,
            //         // physics: NeverScrollableScrollPhysics(),
            //         itemBuilder: (context, index) {
            //           return Text(snapshot.data![index].content);
            //         },
            //         itemCount: snapshot.data!.length,
            //       );
            //     }
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}

class PostUserInfo extends StatefulWidget {
  const PostUserInfo({super.key, required this.post});

  final PostModel post;

  @override
  State<PostUserInfo> createState() => _PostUserInfoState();
}

class _PostUserInfoState extends State<PostUserInfo> with Methods {
  late String timeAgo;

  @override
  void initState() {
    super.initState();
    timeAgo = calculateTimeFromNow(widget.post.timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(widget.post.userAvatar),
                ),
              ),
              Text(widget.post.username,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text(
                timeAgo,
                style: AppTextStyle.timestampStyle,
              )
              // Text((post.timestamp as Timestamp).toDate().toString()),
            ],
          ),
          // Text(now.toString()),
          // Text(now.difference(date).inMinutes.toString()),
        ],
      ),
    );
  }
}

class PostImage extends StatelessWidget {
  const PostImage({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    // return Image.network(post.image);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        // child: 
        // Image.network(
        //   post.assets,
        //   fit: BoxFit.cover,
        // ),
      ),
    );
  }
}

class PostStatsBar extends StatelessWidget {
  const PostStatsBar({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Text(
                post.viewAmount.toString(),
                style: TextStyle(color: AppColors.carbon.withOpacity(0.5)),
              ),
              IconButton(
                icon: Icon(
                  Icons.remove_red_eye_outlined,
                  color: AppColors.iric.withOpacity(0.5),
                ),
                onPressed: () {},
              ),
            ],
          ),
          Row(
            children: [
              Text(
                post.commentAmount.toString(),
                style: TextStyle(color: AppColors.carbon.withOpacity(0.5)),
              ),
              IconButton(
                icon: Icon(
                  Icons.insert_comment_outlined,
                  color: AppColors.iric.withOpacity(0.5),
                ),
                onPressed: () {
                  // context.go('/signin/comment');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CommentScreen(post: post)));
                },
              ),
            ],
          ),
          Row(
            children: [
              Text(
                post.likeAmount.toString(),
                style: TextStyle(color: AppColors.carbon.withOpacity(0.5)),
              ),
              IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  color: AppColors.iric.withOpacity(0.5),
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PostContent extends StatelessWidget {
  const PostContent({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          post.content * 20,
          // style: TextStyle(
          //   fontSize: 14,
          //   color: AppColors.trolleyGrey,
          //   fontFamily: 'CircularStd',
          //   wordSpacing: 4
          // ),
          style: AppTextStyle.contentPost,
        ));
  }
}
