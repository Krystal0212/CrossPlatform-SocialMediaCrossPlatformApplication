import 'package:socialapp/utils/import.dart';

import '../../home/widgets/collection_dialog.dart';

class PostDetailInfo extends StatefulWidget {
  final OnlinePostModel post;
  final UserModel? currentUser;

  const PostDetailInfo({super.key, required this.post, this.currentUser});

  @override
  State<PostDetailInfo> createState() => _PostDetailInfoState();
}

class _PostDetailInfoState extends State<PostDetailInfo> with Methods, FlashMessage {
  late String timeAgo;

  @override
  void initState() {
    super.initState();

    timeAgo = calculateTimeFromNow(widget.post.timestamp);
  }

  void showCollectionPicker(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => CollectionPickerDialog(
        userId: userId, postId: widget.post.postId, medias: widget.post.media!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
              FocusScope.of(context).unfocus();
            },
            icon: const Icon(Icons.arrow_back_sharp, size: 30, color: AppColors.erieBlack,),
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
            onPressed: () {
              if (widget.currentUser?.id?.isNotEmpty ?? false) {
                showCollectionPicker(context, widget.currentUser!.id!);
              } else {
                showNotSignedInMassage(
                    context: context,
                    description: AppStrings.notSignedInCollectionDescription);
              }
            },
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
