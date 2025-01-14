import 'package:socialapp/data/sources/firestore/chat_service_impl.dart';
import 'package:socialapp/utils/import.dart';

import 'message_item.dart';

class MessageList extends StatelessWidget {

  final String receiverUserID, receiverAvatar;
  final ScrollController scrollController;

  const MessageList({
    super.key,
    required this.receiverUserID,
    required this.scrollController, required this.receiverAvatar,

  });

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    return StreamBuilder<QuerySnapshot>(
      stream: chatService.getMessages(receiverUserID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "Send your first message now",
              style: TextStyle(fontSize: 16),
            ),
          );
        } else {
          return ListView.builder(
            reverse: true,
            controller: scrollController,
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot currentDocument = snapshot.data!.docs[index];
              DocumentSnapshot? nextDocument =
              (index - 1 >= 0) ? snapshot.data!.docs[index - 1] : null;

              return MessageItem(
                document: currentDocument,
                nextDocument: nextDocument,
                chatService: chatService, receiverAvatar: receiverAvatar,
              );
            },
          );
        }
      },
    );
  }
}
