import 'package:socialapp/data/sources/firestore/chat_service_impl.dart';
import 'package:socialapp/utils/import.dart';

import 'package:intl/intl.dart';

import 'chat_page_properties.dart';
import 'message_image_grid_display.dart';

class MessageList extends StatelessWidget {
  final String receiverUserID, receiverAvatar;
  final ScrollController scrollController;
  final ChatService chatService = ChatServiceImpl();

  MessageList({
    super.key,
    required this.receiverUserID,
    required this.scrollController,
    required this.receiverAvatar,
  });

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: StreamBuilder<QuerySnapshot>(
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
                  return NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: ListView.builder(
                      shrinkWrap: true,
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
                          chatService: chatService,
                          receiverAvatar: receiverAvatar,
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MessageItem extends StatelessWidget {
  final DocumentSnapshot document;
  final DocumentSnapshot? nextDocument;
  final ChatService chatService;
  final String receiverAvatar;

  const MessageItem({
    super.key,
    required this.document,
    required this.nextDocument,
    required this.chatService,
    required this.receiverAvatar,
  });

  // Function to format time
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
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    Map<String, dynamic>? nextData =
        nextDocument?.data() as Map<String, dynamic>?;
    final bool isUser1 = ChatPageUserProperty.of(context).isUser1;

    final Map<String, dynamic> layoutData = chatService.getMessageLayoutData(
      data,
      nextData,
      isUser1,
    );
    bool isSender = layoutData['isSender'];
    bool showAvatar = layoutData['showAvatar'];
    bool showTimestamp = layoutData['showTimestamp'];
    double spacing = layoutData['spacing'];

    double deviceWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing, left: 8.0, right: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isSender) ...[
            if (showAvatar)
              CircleAvatar(
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: receiverAvatar,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(
                      color: AppColors.blueDeFrance,
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
              )
            else
              const SizedBox(width: 40),
            const SizedBox(width: 16.0),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (data['media'] != null && (data['media'] as Map).isNotEmpty)
                  ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: deviceWidth * 0.7, // 70% of parent width
                      ),
                      child: ImageDisplayGrid(
                        rawMediaData: data['media'],
                      )),
                if (data['message'].isNotEmpty)
                  ChatBubble(
                    message: data['message'],
                    isSender: isSender,
                  ),
                if (showTimestamp)
                  Text(
                    formatTime(data['timestamp']),
                    style: TextStyle(color: Colors.grey[600], fontSize: 11.0),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSender;

  const ChatBubble({super.key, required this.message, required this.isSender});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.7,
        minWidth: 0,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSender
              ? AppColors.lavenderBlueShadow.withOpacity(0.2)
              : AppColors.christmasSilver.withOpacity(0.2),
        ),
        child: Text(
          message,
          style: AppTheme.messageStyle,
        ),
      ),
    );
  }
}
