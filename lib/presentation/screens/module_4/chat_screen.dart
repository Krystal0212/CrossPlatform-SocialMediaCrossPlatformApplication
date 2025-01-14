import 'package:socialapp/utils/import.dart';
import 'package:intl/intl.dart';
import 'chat_page/chat_page.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        backgroundColor: Colors.lightBlueAccent,
        title: const Text(
          "My box",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _userList(),
      ),
    );
  }

  Widget _userList() {
    final String uid = _auth.currentUser!.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('User').doc(uid).snapshots(),
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

            return ListView(
              children: interacts
                  .map<Widget>((userRef) => _fetchAndBuildChatRooms(userRef.id, uid))
                  .toList(),
            );
          } else {
            return const Text('No interactions found.');
          }
        }
        return const Text('No data available.');
      },
    );
  }


  Widget _fetchAndBuildChatRooms(String secondUID, String uID) {
    String chatRoomId = _getChatRoomId(uID, secondUID);

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc(chatRoomId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error fetching chat room");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          return FutureBuilder<Widget>(
            future: _buildChatRoomListTile(snapshot.data!, uID),
            builder: (context, tileSnapshot) {
              if (tileSnapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (tileSnapshot.hasError) {
                if (kDebugMode) {
                  print("Error building chat room list tile");
                  return const SizedBox();
                }
              }
              return tileSnapshot.data ?? const Text("No data available");
            },
          );
        } else {
          return const Text("No chat room available");
        }
      },
    );
  }

  Future<Widget> _buildChatRoomListTile(
    DocumentSnapshot<Map<String, dynamic>> chatRoom,
    String currentUserId,
  ) async {
    final currentUserRef =
        FirebaseFirestore.instance.doc('/User/$currentUserId');
    String chatRoomId = chatRoom.id;
    bool isUser1 = chatRoom['user1Ref'] == currentUserRef;
    DocumentReference otherUserRef =
        isUser1 ? chatRoom['user2Ref'] : chatRoom['user1Ref'];

    // Fetch other user's info
    DocumentSnapshot otherUserSnapshot = await otherUserRef.get();
    String otherUserEmail = otherUserSnapshot['email'];
    String otherUserAvatar = otherUserSnapshot['avatar'];

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('ChatRoom')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            leading: CircularProgressIndicator(color: Colors.blue),
            title: Text("Loading..."),
          );
        }

        final message = snapshot.data?.docs.first;
        String recentMessage = message?['message'] ?? "No messages yet";
        String recentTime =
            message != null ? formatTime(message['timestamp']) : "";
        bool isImageMessage = message?['imageUrl'] != null;
        bool isFromUser1 = message?['isFromUser1'] ?? false;

        return ListTile(
          tileColor: Colors.grey.withOpacity(0.1),
          leading: CircleAvatar(
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: otherUserAvatar,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
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
                      ? isFromUser1 == isUser1
                          ? "You: Sent a picture"
                          : "Sent you a picture"
                      : isFromUser1 == isUser1
                          ? "You: $recentMessage"
                          : recentMessage,
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
      },
    );
  }

  String _getChatRoomId(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort(); // Sort ids to ensure chatRoomId is the same for every pair of chatter
    String chatRoomId = ids.join("_");
    return chatRoomId;
  }

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
}
