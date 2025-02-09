import 'package:socialapp/utils/import.dart';
import 'package:intl/intl.dart';

import '../add_contact/add_contact_screen.dart';
import 'cubits/message_list_screen_cubit.dart';
import 'cubits/message_list_screen_state.dart';
import 'providers/user_data_properties.dart';

class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MessageListScreenCubit(),
        child: const MessageListBase());
  }
}

class MessageListBase extends StatefulWidget {
  const MessageListBase({super.key});

  @override
  State<MessageListBase> createState() => _MessageListBaseState();
}

class _MessageListBaseState extends State<MessageListBase> {
  late double deviceWidth = 0, deviceHeight = 0;

  @override
  void initState() {
    super.initState();

    final flutterView = PlatformDispatcher.instance.views.first;
    deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    deviceHeight = flutterView.physicalSize.height;
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageListScreenCubit, MessageListScreenState>(
        builder: (context, state) {
      if (state is MessageListScreenLoaded) {
        UserModel currentUser = state.userModel;
        return UserDataInheritedWidget(
          currentUser: currentUser,
          child: Scaffold(
            appBar: AppBar(
              scrolledUnderElevation: 0,
              elevation: 0,
              // Disable default AppBar elevation
              leading: IconButton(
                style: ButtonStyle(
                  elevation: WidgetStateProperty.all(0.0),
                  // Remove tap effect
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_left, size: 40,),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  // Add right padding
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const AddContactScreen()));
                    },
                    icon: const Icon(
                      Icons.add_circle_outline_outlined,
                      size: 40,
                    ),
                  ),
                ),
              ],
              backgroundColor: AppColors.white,
              title: Text(
                'Message',
                style: AppTheme.messageStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 35, bottom: 10),
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: context.read<MessageListScreenCubit>().getChatListSnapshot(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      (snapshot.hasData && currentUser.id == null)) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: AppColors.iris,
                    ));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    // Safely extract 'interacts' from the document
                    final data = snapshot.data!.data();
                    if (data != null && data['interacts'] is List) {
                      final List interacts = data['interacts'];

                      return ListView.builder(
                        itemCount: interacts.length,
                        itemBuilder: (context, index) {
                          final userRef = interacts[index];
                          String chatRoomId =
                              _getChatRoomId(userRef.id, currentUser.id!);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: FutureBuilder<
                                DocumentSnapshot<Map<String, dynamic>>>(
                              future: FirebaseFirestore.instance
                                  .collection('ChatRoom')
                                  .doc(chatRoomId)
                                  .get(),
                              builder: (context, chatRoomSnapshot) {
                                if (chatRoomSnapshot.hasError) {
                                  return const Text("Error fetching chat room");
                                }
                                if (chatRoomSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox(
                                    height: deviceHeight * 0.3,
                                    child: const Center(
                                        child: CircularProgressIndicator(
                                      color: AppColors.iris,
                                    )),
                                  );
                                }
                                if (chatRoomSnapshot.hasData &&
                                    chatRoomSnapshot.data!.exists) {
                                  return ChatRoomTile(
                                    chatRoom: chatRoomSnapshot.data!,
                                    currentUserId: currentUser.id!,
                                    index: index,
                                  );
                                } else {
                                  return const Text("No chat room available");
                                }
                              },
                            ),
                          );
                        },
                      );
                    } else {
                      return NoContactsAvailablePlaceholder(
                        width: deviceWidth,
                      );
                    }
                  }
                  return NoContactsAvailablePlaceholder(
                    width: deviceWidth,
                  );
                },
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  String _getChatRoomId(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort(); // sort to ensure a consistent chatRoomId between users
    return ids.join("_");
  }
}

class ChatRoomTile extends StatelessWidget {
  final DocumentSnapshot<Map<String, dynamic>> chatRoom;
  final String currentUserId;
  final int index;
  final ChatService _chatService = ChatServiceImpl();

  ChatRoomTile({
    super.key,
    required this.chatRoom,
    required this.currentUserId,
    required this.index,
  });

  String formatTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    DateTime now = DateTime.now();

    if (DateFormat('yyyyMMdd').format(dateTime) ==
        DateFormat('yyyyMMdd').format(now)) {
      return "Today at ${DateFormat('HH:mm').format(dateTime)}";
    } else if (DateFormat('yyyyMMdd').format(dateTime) ==
        DateFormat('yyyyMMdd').format(now.subtract(const Duration(days: 1)))) {
      return "Yesterday at ${DateFormat('HH:mm').format(dateTime)}";
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Create a reference to the current user
    final currentUserRef =
        FirebaseFirestore.instance.doc('/User/$currentUserId');
    String chatRoomId = chatRoom.id;
    bool isUser1 = chatRoom['user1Ref'] == currentUserRef;
    // Determine the other user based on stored references
    DocumentReference otherUserRef =
        isUser1 ? chatRoom['user2Ref'] : chatRoom['user1Ref'];

    // First, fetch the other user’s details
    return FutureBuilder<DocumentSnapshot>(
      future: otherUserRef.get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircularProgressIndicator(color: AppColors.iris),
            title: Text("Loading..."),
          );
        }
        if (userSnapshot.hasError || !userSnapshot.hasData) {
          return const ListTile(
            title: Text("Error loading user info"),
          );
        }
        final otherUserSnapshot = userSnapshot.data!;
        String otherUserName = otherUserSnapshot['name'];
        String otherUserAvatar = otherUserSnapshot['avatar'];

        // Now that we have user info, listen to the most recent message
        return StreamBuilder<QuerySnapshot>(
          stream: _chatService.getMessagesStream(chatRoomId),
          builder: (context, messageSnapshot) {
            if (messageSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.iris));
            }
            if (messageSnapshot.hasError) {
              return const ListTile(
                title: Text("Error loading messages"),
              );
            }
            final docs = messageSnapshot.data?.docs;
            final message =
                (docs != null && docs.isNotEmpty) ? docs.first : null;
            String recentMessage = message?['message'] ?? "No messages yet";
            String recentTime =
                message != null ? formatTime(message['timestamp']) : "";
            bool isImageMessage = message?['media'] != null;
            bool isFromUser1 = message?['isFromUser1'] ?? false;

            // Build the final chat room list tile with all gathered data
            return ChatRoomListTile(
              otherUserName: otherUserName,
              otherUserAvatar: otherUserAvatar,
              recentMessage: recentMessage,
              recentTime: recentTime,
              isImageMessage: isImageMessage,
              isFromUser1: isFromUser1,
              currentUserId: currentUserId,
              chatRoomId: chatRoomId,
              otherUserRef: otherUserRef,
              isUser1: isUser1,
              index: index,
              currentUser: UserDataInheritedWidget.of(context)!.currentUser,
            );
          },
        );
      },
    );
  }
}

class ChatRoomListTile extends StatelessWidget {
  final String otherUserName;
  final String otherUserAvatar;
  final String recentMessage;
  final String recentTime;
  final bool isImageMessage;
  final bool isFromUser1;
  final String currentUserId;
  final String chatRoomId;
  final DocumentReference otherUserRef;
  final bool isUser1;
  final int index;
  final UserModel currentUser;

  const ChatRoomListTile({
    super.key,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.recentMessage,
    required this.recentTime,
    required this.isImageMessage,
    required this.isFromUser1,
    required this.currentUserId,
    required this.chatRoomId,
    required this.otherUserRef,
    required this.isUser1,
    required this.index,
    required this.currentUser,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: index.isOdd
            ? AppColors.iris.withOpacity(0.1)
            : AppColors.trolleyGrey.withOpacity(0.1), // Check index
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 40, // Set the radius for a circular avatar
          backgroundColor: AppColors.iris,
          backgroundImage: CachedNetworkImageProvider(
              otherUserAvatar), // Use CachedNetworkImageProvider directly
        ),
        title: Text(otherUserName,
            style: AppTheme.blackUsernameMobileStyle
                .copyWith(fontWeight: FontWeight.w700)),
        subtitle: Row(
          children: [
            Expanded(
              child: Text(
                isImageMessage
                    ? (isFromUser1 == isUser1
                        ? "You: Sent a picture"
                        : "Sent you a picture")
                    : (isFromUser1 == isUser1
                        ? "You: $recentMessage"
                        : recentMessage),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.blackUsernameMobileStyle.copyWith(
                  fontSize: 16,
                  color: AppColors.trolleyGrey,
                ),
              ),
            ),
            if (recentTime.isNotEmpty)
              Text(
                " · $recentTime",
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              isUser1: isUser1,
              receiverUserEmail: otherUserName,
              receiverUserID: otherUserRef.id,
              receiverAvatar: otherUserAvatar,
              currentUser: currentUser,
            ),
          ),
        ),
      ),
    );
  }
}
