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
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(AppColors.white),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        title: const Text(
          "My box",
          style: TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _userList(),
      ),
    );
  }

  // User List here
  Widget _userList() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("User")
            // .where('followers', arrayContains: _auth.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Error");
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                  SizedBox(
                    height: 4.0,
                  ),
                  Text("Fetching user list...")
                ],
              ),
            );
          }
          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
            // Followers handle here in future
            return const Center(
              child: Text("No user available"),
            );
          } else {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return _userListItem(snapshot.data!.docs[index]);
                });
          }
        });
  }

  Widget _userListItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;

    // Display all users except the current user
    if (_auth.currentUser!.email != data["email"]) {
      String chatRoomId = _getChatRoomId(_auth.currentUser!.uid, document.id);

      return StreamBuilder<QuerySnapshot>(
        // get new message for display
        stream: FirebaseFirestore.instance
            .collection("chat_rooms")
            .doc(chatRoomId)
            .collection("messages")
            .orderBy("timestamp", descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Column(
              children: [
                ListTile(
                  leading: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                  title: Text("Loading..."),
                ),
                SizedBox(
                  height: 5.0,
                ),
              ],
            );
          }

          String recentMessage = "Send your first message";
          String recentTime = "No time available";
          bool isImageMessage = false;
          bool isSender = false;
          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            var document = snapshot.data!.docs.first;
            recentMessage = document["message"];
            recentTime = formatTime(document["timestamp"]);
            isImageMessage = (document["imageUrl"] == null) ? false : true;
            isSender =
                (document["senderId"] != _auth.currentUser!.uid) ? false : true;
          }

          return Column(
            children: [
              ListTile(
                tileColor: Colors.grey.withOpacity(0.1),
                leading: CircleAvatar(
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: data["avatar"],
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),
                title: Text(
                  data["email"],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (!isImageMessage)
                            ? (!isSender)
                                ? recentMessage
                                : "You: $recentMessage"
                            : (!isSender)
                                ? "Sent you a picture"
                                : "You: Sent a picture",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      (recentTime != "No time available")
                          ? " · $recentTime"
                          : "",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        receiverUserEmail: data["email"],
                        receiverUserID: document.id,
                        receiverAvatar: data["avatar"],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(
                height: 5.0,
              ),
            ],
          );
        },
      );
    } else {
      return Container();
    }
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
