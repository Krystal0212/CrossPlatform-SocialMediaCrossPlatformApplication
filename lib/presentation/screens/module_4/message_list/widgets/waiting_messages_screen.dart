import 'package:socialapp/utils/import.dart';

import '../message_list_screen.dart';
import '../providers/user_data_properties.dart';

class WaitingMessagesHeader extends StatelessWidget {
  final int totalItems;
  final UserModel currentUser;
  final List<Map<String, dynamic>> chatRoomList;


  const WaitingMessagesHeader(
      {super.key, required this.totalItems, required this.currentUser, required this.chatRoomList});

  @override
  Widget build(BuildContext context) {
    return UserWaitingDataInheritedWidget(
      currentUser: currentUser,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      WaitingMessagesList(
                        chatRoomList: chatRoomList, currentUser: currentUser,))
          );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          color: Colors.blueAccent, // Change to desired color
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.mail_outline, color: Colors.white),
                  // Icon for messages
                  SizedBox(width: 8),
                  Text(
                    'Waiting messages',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                '$totalItems', // Display the total number of items
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaitingMessagesList extends StatefulWidget {
  final List<Map<String, dynamic>> chatRoomList;
  final UserModel currentUser;

  const WaitingMessagesList(
      {super.key, required this.chatRoomList, required this.currentUser});

  @override
  State<WaitingMessagesList> createState() => _WaitingMessagesListState();
}

class _WaitingMessagesListState extends State<WaitingMessagesList> {
  late double deviceWidth = 0,
      deviceHeight = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
    final flutterView = PlatformDispatcher.instance.views.first;

    deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    deviceHeight = flutterView.physicalSize.height;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> contacts = widget.chatRoomList;

    return Scaffold(
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
          backgroundColor: AppColors.white,
          title: Text(
            'Waiting Message',
            style: AppTheme.messageStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding:
          const EdgeInsets.only(left: 30, right: 30, top: 35, bottom: 10),

          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: ChatRoomTile(
                  currentUser: widget.currentUser,
                  chatRoomData: contacts[index]['chatRoomData'],
                  currentUserId: widget.currentUser.id!,
                  index: index,
                ),
              );
            },
          ),


        ));
  }
}
