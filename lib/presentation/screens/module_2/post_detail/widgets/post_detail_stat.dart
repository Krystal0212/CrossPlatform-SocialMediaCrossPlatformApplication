import 'package:socialapp/utils/import.dart';

import '../cubit/post_detail_cubit.dart';

const double customIconSize = 32;

class PostStatsBar extends StatefulWidget {
  final OnlinePostModel post;
  final UserModel currentUser;
  final ValueNotifier<int> commentAmountNotifier;

  const PostStatsBar(
      {super.key, required this.post, required this.currentUser, required this.commentAmountNotifier});

  @override
  State<PostStatsBar> createState() => _PostStatsBarState();
}

class _PostStatsBarState extends State<PostStatsBar> with FlashMessage {
  late UserModel currentUser = UserModel.empty();

  late ValueNotifier<bool> isUserLiked = ValueNotifier<bool>(false);
  late final ValueNotifier<int> likeAmountNotifier = ValueNotifier<int>(widget.post.likeAmount);

  late int commentAmount, likeAmount;
  late bool isLikeOriginalData;

  @override
  void initState() {
    super.initState();

    commentAmount = widget.post.commentAmount;
    likeAmount = widget.post.likeAmount;


  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    currentUser = widget.currentUser;

    isUserLiked = ValueNotifier<bool>(
      widget.post.likes.contains(currentUser.id ?? ''),
    );
  }

  @override
  void dispose() {
    likeAmountNotifier.dispose();
    isUserLiked.dispose();
    super.dispose();
  }

  void toggleLike() {
    final userId = currentUser.id!;

    if (isUserLiked.value) {
      widget.post.likes.remove(userId);
      likeAmountNotifier.value -= 1;
      context.read<PostDetailCubit>().removePostLike();
    } else {
      widget.post.likes.add(userId);
      likeAmountNotifier.value += 1;
      context.read<PostDetailCubit>().addPostLike();
    }

    isUserLiked.value = !isUserLiked.value;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          double paddingWidth = constraints.maxWidth * 0.06;
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: paddingWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.post.viewAmount.toString(),
                        style: AppTheme.postStatsStyle,
                      ),
                      const SizedBox(width: 10,),
                      IconButton(
                        icon: const Icon(
                          Icons.remove_red_eye_outlined,
                          color: AppColors.iris,
                          size: customIconSize,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ValueListenableBuilder(valueListenable: widget.commentAmountNotifier,
                        builder: (context, value, child) {
                          return Text(
                            value.toString(),
                            style: AppTheme.postStatsStyle,
                          );
                        }
                      ),
                      const SizedBox(width: 10,),
                      IconButton(
                        icon: const Icon(
                          Icons.insert_comment_outlined,
                          color: AppColors.iris,
                            size: customIconSize,

                        ),
                        onPressed: () {
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ValueListenableBuilder<int>(
                          valueListenable: likeAmountNotifier,
                          builder: (context, likeAmount, _) {
                          return Text(
                            likeAmount.toString(),
                            style: AppTheme.postStatsStyle,
                          );
                        }
                      ),
                      const SizedBox(width: 10,),
                      ValueListenableBuilder<bool>(
                          valueListenable: isUserLiked,
                          builder: (context, isLiked, _) {
                            return LikeButton(
                              isLiked: isLiked,
                              size: customIconSize,
                              likeBuilder: (data) => SvgPicture.asset(
                                isLiked ? AppIcons.heartFilled : AppIcons.heart,
                              ),
                              onTap: (_) async {
                                if (currentUser.id?.isNotEmpty ?? false) {
                                  toggleLike();
                                } else {
                                  showNotSignedInMessage(
                                      context: context,
                                      description: AppStrings
                                          .notSignedInCollectionDescription);
                                }
                                return !isLiked;
                              },
                            );
                          }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}
