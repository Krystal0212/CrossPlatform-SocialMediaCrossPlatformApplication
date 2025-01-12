import 'package:socialapp/data/sources/chat/chat_service.dart';
import 'package:socialapp/utils/import.dart';
import 'package:intl/intl.dart';
import 'package:socialapp/presentation/widgets/chat/message_input.dart';
import 'package:palette_generator/palette_generator.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  const ChatPage(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with AppDialogs {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ScrollController _scrollController =
      ScrollController(); // ScrollController
  final ValueNotifier<XFile?> _selectedImageNotifier =
      ValueNotifier<XFile?>(null);
  final int documentLimit = 20;
  bool _hasNext = true;
  bool _isFetchingUsers = false;
  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      _selectedImageNotifier.value = image;
    }
  }

  void sendMessage() async {
    // Ensure not to send an empty message
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
          widget.receiverUserID, _messageController.text);
      // Clear the message controller after sending the message
      _messageController.clear();
    }
  }

  void sendImageWithText() async {
    if (_selectedImageNotifier.value != null) {
      try {
        await _chatService.sendImageMessage(
          widget.receiverUserID,
          _selectedImageNotifier.value!.path,
          _messageController.text,
        );
        // Clear after sending image and message
        _selectedImageNotifier.value = null;
        _messageController.clear();
      } catch (e) {
        if (kDebugMode) {
          print('Error sending image: $e');
        }
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 1100),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("I'm building");
    }
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
        title: Text(widget.receiverUserEmail),
        backgroundColor: AppColors.iris.withOpacity(0.3),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.grey.withOpacity(0.2),
        child: Column(
          children: [
            // Message list
            Expanded(child: _messageList()),
            // Message input
            _messageInput()
          ],
        ),
      ),
    );
  }

  // Build message list
  Widget _messageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(
          _firebaseAuth.currentUser!.uid, widget.receiverUserID, documentLimit),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.length < documentLimit) _hasNext = false;

        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "Send your first message now",
              style: TextStyle(fontSize: 16),
            ),
          );
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
          });
          return ListView.builder(
            controller: _scrollController,
            itemCount: snapshot.data!.docs.length + 1,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              if (index == snapshot.data!.docs.length) {
                return Container();
              }
              return _messageItem(snapshot.data!.docs[index]);
            },
          );
        }
      },
    );
  }

  // Build message item
  Widget _messageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    // Align sender message to the right, receiver message to the left
    Alignment alignment = (data['senderId'] == _firebaseAuth.currentUser!.uid)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              (data['senderId'] == _firebaseAuth.currentUser!.uid)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
            Text(
              data['senderEmail'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5.0),
            if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
              LayoutBuilder(
                // Use LayoutBuilder
                builder: (BuildContext context, BoxConstraints constraints) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth:
                          constraints.maxWidth * 0.6, // 60% of parent width
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: CachedNetworkImage(
                        imageUrl: data["imageUrl"],
                        fit: BoxFit.fitWidth, // Important: Use BoxFit.fitWidth
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Colors.blue),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  );
                },
              ),
            if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
              const SizedBox(height: 5.0),
            if (data['message'].isNotEmpty)
              ChatBubble(
                message: data['message'],
                isSender: data['senderId'] == _firebaseAuth.currentUser!.uid,
              ),
            const SizedBox(height: 5.0),
            Text(
              formatTime(data['timestamp']),
              style: TextStyle(color: Colors.grey[600], fontSize: 11.0),
            ),
          ],
        ),
      ),
    );
  }

  // Build message input
  Widget _messageInput() {
    return Column(
      children: [
        ValueListenableBuilder<XFile?>(
          // This is now correctly isolated
          valueListenable: _selectedImageNotifier,
          builder: (context, selectedImage, child) {
            if (selectedImage != null) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.file(
                      File(selectedImage.path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        _selectedImageNotifier.value = null;
                      },
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 8.0, bottom: 8.0),
          child: Row(
            children: [
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: TextField(
                    cursorColor: AppColors.iris,
                    controller: _messageController,
                    obscureText: false,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Your message',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_upward,
                    size: 40, color: AppColors.lightIris),
                onPressed: () {
                  if (_selectedImageNotifier.value != null) {
                    sendImageWithText();
                  } else {
                    sendMessage();
                  }
                },
              ),
              const SizedBox(width: 6.0),
              IconButton(
                icon: const Icon(Icons.image, size: 40, color: AppColors.iris),
                onPressed: pickImage,
              ),
            ],
          ),
        ),
      ],
    );
  }

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
}
