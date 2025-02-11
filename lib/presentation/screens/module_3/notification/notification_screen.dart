import 'package:socialapp/presentation/screens/module_3/notification/cubit/notification_state.dart';
import 'package:socialapp/utils/import.dart';
import 'cubit/notification_cubit.dart';

class NotificationScreen extends StatelessWidget {
  final bool isSignedIn;

  const NotificationScreen({super.key, required this.isSignedIn});

  @override
  Widget build(BuildContext context) {
    if (!isSignedIn) {
      return const NoUserIsSignedInPlaceholder();
    }
    return BlocProvider(
      create: (context) => NotificationCubit(),
      child: const NotificationBase(),
    );
  }
}

class NotificationBase extends StatefulWidget {
  const NotificationBase({super.key});

  @override
  State<NotificationBase> createState() => _NotificationBaseState();
}

class _NotificationBaseState extends State<NotificationBase> with Methods {
  double deviceWidth = 0;
  double deviceHeight = 0;

  @override
  void initState() {
    super.initState();

    final flutterView = PlatformDispatcher.instance.views.first;
    deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    deviceHeight = flutterView.physicalSize.height;
  }

  @override
  void dispose() {
    context.read<NotificationCubit>().close();

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void showNotificationDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return BlocProvider(
          create: (context) => NotificationCubit(),
          child: AlertDialog(
            backgroundColor: AppColors.white,
            title: const Text('Remove Notification'),
            content:
                const Text('Do you want to remove all read notifications?'),
            actions: <Widget>[
              BlocConsumer<NotificationCubit, NotificationState>(
                listener: (context, state) {
                  if (state is NotificationDeleteSuccess) {
                    Navigator.pop(context);
                  }
                },
                builder: (context, state) => AuthElevatedButton(
                  width: double.infinity,
                  height: 45,
                  inputText: 'Remove',
                  onPressed: () {
                    context.read<NotificationCubit>().removeReadNotification();
                  },
                  isLoading: state is NotificationDeleting,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(deviceHeight * 0.04),
        child: Padding(
          padding: const EdgeInsets.only(top: 20, right: 16, left: 16),
          child: AppBar(
            title: Text(
              'Notification',
              style: AppTheme.messageStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  showNotificationDialog(
                    context,
                  );
                },
                icon: SvgPicture.asset(
                  AppIcons.setting,
                  width: 40,
                ),
              ),
            ],
            backgroundColor: AppColors.white,
          ),
        ),
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 35, bottom: 10),
        child: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading || state is NotificationInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is NotificationLoaded) {
              return StreamBuilder<List<NotificationModel>>(
                stream: state.notificationListStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.3,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.iris,
                          ),
                        ));
                  }

                  if (!snapshot.hasData ||
                      snapshot.data == null ||
                      snapshot.data!.isEmpty) {
                    return const Center(child: Text("No notifications yet"));
                  }

                  List<NotificationModel> notifications = snapshot.data!;
                  Map<String, bool> isReadMap = {};

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final NotificationModel notification =
                          notifications[index];
                      DocumentReference otherUserRef = notification.fromUserRef;
                      Future<UserModel> fromUser = context
                          .read<NotificationCubit>()
                          .getUserDataFromUserRef(otherUserRef);
                      return FutureBuilder(
                          future: fromUser,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.iris,
                                ),
                              );
                            } else if (snapshot.hasData) {
                              UserModel otherUser = snapshot.data!;
                              String otherUserAvatar = otherUser.avatar;
                              String otherUserName = otherUser.name;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: NotificationTile(
                                  avatarUrl: otherUserAvatar,
                                  username: otherUserName,
                                  notification: notification,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          });
                    },
                  );
                },
              );
            } else {
              return NoUserDataAvailablePlaceholder(
                width: MediaQuery.of(context).size.width * 0.9,
              );
            }
          },
        ),
      ),
    );
  }
}

class NotificationTile extends StatelessWidget with Methods {
  final String avatarUrl;
  final String username;
  final NotificationModel notification;
  late bool _isProcessing = false;

  NotificationTile({
    super.key,
    required this.avatarUrl,
    required this.username,
    required this.notification,
  });

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case "like":
        return Icons.favorite;
      case "comment":
        return Icons.comment;
      case "add_to_collection":
        return Icons.bookmark;
      case "message":
        return Icons.message;
      case "send_asset":
        return Icons.attach_file;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationText(String data) {
    switch (data) {
      case "like":
        return "liked your post.";
      case "comment":
        return "commented on your post.";
      case "commentLike":
        return "liked your comment in a post.";
      case "textMessage":
        return "sent you a message text.";
      case "singleImageMessage":
        return "sent you an image.";
      case "multipleImageMessage":
        return "sent you some images.";
      case "commentReply":
        return "replied to your comment in a post.";
      default:
        return "You have a new notification.";
    }
  }

  void handleTap(BuildContext context) async {
    if (_isProcessing) return; // Prevent multiple taps
    _isProcessing = true;
    UserModel currentUser =
        (await serviceLocator.get<UserRepository>().getCurrentUserData())!;

    context
        .read<NotificationCubit>()
        .addNotificationReadStatus(notification.id);

    if (notification.type == "like" ||
        notification.type == "commentReply" ||
        notification.type == "comment" ||
        notification.type == "commentLike") {
      OnlinePostModel post = await serviceLocator
          .get<PostRepository>()
          .getDataFromPostId(notification.postId!);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PostDetailScreen(
                post: post,
                currentUser: currentUser,
                searchController: TextEditingController(),
              )));
    }

    if (notification.type == "textMessage" ||
        notification.type == "singleImageMessage" ||
        notification.type == "multipleImageMessage") {
      ChatService chatService = ChatServiceImpl();
      DocumentReference otherUserRef = notification.fromUserRef;
      UserModel otherUser = await context
          .read<NotificationCubit>()
          .getUserDataFromUserRef(otherUserRef);
      String otherUserAvatar = otherUser.avatar;
      String otherUserName = otherUser.name;
      bool isUser1 = await chatService.checkIsUser1(otherUserRef.id);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatPage(
            isUser1: isUser1,
            receiverUserEmail: otherUserName,
            receiverUserID: otherUserRef.id,
            receiverAvatar: otherUserAvatar,
            currentUser: currentUser,
          ),
        ),
      );
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.iris.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            handleTap(context);
          },
          borderRadius: BorderRadius.circular(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 35, // Increased size
                backgroundColor: AppColors.iris,
                backgroundImage: CachedNetworkImageProvider(avatarUrl),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            username,
                            style: AppTheme.blackUsernameMobileStyle.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 25,
                            ),
                          ),
                          Text(
                            _getNotificationText(notification.type),
                            style: AppTheme.blackHeaderMobileStyle
                                .copyWith(fontSize: 19, color: AppColors.iris),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(
                            calculateTimeFromNow(notification.timestamp),
                            style: AppTheme.blackHeaderMobileStyle
                                .copyWith(fontSize: 19),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Icon(_getNotificationIcon(notification.type),
                            size: 35, color: AppColors.blackOak),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
