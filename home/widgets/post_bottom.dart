import 'package:socialapp/utils/import.dart';

class PostBottom extends StatelessWidget {
  final PostModel post;

  const PostBottom({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTheme.postHorizontalPaddingEdgeInsets,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon:SvgPicture.asset(AppIcons.addToCollection),
            onPressed: () {},
          ),
          const Spacer(),
          Text(post.commentAmount.toString()),
          IconButton(
            icon:SvgPicture.asset(AppIcons.chat),
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
    );
  }
}
