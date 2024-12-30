import 'package:socialapp/utils/import.dart';

import 'post_header.dart';

class CustomPost extends StatelessWidget {
  final PostModel post;
  final double bodyWidth;

  const CustomPost({super.key, required this.post, required this.bodyWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: bodyWidth * 0.5,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PostHeader(post: post),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(post: post),
                ),
              );
            },
            child: Image.network(
              post.image,
              fit: BoxFit.cover,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Spacer(),
              Text(post.commentAmount.toString()),
              IconButton(
                icon:SvgPicture.asset(AppIcons.comment),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              Text(post.likeAmount.toString()),
              IconButton(
                icon: SvgPicture.asset(AppIcons.heart),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}