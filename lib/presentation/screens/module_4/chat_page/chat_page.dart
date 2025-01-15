import 'package:flutter_image_compress/flutter_image_compress.dart';
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
  late ScrollController _scrollController;
  final ValueNotifier<List<Map<String, dynamic>>> _selectedAssetsNotifier =
      ValueNotifier<List<Map<String, dynamic>>>([]);

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
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _selectedAssetsNotifier.dispose();
    super.dispose();
  }

  void pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      throw ("No image selected");
    }

    List<Map<String, dynamic>> selectedAssetsList = List.from(_selectedAssetsNotifier.value);
    selectedAssetsList.add({
      'data': File(image.path).readAsBytesSync(),
      'path': image.path,
      'type': 'image'
    });

    _selectedAssetsNotifier.value = selectedAssetsList;
  }

  // void pickImage() async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  //
  //   if (image != null) {
  //     _selectedImageNotifier.value = {image:false};
  //   }
  // }

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
    if (_selectedAssetsNotifier.value.isNotEmpty) {
      _imageSendCubit.sendImageInProgress();
      try {
        for (Map<String, dynamic> image in _selectedAssetsNotifier.value) {
          await _chatService.sendImageMessage(
            isUser1,
            widget.receiverUserID,
            image['path'],
            _messageController.text.trim(),
          );
          _imageSendCubit.sendImageSuccess();
          _selectedAssetsNotifier.value = [];
          _messageController.clear();
        }
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
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: MessageList(
                            receiverUserID: receiverUserID,
                            scrollController: _scrollController,
                            receiverAvatar: receiverAvatar,
                          ),
                        ),
                      ],
                    )),
                    // Message input
                    ImageSendStatusWidget(
                      scrollController: _scrollController,
                    ),
                    MessageInput(
                        messageController: _messageController,
                        selectedImageNotifier: _selectedAssetsNotifier,
                        sendMessage: sendMessage,
                        sendImageWithText: () {
                          sendImageWithText(isUser1);
                        },
                        pickImage: pickImage)
                  ],
                ),
              ),
            ),
            ImagePreview(selectedAssetsNotifier: _selectedAssetsNotifier)
          ]),
        ),
      ),
    );
  }
}
