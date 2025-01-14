import 'package:image_size_getter/file_input.dart';
import 'package:socialapp/data/sources/firestore/chat_service_impl.dart';

import 'package:socialapp/utils/import.dart';
import 'cubit/image_cubit.dart';
import 'widgets/chat_page_properties.dart';

class ChatPage extends StatefulWidget {
  final bool isUser1;
  final String receiverUserEmail, receiverUserID, receiverAvatar;

  const ChatPage(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserID,
      required this.receiverAvatar,
      required this.isUser1});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with AppDialogs {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<XFile?> _selectedImageNotifier =
      ValueNotifier<XFile?>(null);

  late ImageSendCubit _imageSendCubit;
  late bool isUser1;
  late String receiverUserEmail, receiverUserID, receiverAvatar;

  @override
  void initState() {
    super.initState();
    _imageSendCubit = ImageSendCubit();
    isUser1 = widget.isUser1;
    receiverUserID = widget.receiverUserID;
    receiverAvatar = widget.receiverAvatar;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    _selectedImageNotifier.dispose();
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
      await _chatService.sendMessage(
          widget.isUser1, widget.receiverUserID, message);
      // Clear the message controller after sending the message
    }
  }

  void sendImageWithText(isUser1) async {
    if (_selectedImageNotifier.value != null) {
      _imageSendCubit.sendImageInProgress();
      try {
        await _chatService.sendImageMessage(
          isUser1,
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

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("I'm building");
    }
    return BlocProvider(
      create: (_) => _imageSendCubit,
      child: ChatPageUserProperty(
        isUser1: widget.isUser1,
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
                    Expanded(
                        child: MessageList(
                      receiverUserID: receiverUserID,
                      scrollController: _scrollController,
                      receiverAvatar: receiverAvatar,
                    )),
                    // Message input
                    ImageSendStatusWidget(
                      scrollController: _scrollController,
                    ),
                    MessageInput(
                        messageController: _messageController,
                        selectedImageNotifier: _selectedImageNotifier,
                        sendMessage: sendMessage,
                        sendImageWithText: sendImageWithText,
                        pickImage: pickImage)
                  ],
                ),
              ),
            ),
            ImagePreview(selectedImageNotifier: _selectedImageNotifier)
          ]),
        ),
      ),
    );
  }
}
