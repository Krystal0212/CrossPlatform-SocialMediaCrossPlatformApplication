import 'package:socialapp/utils/import.dart';

class PostHeader extends StatelessWidget with Methods {
  const PostHeader({super.key, required this.post});

  final PostModel post;

  @override
  Widget build(BuildContext context) {
    String timeAgo = calculateTimeFromNow(post.timestamp);

    if (kDebugMode) {
      print(post.username);
    }

    double deviceHeight = MediaQuery.of(context).size.height;
    return SizedBox(
      height: 50/700 * deviceHeight,

      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10/700 * deviceHeight),
        child: Row(
          children: [
            InkWell(
              onTap: () {},
              child: CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(post.userAvatar),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              post.username,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.carbon),
            ),
            const Spacer(),
            Text(
              timeAgo,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.timestampStyle,
            ),
          ],
        ),
      ),
    );
  }
}
