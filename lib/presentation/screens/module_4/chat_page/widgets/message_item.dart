import 'package:socialapp/data/sources/firestore/chat_service_impl.dart';
import 'package:socialapp/presentation/screens/module_4/chat_page/widgets/chat_page_properties.dart';
import 'package:socialapp/presentation/widgets/chat/image_placeholder.dart';
import 'package:socialapp/utils/import.dart';
import 'package:intl/intl.dart';


class MessageItem extends StatelessWidget with AppDialogs {
  final DocumentSnapshot document;
  final DocumentSnapshot? nextDocument;
  final ChatService chatService;
  final String receiverAvatar;

  const MessageItem({
    super.key,
    required this.document,
    required this.nextDocument,
    required this.chatService, required this.receiverAvatar,

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
    final bool isUser1 = ChatPageUserProperty.of(context);

    final Map<String, dynamic> layoutData = chatService.getMessageLayoutData(
      data,
      nextData,
      isUser1,
    );
    bool isSender = layoutData['isSender'];
    bool showAvatar = layoutData['showAvatar'];
    bool showTimestamp = layoutData['showTimestamp'];
    double spacing = layoutData['spacing'];

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
                      color: Colors.blue,
                    ),
                    errorWidget: (context, url, error) =>
                    const Icon(Icons.error),
                  ),
                ),
              )
            else
              const SizedBox(width: 40),
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth:
                          constraints.maxWidth * 0.7, // 70% of parent width
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: InkWell(
                            onTap: () => showImageDialog(context, data['imageUrl']),
                            child: CachedNetworkImage(
                              imageUrl: data["imageUrl"],
                              fit: BoxFit.fitWidth,
                              placeholder: (context, url) => ChatImagePlaceholder(
                                width: constraints.maxWidth * 0.7,
                                height:
                                MediaQuery.of(context).size.height * 0.2,
                              ),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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
