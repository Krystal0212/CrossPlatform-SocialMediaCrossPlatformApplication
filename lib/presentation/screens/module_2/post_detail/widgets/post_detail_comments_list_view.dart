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
  DocumentSnapshot? lastDoc;
  bool canTriggerLoadMore = false;

  List<CommentPostModel> _currentComments = [];

  final StreamController<List<CommentPostModel>> _commentsStreamController =
      StreamController<List<CommentPostModel>>.broadcast();
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<String?> selectedReplyCommentIdNotifier =
      ValueNotifier<String?>(null);
  final ValueNotifier<String> sortByNotifier =
      ValueNotifier<String>("mostLiked");

  final TextEditingController _replyCommentController = TextEditingController();

  late StreamSubscription _commentStream;

  @override
  void initState() {
    super.initState();
    _loadInitialComments().then((_) {
      _listenForNewComments();
    });
  }

  @override
  void dispose() {
    sortByNotifier.dispose();
    selectedReplyCommentIdNotifier.dispose();
    _replyCommentController.dispose();
    _commentStream.cancel();
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
          title: const Text('Manage Comment', style: TextStyle(fontWeight: FontWeight.bold),),
          content: const Text('What do you want to do with this comment?',style: TextStyle(fontSize: 20)),
          actions: <Widget>[
            TextButton(
              child: const Icon(Icons.cancel, color: AppColors.iris,size: customIconSize+4,),
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop();
              },
            ),
            TextButton(
              child: const Icon(Icons.delete, color: AppColors.iris,size: customIconSize+4,),
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
          title: const Text('Are you sure?', style: TextStyle(fontWeight: FontWeight.bold),),
          content: const Text(
              'This action cannot be undone. Do you really want to delete the comment?',style: TextStyle(fontSize: 20)),
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
                if(!context.mounted) return;

                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showActionDialogForReplyComment(BuildContext context, String postId,
      String commentId, Map<String, ReplyCommentPostModel> replyComments,
      String replyOrder) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text('Manage Comment', style: TextStyle(fontWeight: FontWeight.bold),),
          content: const Text('What do you want to do with this comment?', style: TextStyle(fontSize: 20),),
          actions: <Widget>[
            TextButton(
              child: const Icon(Icons.cancel, color: AppColors.iris, size: customIconSize+4,),
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop();
              },
            ),
            TextButton(
              child: const Icon(Icons.delete, color: AppColors.iris,size: customIconSize+4,),
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
          title: const Text('Are you sure?', style: TextStyle(fontWeight: FontWeight.bold),),
          content: const Text(
              'This action cannot be undone. Do you really want to delete the comment?',style: TextStyle(fontSize: 20)),
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
                      .removeReplyComment(postId, commentId, int.parse(replyOrder));

                  setState(() {
                    replyComments.remove(replyOrder);
                  });
                } catch (error) {
                  if (kDebugMode) {
                    print('Error deleting reply comment: $error');
                  }
                }
                if(!context.mounted) return;
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadInitialComments() async {
    try {
      List<CommentPostModel> initialComments =
          await serviceLocator<CommentRepository>()
              .fetchInitialComments(widget.post.postId, sortByNotifier.value);
      _currentComments = initialComments;
      canTriggerLoadMore = true;

      if (_currentComments.isNotEmpty) {
        lastDoc = _currentComments.last.documentSnapshot;
      }

      _commentsStreamController.add(List.from(_currentComments));
    } catch (error) {
      if (kDebugMode) {
        print('Error fetching comments for posts: $error');
      }
      throw Exception('Failed to fetch comments');
    }
  }

  void _listenForNewComments() async {
    _commentStream = serviceLocator<CommentRepository>()
        .getCommentStream(widget.post.postId)
        .listen((newComment) {
      final String currentMode = sortByNotifier.value;

      try {
        if(newComment != null){
        if (currentMode == "newest") {
          bool shouldAdd = !_currentComments
              .any((comment) => comment.commentId == newComment.commentId);
          if (shouldAdd) {
            _currentComments = [newComment, ..._currentComments];
          }
          _commentsStreamController.add(List.from(_currentComments));
        } else if (currentMode == "mostLiked") {
          if (_currentComments.isEmpty) {
            _currentComments = [newComment, ..._currentComments];
            _commentsStreamController.add(List.from(_currentComments));
          } else {
            final int minLikes = _currentComments.last.likes.length;

            bool shouldAdd = (newComment.likes.length >= minLikes) &&
                (!_currentComments.any(
                    (comment) => comment.commentId == newComment.commentId));

            if (shouldAdd) {
              _currentComments.add(newComment);

              _commentsStreamController.add(List.from(_currentComments));
            }
          }
        }
        }
      } catch (error) {
        if (kDebugMode) {
          print('Error during listen for new comments: $error');
        }
      }
    });
  }

  Future<void> _loadMoreComments() async {
    if (isLoadingNotifier.value || lastDoc == null) return;

    isLoadingNotifier.value = true;

    try {
      List<CommentPostModel> moreComments =
          await serviceLocator<CommentRepository>().fetchMoreComments(
        widget.post.postId,
        sortByNotifier.value,
        lastDoc!,
      );

      if (moreComments.isNotEmpty) {
        _currentComments.addAll(moreComments);
        _currentComments = _currentComments.toSet().toList();
        lastDoc = _currentComments.last.documentSnapshot;

        _commentsStreamController.add(List.from(_currentComments));
      }
    } catch (error) {
      if (error == 'no-more-newest-comments' ||
          error == 'no-more-most-liked-comments') {
        canTriggerLoadMore = false;
      } else if (kDebugMode) {
        print('Error during load more comments: $error');
      }
    } finally {
      isLoadingNotifier.value = false;
    }
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Comments",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ValueListenableBuilder<String>(
                    valueListenable: sortByNotifier,
                    builder: (context, sortBy, _) {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          onChanged: (value) {
                            if (value != null) {
                              sortByNotifier.value = value;

                              _commentsStreamController.add([]);

                              _loadInitialComments().then((_) {
                                _commentStream.cancel();

                                _listenForNewComments();
                              });
                            }
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
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<CommentPostModel>>(
                stream: _commentsStreamController.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.iris,
                      ),
                    );
                  }
                  final List<CommentPostModel> comments = snapshot.data!;
                  if (comments.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.iris,
                      ),
                    );
                  }
                  return NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels >=
                              scrollInfo.metrics.maxScrollExtent - 50 &&
                          canTriggerLoadMore) {
                        _loadMoreComments();
                      }
                      return false;
                    },
                    child: ValueListenableBuilder<bool>(
                        valueListenable: isLoadingNotifier,
                        builder: (context, isLoading, child) {
                          return ListView.builder(
                              itemCount: comments.length + (isLoading ? 1 : 0),
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
                                final CommentPostModel comment =
                                    comments[index];
                                ValueNotifier<bool> isUserLiked =
                                    ValueNotifier<bool>(
                                  comment.likes
                                      .contains(widget.currentUser.id ?? ''),
                                );
                                return ValueListenableBuilder<String?>(
                                  valueListenable:
                                      selectedReplyCommentIdNotifier,
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
                                                        .symmetric(
                                                        horizontal: 5),
                                                    child:
                                                        ValueListenableBuilder(
                                                      valueListenable:
                                                          isUserLiked,
                                                      builder: (context,
                                                          isLiked, _) {
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
                                                                selectedReplyCommentIdNotifier
                                                                    .value = (selectedReplyCommentId ==
                                                                        comment
                                                                            .commentId)
                                                                    ? null
                                                                    : comment
                                                                        .commentId;
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
                                                                    comment.unlikeComment(widget
                                                                        .currentUser
                                                                        .id!);
                                                                    isUserLiked
                                                                            .value =
                                                                        false;
                                                                    context
                                                                        .read<
                                                                            PostDetailCubit>()
                                                                        .removeCommentLike(
                                                                            comment.commentId!);
                                                                  } else {
                                                                    comment.likeComment(widget
                                                                        .currentUser
                                                                        .id!);
                                                                    isUserLiked
                                                                            .value =
                                                                        true;
                                                                    context
                                                                        .read<
                                                                            PostDetailCubit>()
                                                                        .addCommentLike(
                                                                            comment.commentId!);
                                                                  }
                                                                } else {
                                                                  showNotSignedInMassage(
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

                                        if (comment
                                            .replyComments.isNotEmpty) ...[
                                          ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  comment.replyComments.length,
                                              itemBuilder: (context, index) {
                                                ReplyCommentPostModel
                                                    replyComment =
                                                    comment.replyComments[
                                                        index.toString()]!;
                                                ValueNotifier<bool>
                                                    isThisReplyUserLiked =
                                                    ValueNotifier<bool>(
                                                  replyComment.likes.contains(
                                                      widget.currentUser.id ??
                                                          ''),
                                                );
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 80),
                                                  child: GestureDetector(
                                                    onLongPress: () {
                                                      if (replyComment.userId ==
                                                          widget.currentUser.id) {
                                                        showActionDialogForReplyComment(
                                                            context,
                                                            widget.post.postId,
                                                            comment.commentId!,
                                                            comment.replyComments,
                                                            replyComment.order!);
                                                      }
                                                    },
                                                    child: Card(
                                                        color: AppColors.white,
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 8,
                                                            horizontal: 10),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12)),
                                                        elevation: 3,
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(20),
                                                            child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      Text(
                                                                          'replied to ${comment.username}',
                                                                          style: AppTheme
                                                                              .blackHeaderMobileStyle
                                                                              .copyWith(fontSize: 16))
                                                                    ],
                                                                  ),
                                                                  Text(
                                                                    replyComment
                                                                        .content,
                                                                    style: AppTheme
                                                                        .blackHeaderCommentMobileStyle
                                                                        .copyWith(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                      height: 10),
                                                                  Padding(
                                                                    padding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            5),
                                                                    child:
                                                                        ValueListenableBuilder(
                                                                      valueListenable:
                                                                          isThisReplyUserLiked,
                                                                      builder:
                                                                          (context,
                                                                              isLiked,
                                                                              _) {
                                                                        return Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            CircleAvatar(
                                                                              backgroundImage:
                                                                                  CachedNetworkImageProvider(replyComment.userAvatar!),
                                                                              radius:
                                                                                  25,
                                                                            ),
                                                                            const SizedBox(
                                                                                width: 8),
                                                                            Expanded(
                                                                              child:
                                                                                  Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(replyComment.username!, style: AppTheme.blackHeaderMobileStyle),
                                                                                  Text(
                                                                                    "${replyComment.likes.length} likes",
                                                                                    style: AppTheme.blackHeaderMobileStyle.copyWith(fontSize: 16),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            const SizedBox(
                                                                                width: 16),
                                                                            Text(
                                                                                calculateTimeFromNow(comment.timestamp),
                                                                                style: AppTheme.blackHeaderMobileStyle.copyWith(fontSize: 16)),
                                                                          ],
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                ]))),
                                                  ),
                                                );
                                              })
                                        ],

                                        // Show reply text field if this comment is selected
                                        if (selectedReplyCommentId ==
                                            comment.commentId)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 5),
                                            child: TextField(
                                              controller:
                                                  _replyCommentController,
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
                                                          .read<
                                                              PostDetailCubit>()
                                                          .sendReplyComment(
                                                              widget.currentUser
                                                                  .id!,
                                                              replyText,
                                                              comment
                                                                  .commentId!);

                                                      final UserModel
                                                          currentUser =
                                                          await context
                                                              .read<
                                                                  PostDetailCubit>()
                                                              .getCurrentUser();

                                                      ReplyCommentPostModel
                                                          tempReply =
                                                          ReplyCommentPostModel(
                                                              content:
                                                                  replyText,
                                                              userId: widget
                                                                  .currentUser
                                                                  .id,
                                                              username:
                                                                  currentUser
                                                                      .name,
                                                              userAvatar:
                                                                  currentUser
                                                                      .avatar,
                                                              timestamp:
                                                                  Timestamp
                                                                      .now(),
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
                        }),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}
