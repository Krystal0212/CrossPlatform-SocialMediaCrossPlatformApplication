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
        child: FutureBuilder<List<Widget>>(
          future: _fetchAndBuildChatRooms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No chat rooms found."));
            }
            return ListView(children: snapshot.data!);
          },
        ),
      ),
    );
  }

  Future<List<Widget>> _fetchAndBuildChatRooms() async {
    final String uid = _auth.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.doc('/User/$uid');

    // Fetch chat rooms
    QuerySnapshot chatRooms1 = await FirebaseFirestore.instance
        .collection('DemoChatRoom')
        .where('user1Ref', isEqualTo: userRef)
        .get();

    QuerySnapshot chatRooms2 = await FirebaseFirestore.instance
        .collection('DemoChatRoom')
        .where('user2Ref', isEqualTo: userRef)
        .get();

    final uniqueChatRooms = <dynamic>{
      ...chatRooms1.docs,
      ...chatRooms2.docs,
    };

    // Build widgets for chat rooms
    return Future.wait(
      uniqueChatRooms.map((chatRoom) => _buildChatRoomListTile(chatRoom, uid)),
    );
  }

  Future<Widget> _buildChatRoomListTile(
      QueryDocumentSnapshot chatRoom,
      String currentUserId,
      ) async {
    String chatRoomId = chatRoom.id;
    bool isUser1 = chatRoom['user1Ref'].id == currentUserId;
    DocumentReference otherUserRef =
    isUser1 ? chatRoom['user2Ref'] : chatRoom['user1Ref'];

    // Fetch other user's info
    DocumentSnapshot otherUserSnapshot = await otherUserRef.get();
    String otherUserEmail = otherUserSnapshot['email'];
    String otherUserAvatar = otherUserSnapshot['avatar'];

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('DemoChatRoom')
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
        String recentTime = message != null ? formatTime(message['timestamp']) : "";
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
                errorWidget: (context, url, error) =>
                const Icon(Icons.error),
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
                receiverUserEmail: otherUserEmail,
                receiverUserID: otherUserRef.id,
              ),
            ),
          ),
        );
      },
    );
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
