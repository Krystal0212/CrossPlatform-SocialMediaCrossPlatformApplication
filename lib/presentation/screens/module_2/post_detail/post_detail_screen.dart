import 'package:socialapp/presentation/screens/module_2/post_detail/widgets/post_detail_info.dart';
import 'package:socialapp/utils/import.dart';

import '../home/widgets/collection_dialog.dart';
import '../mobile_navigator/navigator_bar.dart';
import 'cubit/post_detail_cubit.dart';
import 'cubit/post_detail_load_cubit.dart';
import 'cubit/post_detail_load_state.dart';
import 'cubit/post_detail_state.dart';
import 'widgets/post_detail_asset.dart';
import 'widgets/post_detail_comments_list_view.dart';
import 'widgets/post_detail_edit_text_field.dart';
import 'widgets/post_detail_content.dart';
import 'widgets/post_detail_stat.dart';

const double iconSize = 50;

class PostDetailScreen extends StatelessWidget {
  final OnlinePostModel? post;
  final String? postId;
  final UserModel currentUser;
  final TextEditingController searchController;

  const PostDetailScreen({
    super.key,
    this.post,
    this.postId,
    required this.currentUser,
    required this.searchController,
  }) : assert(post != null || postId != null,
            'Either post or postId must be provided.');

  @override
  Widget build(BuildContext context) {
    return (post == null)
        ? BlocProvider(
            create: (context) => PostDataLoadCubit(post?.postId ?? postId!),
            child: BlocBuilder<PostDataLoadCubit, PostDataLoadedState>(
                builder: (context, state) {
              if (state is PostDataLoaded) {
                return BlocProvider(
                  create: (context) => PostDetailCubit(post?.postId ?? postId!),
                  child: PostDetailBase(
                    currentUser: currentUser,
                    post: state.post,
                    searchController: searchController,
                  ),
                );
              }
              return const GettingDataPlaceholder();
            }))
        : BlocProvider(
            create: (context) => PostDetailCubit(post?.postId ?? postId!),
            child: BlocBuilder<PostDetailCubit, PostDetailState>(
                builder: (context, state) {
              return PostDetailBase(
                currentUser: currentUser,
                post: post!,
                searchController: searchController,
              );
            }),
          );
  }
}

class PostDetailBase extends StatefulWidget {
  final OnlinePostModel post;
  final UserModel currentUser;
  final TextEditingController searchController;

  const PostDetailBase(
      {super.key,
      required this.post,
      required this.currentUser,
      required this.searchController});

  @override
  State<PostDetailBase> createState() => _PostDetailBaseState();
}

class _PostDetailBaseState extends State<PostDetailBase> with FlashMessage {
  late ValueNotifier<int> commentAmountNotifier;
  late ValueNotifier<String> postContentNotifier;
  late TextEditingController _editController = TextEditingController();
  late bool isModified = false;

  @override
  void initState() {
    super.initState();
    postContentNotifier = ValueNotifier(widget.post.content);
    commentAmountNotifier = ValueNotifier(widget.post.commentAmount);
    _editController = TextEditingController(text: widget.post.content);
  }

  @override
  void dispose() {
    _editController.dispose();
    postContentNotifier.dispose();
    commentAmountNotifier.dispose();
    super.dispose();
  }

  void showEditPostDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider(
          create: (context) => PostDetailCubit(widget.post.postId),
          child: AlertDialog(
            backgroundColor: AppColors.white,
            title: const Text("Edit Post Content"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _editController,
                  maxLength: 300,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: "Update your post content...",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              BlocConsumer<PostDetailCubit, PostDetailState>(
                listener: (context, state) {
                  if (state is PostDetailChangeContentSuccess) {
                    isModified = true;
                    postContentNotifier.value =
                        _editController.text; // Update the notifier
                    Navigator.pop(context);
                    showSuccessMessage(
                      context: context,
                      title: 'Content Updated',
                    );
                  }
                },
                builder: (context, state) => AuthElevatedButton(
                  width: double.infinity,
                  height: 45,
                  inputText: AppStrings.submit,
                  onPressed: () {
                    context.read<PostDetailCubit>().updatePostContent(
                        _editController.text, widget.post.postId);
                  },
                  isLoading: state is PostDetailChangeContentLoading,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppTheme.authSignUpStyle,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _showDeleteDialog(BuildContext parentContext) async {
    return await showDialog(
          context: context,
          builder: (context) {
            return BlocProvider(
              create: (context) => PostDetailCubit(widget.post.postId),
              child: AlertDialog(
                backgroundColor: AppColors.white,
                title: Text(AppStrings.exitDialogTitle,
                    style: AppTheme.blackUsernameMobileStyle
                        .copyWith(fontSize: 30)),
                content: Text(AppStrings.removePost,
                    style: AppTheme.blackUsernameMobileStyle
                        .copyWith(fontWeight: FontWeight.w300)),
                actions: <Widget>[
                  BlocConsumer<PostDetailCubit, PostDetailState>(
                    listener: (context, state) {
                      if (state is PostDetailDeleteSuccess) {
                        Navigator.pop(context);
                        Navigator.pop(parentContext);
                      }
                    },
                    builder: (context, state) => AuthElevatedButton(
                      width: double.infinity,
                      height: 45,
                      inputText: 'Yah',
                      onPressed: () {
                        context
                            .read<PostDetailCubit>()
                            .deletePost(widget.post.postId);
                      },
                      isLoading: state is PostDetailChangeContentLoading,
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: AppTheme.authSignUpStyle.copyWith(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ) ??
        false;
  }


  void showCollectionPicker(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (context) => CollectionPickerDialog(
        userId: userId, postId: widget.post.postId, medias: widget.post.media!,
      ),
    );
  }

  void showPostOptionsDialogForOwner(BuildContext parentContext) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text("Post Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Change Post Content"),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  showEditPostDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline_outlined),
                title: const Text("Add To Collection"),
                onTap: () async{
                  UserModel? currentUser = await serviceLocator<UserRepository>().getCurrentUserData();

                  Navigator.of(dialogContext).pop();
                  if(currentUser?.id?.isNotEmpty ?? false) {
                    showCollectionPicker(context, currentUser!.id!);
                  }

                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text("Delete This Post"),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  _showDeleteDialog(parentContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text("Cancel"),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: SingleChildScrollView(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PostDetailInfo(
                popCase: () {
                  if (!isModified) {
                    Navigator.pop(context);
                    FocusScope.of(context).unfocus();
                  } else {
                    if (!kIsWeb) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const CustomNavigatorBar()), // Replace with your home screen widget
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const WebsiteHomeScreen()), // Replace with your home screen widget
                      );
                    }
                  }
                },
                ownerInteraction: () {
                  showPostOptionsDialogForOwner( context);
                },
                post: widget.post,
                currentUser: widget.currentUser,
              ),
              PostDetailContent(
                postContentNotifier: postContentNotifier,
                post: widget.post,
                user: widget.currentUser,
                searchController: widget.searchController,
              ),
              PostDetailAsset(
                post: widget.post,
              ),
              PostStatsBar(
                post: widget.post,
                currentUser: widget.currentUser,
                commentAmountNotifier: commentAmountNotifier,
              ),
              PostDetailEditTextField(
                post: widget.post,
                commentAmountNotifier: commentAmountNotifier,
              ),
              PostDetailCommentsListView(
                post: widget.post,
                currentUser: widget.currentUser,
              ),
            ]),
      ),
    )));
  }
}
