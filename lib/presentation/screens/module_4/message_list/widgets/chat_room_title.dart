import 'package:socialapp/utils/import.dart';
import 'package:intl/intl.dart';

class ChatRoomTile extends StatelessWidget {
  final Map<String, dynamic> chatRoomData;
  final String currentUserId;
  final UserModel currentUser;
  final int index;
  final bool isWaiting;
  final ChatService _chatService = ChatServiceImpl();

  ChatRoomTile({
    super.key,
    required this.chatRoomData,
    required this.currentUserId,
    required this.currentUser,
    required this.isWaiting,
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
    String chatRoomId = chatRoomData['id'];
    bool isUser1 = chatRoomData['user1Ref'] == currentUserRef;
    // Determine the other user based on stored references
    DocumentReference otherUserRef =
    isUser1 ? chatRoomData['user2Ref'] : chatRoomData['user1Ref'];

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
              isWaiting: isWaiting,
              index: index,
              currentUser: currentUser,
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
  final bool isUser1, isWaiting;
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
    required this.currentUser, required this.isWaiting,
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
        onTap: () => isWaiting ? Navigator.pushReplacement(
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
        ) : Navigator.push(
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
