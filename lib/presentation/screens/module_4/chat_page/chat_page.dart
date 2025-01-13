import 'package:image_size_getter/file_input.dart';
import 'package:socialapp/data/sources/chat/chat_service.dart';
import 'package:socialapp/utils/import.dart';
import 'package:intl/intl.dart';
import 'package:image_size_getter/image_size_getter.dart';
import '../../../widgets/chat/image_placeholder.dart';
import 'cubit/image_cubit.dart';

class ChatPage extends StatefulWidget {
  final String receiverUserEmail;
  final String receiverUserID;
  final String receiverAvatar;
  const ChatPage(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserID,
      required this.receiverAvatar});

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
  late ImageSendCubit _imageSendCubit;

  @override
  void initState() {
    super.initState();
    _imageSendCubit = ImageSendCubit();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _messageController.dispose();
  }

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
      String message = _messageController.text.trim();
      _messageController.clear();
      await _chatService.sendMessage(widget.receiverUserID, message);
      // Clear the message controller after sending the message
    }
  }

  void sendImageWithText() async {
    if (_selectedImageNotifier.value != null) {
      _imageSendCubit.sendImageInProgress();
      try {
        await _chatService.sendImageMessage(
          widget.receiverUserID,
          _selectedImageNotifier.value!.path,
          _messageController.text.trim(),
        );
        _imageSendCubit.sendImageSuccess();
        _selectedImageNotifier.value = null;
        _messageController.clear();
      } catch (e) {
        _imageSendCubit.sendImageFailure();
        if (kDebugMode) {
          print('Error sending image: $e');
        }
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final position = _scrollController.position.minScrollExtent;
      _scrollController.animateTo(
        position,
        duration: const Duration(seconds: 1),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("I'm building");
    }
    return BlocProvider(
      create: (_) => _imageSendCubit,
      child: Scaffold(
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
          title: Row(
            children: [
              CircleAvatar(
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.receiverAvatar,
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
              const SizedBox(
                width: 8.0,
              ),
              Text(widget.receiverUserEmail),
            ],
          ),
          backgroundColor: AppColors.iris.withOpacity(0.3),
          centerTitle: true,
        ),
        body: Stack(children: [
          Container(
            color: Colors.grey.withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: [
                  // Message list
                  Expanded(child: _messageList()),
                  // Message input
                  _imageSendStatusWidget(),
                  _messageInput()
                ],
              ),
            ),
          ),
          _imagePreview()
        ]),
      ),
    );
  }

  void _showSnackbar(String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget _imageSendStatusWidget() {
    return BlocListener<ImageSendCubit, ImageSendStatus>(
      listener: (context, state) {
        if (state == ImageSendStatus.loading) {
          _showSnackbar('Uploading image...', Colors.amber);
        } else if (state == ImageSendStatus.success) {
          _scrollToBottom();
          _showSnackbar('Image sent successfully!', Colors.green);
        } else if (state == ImageSendStatus.failure) {
          _showSnackbar(
              'Failed to send image, please try again', Colors.redAccent);
        }
      },
      child: const SizedBox.shrink(),
    );
  }

  // Build message list
  Widget _messageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getMessages(
          _firebaseAuth.currentUser!.uid, widget.receiverUserID),
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
          _scrollToBottom();
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                  child: ListView.builder(
                reverse: true,
                shrinkWrap: true,
                controller: _scrollController,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot currentDocument = snapshot.data!.docs[index];
                  DocumentSnapshot? nextDocument =
                      (index - 1 >= 0) ? snapshot.data!.docs[index - 1] : null;
                  return _messageItem(currentDocument, index, nextDocument);
                },
              )),
            ],
          );
        }
      },
    );
  }

  Widget _messageItem(
      DocumentSnapshot document, int index, DocumentSnapshot? nextDocument) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    Map<String, dynamic>? nextData =
        nextDocument?.data() as Map<String, dynamic>?;

    // Align sender message to the right, receiver message to the left
    bool isSender = data['senderId'] == _firebaseAuth.currentUser!.uid;

    // Determine whether to show avatar
    bool showAvatar =
        nextData == null || nextData['senderId'] != data['senderId'];

    // Determine whether to show timestamp
    bool showTimestamp =
        nextData == null || nextData['senderId'] != data['senderId'];

    // Spacing based on whether next message is from the same sender
    double spacing =
        (nextData == null || nextData['senderId'] != data['senderId'])
            ? 16.0 // Larger spacing for different senders
            : 4.0; // Smaller spacing for the same sender

    return Padding(
      padding: EdgeInsets.only(bottom: spacing, left: 8.0, right: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end, // Align bottom of messages
        mainAxisAlignment:
            isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Reserve space for avatar consistency
          if (!isSender) ...[
            if (showAvatar)
              CircleAvatar(
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.receiverAvatar,
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
              const SizedBox(width: 40), // Placeholder to align messages
            const SizedBox(width: 8.0), // Space between avatar and message
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Image message
                if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth:
                              constraints.maxWidth * 0.7, // 70% of parent width
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: InkWell(
                            onTap: () =>
                                showImageDialog(context, data['imageUrl']),
                            child: CachedNetworkImage(
                              imageUrl: data["imageUrl"],
                              fit: BoxFit.fitWidth,
                              placeholder: (context, url) => ImagePlaceholder(
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
                // Text message
                if (data['message'].isNotEmpty)
                  ChatBubble(
                    message: data['message'],
                    isSender: isSender,
                  ),
                // Timestamp
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

  Widget _imagePreview() {
    return ValueListenableBuilder<XFile?>(
      valueListenable: _selectedImageNotifier,
      builder: (context, selectedImage, child) {
        if (selectedImage != null) {
          return Positioned(
            bottom: MediaQuery.of(context).size.height * 0.07,
            left: 16.0,
            right: 16.0,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxWidth = constraints.maxWidth * 0.5;
                final maxHeight = MediaQuery.of(context).size.height * 0.3;

                // Get img resolution
                final sizeResult = ImageSizeGetter.getSizeResult(
                    FileInput(File(selectedImage.path)));
                final imageWidth = sizeResult.size.width;
                final imageHeight = sizeResult.size.height;

                // Compute ratio
                final aspectRatio = imageWidth / imageHeight;
                double previewWidth = maxWidth;
                double previewHeight = previewWidth / aspectRatio;

                if (previewHeight > maxHeight) {
                  previewHeight = maxHeight;
                  previewWidth = previewHeight * aspectRatio;
                }

                return Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 15.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Ảnh preview
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: SizedBox(
                            width: previewWidth,
                            height: previewHeight,
                            child: Image.file(
                              File(selectedImage.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -10,
                          right: -10,
                          child: GestureDetector(
                            onTap: () {
                              _selectedImageNotifier.value = null;
                            },
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4.0),
                              child: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  // Build message input
  Widget _messageInput() {
    return Padding(
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
