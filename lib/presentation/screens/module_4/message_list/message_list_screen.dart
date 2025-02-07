import 'package:socialapp/utils/import.dart';
import 'package:intl/intl.dart';

class MessageListScreen extends StatefulWidget {
  const MessageListScreen({super.key});

  @override
  State<MessageListScreen> createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  late String uid = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    uid = _auth.currentUser!.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          icon: SvgPicture.asset(
            AppIcons.backButton,
            width: 55,
            height: 55,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.add_circle_outline_outlined,
              size: 45,
            ),
          )
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
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('User')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text("Error");
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasData && snapshot.data != null) {
              // Safely extract 'interacts' from the document
              final data = snapshot.data!.data();
              if (data != null && data['interacts'] is List) {
                final List interacts = data['interacts'];

                return ListView.builder(
                  itemCount: interacts.length,
                  itemBuilder: (context, index) {
                    final userRef = interacts[index];
                    String chatRoomId = _getChatRoomId(userRef.id, uid);

                    // Instead of using a helper that returns a widget,
                    // we use our dedicated ChatRoomTile widget
                    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection('ChatRoom')
                          .doc(chatRoomId)
                          .get(),
                      builder: (context, chatRoomSnapshot) {
                        if (chatRoomSnapshot.hasError) {
                          return const Text("Error fetching chat room");
                        }
                        if (chatRoomSnapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (chatRoomSnapshot.hasData && chatRoomSnapshot.data!.exists) {
                          return ChatRoomTile(
                            chatRoom: chatRoomSnapshot.data!,
                            currentUserId: uid,
                          );
                        } else {
                          return const Text("No chat room available");
                        }
                      },
                    );
                  },
                );
              } else {
                return const Text('No interactions found.');
              }
            }
            return const Text('No data available.');
          },
        ),
      ),
    );
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

  const ChatRoomTile({
    super.key,
    required this.chatRoom,
    required this.currentUserId,
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
    final currentUserRef = FirebaseFirestore.instance.doc('/User/$currentUserId');
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
            leading: CircularProgressIndicator(color: Colors.blue),
            title: Text("Loading..."),
          );
        }
        if (userSnapshot.hasError || !userSnapshot.hasData) {
          return const ListTile(
            title: Text("Error loading user info"),
          );
        }
        final otherUserSnapshot = userSnapshot.data!;
        String otherUserEmail = otherUserSnapshot['email'];
        String otherUserAvatar = otherUserSnapshot['avatar'];

        // Now that we have user info, listen to the most recent message
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('ChatRoom')
              .doc(chatRoomId)
              .collection('messages')
              .orderBy('timestamp', descending: true)
              .limit(1)
              .snapshots(),
          builder: (context, messageSnapshot) {
            if (messageSnapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                leading: CircularProgressIndicator(color: Colors.blue),
                title: Text("Loading..."),
              );
            }
            if (messageSnapshot.hasError) {
              return const ListTile(
                title: Text("Error loading messages"),
              );
            }
            final docs = messageSnapshot.data?.docs;
            final message = (docs != null && docs.isNotEmpty) ? docs.first : null;
            String recentMessage = message?['message'] ?? "No messages yet";
            String recentTime =
            message != null ? formatTime(message['timestamp']) : "";
            bool isImageMessage = message?['media'] != null;
            bool isFromUser1 = message?['isFromUser1'] ?? false;

            // Build the final chat room list tile with all gathered data
            return ChatRoomListTile(
              otherUserEmail: otherUserEmail,
              otherUserAvatar: otherUserAvatar,
              recentMessage: recentMessage,
              recentTime: recentTime,
              isImageMessage: isImageMessage,
              isFromUser1: isFromUser1,
              currentUserId: currentUserId,
              chatRoomId: chatRoomId,
              otherUserRef: otherUserRef,
              isUser1: isUser1,
            );
          },
        );
      },
    );
  }
}

class ChatRoomListTile extends StatelessWidget {
  final String otherUserEmail;
  final String otherUserAvatar;
  final String recentMessage;
  final String recentTime;
  final bool isImageMessage;
  final bool isFromUser1;
  final String currentUserId;
  final String chatRoomId;
  final DocumentReference otherUserRef;
  final bool isUser1;

  const ChatRoomListTile({
    super.key,
    required this.otherUserEmail,
    required this.otherUserAvatar,
    required this.recentMessage,
    required this.recentTime,
    required this.isImageMessage,
    required this.isFromUser1,
    required this.currentUserId,
    required this.chatRoomId,
    required this.otherUserRef,
    required this.isUser1,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey.withOpacity(0.1),
      leading: CircleAvatar(
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: otherUserAvatar,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
            const CircularProgressIndicator(color: Colors.blue),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      ),
      title: Text(otherUserEmail),
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
              style: const TextStyle(fontSize: 14),
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
            receiverUserEmail: otherUserEmail,
            receiverUserID: otherUserRef.id,
            receiverAvatar: otherUserAvatar,
          ),
        ),
      ),
    );
  }
}