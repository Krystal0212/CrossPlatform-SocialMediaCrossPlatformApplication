import 'package:socialapp/presentation/screens/module_2/home/cubit/home_cubit.dart';
import 'package:socialapp/presentation/screens/module_2/home/providers/home_properties_provider.dart';
import 'package:socialapp/utils/import.dart';

class PostBottom extends StatefulWidget {
  final OnlinePostModel post;

  const PostBottom({super.key, required this.post});

  @override
  State<PostBottom> createState() => _PostBottomState();
}

class _PostBottomState extends State<PostBottom> with FlashMessage {
  late UserModel? currentUser = UserModel.empty();
  late ValueNotifier<bool> isUserLiked = ValueNotifier<bool>(false);
  late final ValueNotifier<int> likeAmountNotifier;

  late int commentAmount, likeAmount;

  @override
  void initState() {
    super.initState();

    commentAmount = widget.post.commentAmount;
    likeAmount = widget.post.likeAmount;

    likeAmountNotifier = ValueNotifier<int>(widget.post.likeAmount);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    currentUser = HomePropertiesProvider.of(context)?.user;
    isUserLiked = ValueNotifier<bool>(
      widget.post.likes.contains(currentUser?.id ?? ''),
    );
  }

  @override
  void dispose() {
    isUserLiked.dispose();
    likeAmountNotifier.dispose();
    super.dispose();
  }

  void toggleLike() {
    final userId = currentUser!.id!;
    final postId = widget.post.postId;

    if (isUserLiked.value) {
      widget.post.likes.remove(userId);
      likeAmountNotifier.value -= 1;
      context.read<HomeCubit>().removePostLike(postId);
    } else {
      widget.post.likes.add(userId);
      likeAmountNotifier.value += 1;
      context.read<HomeCubit>().addPostLike(postId);
    }

    isUserLiked.value = !isUserLiked.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppTheme.postHorizontalPaddingEdgeInsets,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(widget.post.media!= null)
          IconButton(
            icon: SvgPicture.asset(AppIcons.addToCollection),
            onPressed: () {
              if (currentUser?.id?.isNotEmpty ?? false) {
                toggleLike();
              } else {
                showNotSignedInMassage(
                    context: context,
                    description: AppStrings.notSignedInCollectionDescription);
              }
            },
          ),
          const Spacer(),
          Row(
            children: [
              Text(widget.post.commentAmount.toString()),
              const SizedBox(width: 15),
              IconButton(
                icon: SvgPicture.asset(AppIcons.chat),
                onPressed: () {
                  if (currentUser?.id?.isNotEmpty ?? false) {
                    toggleLike();
                  } else {
                    showNotSignedInMassage(
                        context: context,
                        description: AppStrings.notSignedInMessageDescription);
                  }
                },
              ),
            ],
          ),
          Row(
            children: [
              ValueListenableBuilder<int>(
                valueListenable: likeAmountNotifier,
                builder: (context, likeAmount, _) {
                  return Text(likeAmount.toString());
                },
              ),
              const SizedBox(width: 15),
              ValueListenableBuilder<bool>(
                valueListenable: isUserLiked,
                builder: (context, isLiked, _) {
                  return LikeButton(
                      isLiked: isLiked,
                      likeBuilder: (data) => SvgPicture.asset(
                            isLiked ? AppIcons.heartFilled : AppIcons.heart,
                          ),
                      onTap: (_) async {
                        if (currentUser?.id?.isNotEmpty ?? false) {
                          toggleLike();
                        } else {
                          showNotSignedInMassage(
                              context: context,
                              description:
                                  AppStrings.notSignedInLikedDescription);
                        }
                        return !isLiked;
                      });
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
