import 'package:socialapp/utils/import.dart';

import '../add_contact/add_contact_screen.dart';
import 'cubits/message_list_screen_cubit.dart';
import 'cubits/message_list_screen_state.dart';
import 'providers/user_data_properties.dart';
import 'widgets/chat_room_title.dart';
import 'widgets/waiting_messages_screen.dart';

class MessageListScreen extends StatelessWidget {
  const MessageListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => MessageListScreenCubit(),
        child: const MessageListBase());
  }
}

class MessageListBase extends StatefulWidget {
  const MessageListBase({super.key});

  @override
  State<MessageListBase> createState() => _MessageListBaseState();
}

class _MessageListBaseState extends State<MessageListBase> {
  late double deviceWidth = 0, deviceHeight = 0;
  final ChatService _chatService = ChatServiceImpl();

  @override
  void initState() {
    super.initState();

    final flutterView = PlatformDispatcher.instance.views.first;
    deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    deviceHeight = flutterView.physicalSize.height;
  }

  Future<bool> _showDeleteDialog() async {
    bool shouldDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              const Text('Are you sure you want to delete this chat room?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false on cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Return true on delete
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    return shouldDelete; // Default to false if the dialog is closed unexpectedly
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessageListScreenCubit, MessageListScreenState>(
        builder: (context, state) {
      if (state is MessageListScreenLoaded) {
        UserModel currentUser = state.userModel;
        return UserDataInheritedWidget(
          currentUser: currentUser,
          child: Scaffold(
            appBar: AppBar(
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
                icon: const Icon(
                  Icons.arrow_left,
                  size: 40,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  // Add right padding
                  child: IconButton(
                    onPressed: () {
                      setState(() {

                      });
                    },
                    icon: const Icon(
                      Icons.restart_alt,
                      size: 40,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  // Add right padding
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              AddContactScreen(currentUser: currentUser)));
                    },
                    icon: const Icon(
                      Icons.add_circle_outline_outlined,
                      size: 40,
                    ),
                  ),
                ),
              ],
              backgroundColor: AppColors.white,
              title: Text(
                'Message',
                style: AppTheme.messageStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.only(
                  left: 30, right: 30, top: 35, bottom: 10),
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: context.read<MessageListScreenCubit>().getContactList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting ||
                      (snapshot.hasData && currentUser.id == null)) {
                    return const Center(
                        child: CircularProgressIndicator(
                      color: AppColors.iris,
                    ));
                  } else if (snapshot.hasData && snapshot.data != null) {
                    final List<Map<String, dynamic>> chatRoomList =
                        snapshot.data!;
                    if (chatRoomList.isNotEmpty) {
                      final List<Map<String, dynamic>> strangers = chatRoomList
                          .where((chatRoom) => chatRoom['isStranger'] == true)
                          .toList();

                      final List<Map<String, dynamic>> contacts = chatRoomList
                          .where((chatRoom) => chatRoom['isStranger'] == false)
                          .toList();

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            if (strangers.isNotEmpty)
                              WaitingMessagesHeader(
                                totalItems: strangers.length,
                                currentUser: currentUser,
                                chatRoomList: chatRoomList,
                              ),
                            ...contacts.map((contact) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Dismissible(
                                  key: Key(contact['chatRoomData']['id']),
                                  // Ensure each item is unique
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (direction) async {
                                    bool shouldDelete =
                                        await _showDeleteDialog();
                                    return shouldDelete;
                                  },
                                  onDismissed: (_) async {
                                    await _chatService.deleteTempChatForUser(
                                        contact['chatRoomData']['id'],
                                        currentUser.id!);
                                    setState(() {});
                                  },
                                  background: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: AppColors.sangoRed,
                                    ),
                                    child: const Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: Icon(
                                          Icons.delete,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: ChatRoomTile(
                                    currentUser: currentUser,
                                    isWaiting: false,
                                    chatRoomData: contact['chatRoomData'],
                                    currentUserId: currentUser.id!,
                                    index: contacts.indexOf(contact),
                                  ),
                                ),
                              );
                              ;
                            }),
                          ],
                        ),
                      );
                    } else {
                      return NoContactsAvailablePlaceholder(
                        width: deviceWidth,
                      );
                    }
                  }
                  return NoContactsAvailablePlaceholder(
                    width: deviceWidth,
                  );
                },
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }
}
