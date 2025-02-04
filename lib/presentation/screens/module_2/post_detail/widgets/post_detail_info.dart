import 'package:socialapp/utils/import.dart';

class PostDetailInfo extends StatefulWidget {
  final OnlinePostModel post;

  const PostDetailInfo({super.key, required this.post});

  @override
  State<PostDetailInfo> createState() => _PostDetailInfoState();
}

class _PostDetailInfoState extends State<PostDetailInfo> with Methods {
  late String timeAgo;

  @override
  void initState() {
    super.initState();

    timeAgo = calculateTimeFromNow(widget.post.timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BackButton(

            color: AppColors.erieBlack,
            style: AppTheme.actionNoEffectCircleButtonStyle,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: CircleAvatar(
              radius: 25,
              backgroundImage:
                  CachedNetworkImageProvider(widget.post.userAvatarUrl),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.post.username,
                style: AppTheme.blackUsernameMobileStyle,
                softWrap: true,
              ),
              Text(
                timeAgo,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.timestampStyle,
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              AppIcons.addToCollection,
              width: iconSize,
              height: iconSize,
            ),
          )
        ],
      ),
    );
  }
}
