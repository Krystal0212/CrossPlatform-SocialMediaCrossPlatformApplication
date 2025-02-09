import 'package:socialapp/data/sources/firestore/chat_service_impl.dart';
import 'package:universal_html/html.dart' as html;

import 'package:socialapp/utils/import.dart';
import 'cubit/image_cubit.dart';
import 'cubit/image_state.dart';
import 'widgets/chat_page_properties.dart';

class ChatPage extends StatefulWidget {
  final bool isUser1;
  final UserModel currentUser;
  final String receiverUserEmail, receiverUserID, receiverAvatar;

  const ChatPage(
      {super.key,
      required this.receiverUserEmail,
      required this.receiverUserID,
      required this.receiverAvatar,
      required this.isUser1,
      required this.currentUser});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with AppDialogs {
  final TextEditingController _messageController = TextEditingController();

  late ScrollController _scrollController;
  late ValueNotifier<List<Map<String, dynamic>>> _selectedAssetsNotifier;

  late bool isUser1;
  late String receiverUserEmail, receiverUserID, receiverAvatar;

  @override
  void initState() {
    super.initState();
    isUser1 = widget.isUser1;
    receiverUserID = widget.receiverUserID;
    receiverAvatar = widget.receiverAvatar;
    _scrollController = ScrollController();
    _selectedAssetsNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _selectedAssetsNotifier.dispose();
    super.dispose();
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
    return ChatPageUserProperty(
      chatPageUserPropertyData: ChatPageUserPropertyData(
        currentUser: widget.currentUser,
        isUser1: widget.isUser1,
      ),
      child: BlocProvider(
        create: (context) {
          final chatSendCubit = ChatSendCubit();
          chatSendCubit.initialize(); // Initialize the cubit asynchronously
          return chatSendCubit;
        },
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppBar(
                  scrolledUnderElevation: 0,
                  elevation: 0,
                  // Disable default AppBar elevation
                  leading: IconButton(
                    style: ButtonStyle(
                      elevation: WidgetStateProperty.all(0.0),
                      // Remove tap effect
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: SvgPicture.asset(
                      AppIcons.backButton,
                      width: 75,
                      height: 75,
                    ),
                  ),
                  title: Text(
                    widget.receiverUserEmail,
                    style: AppTheme.messageStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  backgroundColor: AppColors.white,
                  centerTitle: true,
                ),
                Container(
                  height: 1, // Height of the shadow
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.trolleyGrey, // Shadow color
                        blurRadius: 2, // Spread of the shadow
                        offset: Offset(0, 1), // Horizontal and vertical offset
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Stack(children: [
            Container(
              color: AppColors.white,
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    // Message list
                    MessageList(
                      receiverUserID: receiverUserID,
                      scrollController: _scrollController,
                      receiverAvatar: receiverAvatar,
                    ),
                    ValueListenableBuilder(
                        valueListenable: _selectedAssetsNotifier,
                        builder: (context, assetList, _) {
                          return BlocBuilder<ChatSendCubit, ChatSendState>(
                              builder: (context, state) {
                            if (state is ChatSendInProgress) {
                              return Container(
                                  height: 50,
                                  color: AppColors.corona,
                                  child: Center(
                                      child: Text(
                                    'Uploading image...',
                                    style: AppTheme.blackUsernameStyle,
                                  )));
                            } else if (state is ChatSendSuccess) {
                              _scrollToBottom();
                              return Container(
                                  height: 50,
                                  color: AppColors.monstrousGreen,
                                  child: Center(
                                      child: Text(
                                    'Image sent successfully!',
                                    style: AppTheme.blackUsernameStyle,
                                  )));
                            } else if (state is ChatSendFailure) {
                              return Container(
                                  height: 50,
                                  color: AppColors.pelati,
                                  child: Center(
                                      child: Text(
                                    'Failed to send image, please try again',
                                    style: AppTheme.blackUsernameStyle,
                                  )));
                            }
                            return SizedBox(
                              height: (assetList.isNotEmpty) ? 275 : 0,
                            );
                          });
                        }),
                    // Message input
                    MessageInput(
                      messageController: _messageController,
                      selectedAssetsNotifier: _selectedAssetsNotifier,
                      receiverUserID: receiverUserID,
                    )
                  ],
                ),
              ),
            ),
            ImagePreview(
              selectedAssetsNotifier: _selectedAssetsNotifier,
              scrollController: _scrollController,
            )
          ]),
        ),
      ),
    );
  }
}
