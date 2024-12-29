

import 'package:socialapp/utils/import.dart';
import 'package:socialapp/presentation/screens/module_2/post_detail/post_detail_screen.dart';


class PostCustom extends StatelessWidget {

  final PostModel post;

  const PostCustom({super.key, required this.post});


  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColors.white,
        ),
        child: Column(
          children: [
            PostInfo(post: post,),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostDetailScreen(post: post)
                ));
              },
              child: Image.network(
                post.image,
                width: deviceWidth,
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // const AddCollectionIcon(),
                  const Spacer(),
                  Text(post.commentAmount.toString()),
                  IconButton(
                    icon: const Icon(Icons.comment_outlined, color: AppColors.carbon,),
                    onPressed: () {},
                  ),
                  const SizedBox(width: 8),
                  Text(post.likeAmount.toString()),
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: AppColors.carbon,),
                    onPressed: () {},
                  ),
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}

class PostInfo extends StatefulWidget {
  const PostInfo({super.key, required this.post});

  final PostModel post;

  @override
  State<PostInfo> createState() => _PostInfoState();
}

class _PostInfoState extends State<PostInfo> with Methods {
  late String timeAgo;

  @override
  void initState() {
    super.initState();
    timeAgo = calculateTimeFromNow(widget.post.timestamp);
  }

  @override
  Widget build(BuildContext context) {
    // String timeAgo = calculateTimeFromNow(widget.post.timestamp);
    
    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            InkWell(
              onTap: () {

              },
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(widget.post.userAvatar),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: Text(
                widget.post.username,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold
                )
              ),
            ),
            // Spacer(),  
            const Spacer(),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Text(
                textAlign: TextAlign.end,
                timeAgo,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.timestampStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}