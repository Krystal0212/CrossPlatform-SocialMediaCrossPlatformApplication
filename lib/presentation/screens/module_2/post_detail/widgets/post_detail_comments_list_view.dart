import 'package:socialapp/utils/import.dart';

import '../cubit/post_detail_cubit.dart';

import 'package:dropdown_button2/dropdown_button2.dart';

const double customIconSize = 25;

class PostDetailCommentsListView extends StatefulWidget {
  final OnlinePostModel post;
  final UserModel currentUser;

  const PostDetailCommentsListView(
      {super.key, required this.post, required this.currentUser});

  @override
  State<PostDetailCommentsListView> createState() =>
      _PostDetailCommentsListViewState();
}

class _PostDetailCommentsListViewState extends State<PostDetailCommentsListView>
    with FlashMessage, Methods {
  final ValueNotifier<String?> selectedReplyCommentIdNotifier =
      ValueNotifier<String?>(null);
  final ValueNotifier<String> sortByNotifier =
      ValueNotifier<String>("mostLiked");

  final TextEditingController _replyCommentController = TextEditingController();

  @override
  void dispose() {
    sortByNotifier.dispose();
    selectedReplyCommentIdNotifier.dispose();
    _replyCommentController.dispose();
    super.dispose();
  }

  Future<void> showActionDialogForComment(BuildContext context, String postId,
      String commentId, List<CommentPostModel> comments, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to dismiss
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text(
            'Manage Comment',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('What do you want to do with this comment?',
              style: TextStyle(fontSize: 20)),
          actions: <Widget>[
            TextButton(
              child: const Icon(
                Icons.cancel,
                color: AppColors.iris,
                size: customIconSize + 4,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Icon(
                Icons.delete,
                color: AppColors.iris,
                size: customIconSize + 4,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showDeleteConfirmationDialog(
                    context, postId, commentId, comments, index);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context,
      String postId,
      String commentId,
      List<CommentPostModel> comments,
      int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text(
            'Are you sure?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
              'This action cannot be undone. Do you really want to delete the comment?',
              style: TextStyle(fontSize: 20)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  await serviceLocator
                      .get<CommentRepository>()
                      .removeComment(postId, commentId);

                  setState(() {
                    comments.removeAt(index);
                  });
                } catch (error) {
                  if (kDebugMode) {
                    print('Error deleting comment: $error');
                  }
                }
                if (!context.mounted) return;

                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double maxWidth = constraints.maxWidth * 0.9;
      return SizedBox(
        width: maxWidth,
        height: PlatformDispatcher.instance.views.first.physicalSize.height *
            0.9 /
            PlatformDispatcher.instance.views.first.devicePixelRatio,
        child: ValueListenableBuilder<String>(
            valueListenable: sortByNotifier,
            builder: (context, sortBy, _) {
              return Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Comments",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            onChanged: (value) {
                              if (value == null || value == sortBy) return;

                              sortByNotifier.value = value;
                            },
                            value: sortBy,
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 8,
                              offset: const Offset(0, -4),
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: "mostLiked",
                                  child: Text("Most Liked",
                                      style: TextStyle(color: AppColors.iris))),
                              DropdownMenuItem(
                                  value: "newest",
                                  child: Text(
                                    "Newest",
                                    style: TextStyle(color: AppColors.iris),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<CommentPostModel>>(
                      stream: serviceLocator<CommentRepository>()
                          .getCommentsStream(widget.post.postId, sortBy),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                            color: AppColors.iris,
                          )); // Show loading indicator
                        } else if (snapshot.hasError || snapshot.data == null) {
                          return const NoCommentDataAvailablePlaceholder();
                        }

                        final List<CommentPostModel> comments = snapshot.data!;
                        if (comments.isEmpty) {
                          return const NoCommentDataAvailablePlaceholder();
                        }
                        return ListView.builder(
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              if (index == comments.length) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.iris,
                                    ),
                                  ),
                                );
                              }
                              final CommentPostModel comment = comments[index];
                              ValueNotifier<bool> isUserLiked =
                                  ValueNotifier<bool>(
                                comment.likes
                                    .contains(widget.currentUser.id ?? ''),
                              );
                              return ValueListenableBuilder<String?>(
                                valueListenable: selectedReplyCommentIdNotifier,
                                builder:
                                    (context, selectedReplyCommentId, child) {
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onLongPress: () {
                                          if (comment.userId ==
                                              widget.currentUser.id) {
                                            showActionDialogForComment(
                                                context,
                                                widget.post.postId,
                                                comment.commentId!,
                                                comments,
                                                index);
                                          }
                                        },
                                        child: Card(
                                          color: AppColors.white,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 10),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12)),
                                          elevation: 3,
                                          child: Padding(
                                            padding: const EdgeInsets.all(20),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  comment.content,
                                                  style: AppTheme
                                                      .blackHeaderCommentMobileStyle
                                                      .copyWith(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  child: ValueListenableBuilder(
                                                    valueListenable:
                                                        isUserLiked,
                                                    builder:
                                                        (context, isLiked, _) {
                                                      return Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          CircleAvatar(
                                                            backgroundImage:
                                                                CachedNetworkImageProvider(
                                                                    comment
                                                                        .userAvatar!),
                                                            radius: 25,
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                    comment
                                                                        .username!,
                                                                    style: AppTheme
                                                                        .blackHeaderMobileStyle),
                                                                Text(
                                                                  "${comment.likes.length} likes",
                                                                  style: AppTheme
                                                                      .blackHeaderMobileStyle
                                                                      .copyWith(
                                                                          fontSize:
                                                                              16),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Text(
                                                              calculateTimeFromNow(
                                                                  comment
                                                                      .timestamp),
                                                              style: AppTheme
                                                                  .blackHeaderMobileStyle
                                                                  .copyWith(
                                                                      fontSize:
                                                                          16)),
                                                          const SizedBox(
                                                            width: 16,
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(
                                                              Icons.reply,
                                                              size:
                                                                  customIconSize +
                                                                      6,
                                                              color: AppColors
                                                                  .iris,
                                                            ),
                                                            onPressed: () {
                                                              if (selectedReplyCommentId ==
                                                                  comment
                                                                      .commentId) {
                                                                selectedReplyCommentIdNotifier
                                                                        .value =
                                                                    null;
                                                              } else {
                                                                selectedReplyCommentIdNotifier
                                                                        .value =
                                                                    comment
                                                                        .commentId;
                                                              }
                                                            },
                                                          ),
                                                          const SizedBox(
                                                              width: 28),
                                                          LikeButton(
                                                            isLiked: isLiked,
                                                            size:
                                                                customIconSize,
                                                            likeBuilder:
                                                                (data) =>
                                                                    SvgPicture
                                                                        .asset(
                                                              isLiked
                                                                  ? AppIcons
                                                                      .heartFilled
                                                                  : AppIcons
                                                                      .heart,
                                                            ),
                                                            onTap: (_) async {
                                                              if (widget
                                                                      .currentUser
                                                                      .id
                                                                      ?.isNotEmpty ??
                                                                  false) {
                                                                if (comment
                                                                    .likes
                                                                    .contains(widget
                                                                        .currentUser
                                                                        .id)) {
                                                                  comment.unlikeComment(
                                                                      widget
                                                                          .currentUser
                                                                          .id!);
                                                                  isUserLiked
                                                                          .value =
                                                                      false;
                                                                  context
                                                                      .read<
                                                                          PostDetailCubit>()
                                                                      .removeCommentLike(
                                                                          comment
                                                                              .commentId!);
                                                                } else {
                                                                  comment.likeComment(
                                                                      widget
                                                                          .currentUser
                                                                          .id!);
                                                                  isUserLiked
                                                                          .value =
                                                                      true;
                                                                  context
                                                                      .read<
                                                                          PostDetailCubit>()
                                                                      .addCommentLike(
                                                                          comment
                                                                              .commentId!);
                                                                }
                                                              } else {
                                                                showNotSignedInMessage(
                                                                  context:
                                                                      context,
                                                                  description:
                                                                      AppStrings
                                                                          .notSignedInCollectionDescription,
                                                                );
                                                              }
                                                              return !isLiked;
                                                            },
                                                          )
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                      if (comment.replyComments.isNotEmpty) ...[
                                        ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount:
                                                comment.replyComments.length,
                                            itemBuilder: (context, index) {
                                              ReplyCommentPostModel?
                                                  replyComment =
                                                  comment.replyComments[
                                                      index.toString()];

                                              if (replyComment != null) {
                                                ValueNotifier<bool>
                                                    isThisReplyUserLiked =
                                                    ValueNotifier<bool>(
                                                  replyComment.likes.contains(
                                                      widget.currentUser.id ??
                                                          ''),
                                                );

                                                return CommentCard(
                                                  comment: comment,
                                                  isUserLiked: isUserLiked,
                                                  selectedReplyCommentIdNotifier:
                                                      selectedReplyCommentIdNotifier,
                                                  selectedReplyCommentId:
                                                      selectedReplyCommentId,
                                                  currentUser:
                                                      widget.currentUser,
                                                  replyComment: replyComment,
                                                  post: widget.post,
                                                  isThisReplyUserLiked:
                                                      isThisReplyUserLiked,
                                                );
                                              }

                                              return const SizedBox.shrink();
                                            })
                                      ],

                                      // Show reply text field if this comment is selected
                                      if (selectedReplyCommentId ==
                                          comment.commentId)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 5),
                                          child: TextField(
                                            controller: _replyCommentController,
                                            decoration: InputDecoration(
                                              hintText:
                                                  "Reply to ${comment.username}",
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              suffixIcon: IconButton(
                                                icon: const Icon(Icons.send,
                                                    color: AppColors.iris),
                                                onPressed: () async {
                                                  final replyText =
                                                      _replyCommentController
                                                          .text
                                                          .trim();
                                                  if (replyText.isNotEmpty) {
                                                    int replyOrder = await context
                                                        .read<PostDetailCubit>()
                                                        .sendReplyComment(
                                                            widget.currentUser
                                                                .id!,
                                                            replyText,
                                                            comment.commentId!);

                                                    final UserModel
                                                        currentUser =
                                                        await context
                                                            .read<
                                                                PostDetailCubit>()
                                                            .getCurrentUser();

                                                    ReplyCommentPostModel
                                                        tempReply =
                                                        ReplyCommentPostModel(
                                                            content: replyText,
                                                            userId: widget
                                                                .currentUser.id,
                                                            username:
                                                                currentUser
                                                                    .name,
                                                            userAvatar:
                                                                currentUser
                                                                    .avatar,
                                                            timestamp:
                                                                Timestamp.now(),
                                                            likes: {});

                                                    setState(() {
                                                      comment.replyComments
                                                          .addAll({
                                                        replyOrder.toString():
                                                            tempReply
                                                      });
                                                    });

                                                    _replyCommentController
                                                        .clear();
                                                    selectedReplyCommentIdNotifier
                                                        .value = null;
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              );
                            });
                      },
                    ),
                  ),
                ],
              );
            }),
      );
    });
  }
}

class CommentCard extends StatefulWidget {
  final CommentPostModel comment;
  final ReplyCommentPostModel replyComment;
  final ValueNotifier<bool> isUserLiked;
  final ValueNotifier<String?> selectedReplyCommentIdNotifier;
  final OnlinePostModel post;
  final ValueNotifier<bool> isThisReplyUserLiked;

  final String? selectedReplyCommentId;
  final UserModel currentUser;

  const CommentCard({
    super.key,
    required this.comment,
    required this.isUserLiked,
    required this.selectedReplyCommentIdNotifier,
    required this.selectedReplyCommentId,
    required this.currentUser,
    required this.replyComment,
    required this.post,
    required this.isThisReplyUserLiked,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> with FlashMessage, Methods {
  Future<void> showActionDialogForReplyComment(
      BuildContext context,
      String postId,
      String commentId,
      Map<String, ReplyCommentPostModel> replyComments,
      String replyOrder) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text(
            'Manage Comment',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'What do you want to do with this comment?',
            style: TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            TextButton(
              child: const Icon(
                Icons.cancel,
                color: AppColors.iris,
                size: customIconSize + 4,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Icon(
                Icons.delete,
                color: AppColors.iris,
                size: customIconSize + 4,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _showDeleteConfirmationDialogForReplyComment(
                    context, postId, commentId, replyComments, replyOrder);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialogForReplyComment(
      BuildContext context,
      String postId,
      String commentId,
      Map<String, ReplyCommentPostModel> replyComments,
      String replyOrder) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text(
            'Are you sure?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
              'This action cannot be undone. Do you really want to delete the comment?',
              style: TextStyle(fontSize: 20)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  await serviceLocator
                      .get<CommentRepository>()
                      .removeReplyComment(
                          postId, commentId, int.parse(replyOrder));

                  setState(() {
                    replyComments.remove(replyOrder);
                  });
                } catch (error) {
                  if (kDebugMode) {
                    print('Error deleting reply comment: $error');
                  }
                }
                if (!context.mounted) return;
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 80),
      child: GestureDetector(
        onLongPress: () {
          if (widget.replyComment.userId == widget.currentUser.id) {
            showActionDialogForReplyComment(
                context,
                widget.post.postId,
                widget.comment.commentId!,
                widget.comment.replyComments,
                widget.replyComment.order!);
          }
        },
        child: Card(
            color: AppColors.white,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('replied to ${widget.comment.username}',
                              style: AppTheme.blackHeaderMobileStyle
                                  .copyWith(fontSize: 16))
                        ],
                      ),
                      Text(
                        widget.replyComment.content,
                        style: AppTheme.blackHeaderCommentMobileStyle.copyWith(
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: ValueListenableBuilder(
                          valueListenable: widget.isThisReplyUserLiked,
                          builder: (context, isLiked, _) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(
                                      widget.replyComment.userAvatar!),
                                  radius: 25,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(widget.replyComment.username!,
                                          style:
                                              AppTheme.blackHeaderMobileStyle),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                    calculateTimeFromNow(
                                        widget.comment.timestamp),
                                    style: AppTheme.blackHeaderMobileStyle
                                        .copyWith(fontSize: 16)),
                              ],
                            );
                          },
                        ),
                      ),
                    ]))),
      ),
    );
  }
}
