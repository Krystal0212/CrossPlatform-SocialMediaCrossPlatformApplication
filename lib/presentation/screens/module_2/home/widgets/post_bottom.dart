import 'package:socialapp/presentation/screens/module_2/home/cubit/home_cubit.dart';
import 'package:socialapp/presentation/screens/module_2/home/providers/home_properties_provider.dart';
import 'package:socialapp/utils/import.dart';

import 'collection_dialog.dart';

const double customIconSize = 30;

class PostBottom extends StatefulWidget {
  final OnlinePostModel post;

  const PostBottom({super.key, required this.post});

  @override
  State<PostBottom> createState() => _PostBottomState();
}

class _PostBottomState extends State<PostBottom> with FlashMessage {
  late UserModel? currentUser = UserModel.empty();
  late ValueNotifier<bool> isUserLiked = ValueNotifier<bool>(false);
  late final ValueNotifier<int> likeAmountNotifier, viewAmountNotifier;

  late int commentAmount, likeAmount;

  @override
  void initState() {
    super.initState();

    commentAmount = widget.post.commentAmount;
    likeAmount = widget.post.likeAmount;

    likeAmountNotifier = ValueNotifier<int>(widget.post.likeAmount);
    viewAmountNotifier = ValueNotifier<int>(widget.post.viewAmount);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    currentUser = HomePropertiesProvider.of(context)?.currentUser;
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
    TextEditingController searchController = HomePropertiesProvider.of(context)!.searchController;

    return Padding(
      padding: AppTheme.postHorizontalPaddingEdgeInsets,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if(widget.post.media!= null)
          IconButton(
            icon: SvgPicture.asset(AppIcons.addToCollection, width: customIconSize, height: customIconSize),
            onPressed: () {
              if (currentUser?.id?.isNotEmpty ?? false) {
                showCollectionPicker(context, currentUser!.id!);
              } else {
                showNotSignedInMessage(
                    context: context,
                    description: AppStrings.notSignedInCollectionDescription);
              }
            },
          ),
          const Spacer(),
          Row(
            children: [
              Text(widget.post.viewAmount.toString(), style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 5),
              IconButton(
                icon: const Icon(
                  Icons.remove_red_eye_outlined,
                  color: AppColors.iris,
                  size: customIconSize,
                ),
                onPressed: () {
                },
              ),
            ],
          ),
          const SizedBox(width: 15),
          Row(
            children: [
              Text(widget.post.commentAmount.toString(), style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 5),
              IconButton(
                icon: SvgPicture.asset(AppIcons.chat, width: customIconSize, height: customIconSize),
                onPressed: () {
                  if (currentUser?.id?.isNotEmpty ?? false) {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PostDetailScreen(
                          post: widget.post,
                          currentUser: currentUser!, searchController: searchController,
                        )));
                  } else {
                    showNotSignedInMessage(
                        context: context,
                        description: AppStrings.notSignedInMessageDescription);
                  }
                },
              ),
            ],
          ),
          const SizedBox(width: 15),
          Row(
            children: [
              ValueListenableBuilder<int>(
                valueListenable: likeAmountNotifier,
                builder: (context, likeAmount, _) {
                  return Text(likeAmount.toString(), style: const TextStyle(fontSize: 18),);
                },
              ),
              const SizedBox(width: 5),
              ValueListenableBuilder<bool>(
                valueListenable: isUserLiked,
                builder: (context, isLiked, _) {
                  return LikeButton(
                      isLiked: isLiked,
                      likeBuilder: (data) => SvgPicture.asset(
                            isLiked ? AppIcons.heartFilled : AppIcons.heart,
                          ),
                      size: customIconSize+4,
                      onTap: (_) async {
                        if (currentUser?.id?.isNotEmpty ?? false) {
                          toggleLike();
                        } else {
                          showNotSignedInMessage(
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
