import 'package:socialapp/presentation/widgets/general/debounce_search_bar.dart';
import 'package:socialapp/utils/import.dart';

import '../message_list/providers/user_data_properties.dart';

class AddContactScreen extends StatefulWidget {
  final UserModel currentUser;

  const AddContactScreen({super.key, required this.currentUser});

  @override
  State<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends State<AddContactScreen> {
  final ChatService _chatService = ChatServiceImpl();

  late double deviceWidth = 0, deviceHeight = 0;
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    final flutterView = PlatformDispatcher.instance.views.first;
    deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    deviceHeight = flutterView.physicalSize.height;
  }

  @override
  Widget build(BuildContext context) {
    // Determine which future to use based on the search query.
    // If searchQuery is empty, load the followings list.
    // Otherwise, perform a Firestore query using findingUserList.
    Future<List<UserModel>> futureUsers = searchQuery.isEmpty
        ? _chatService.getUserFollowingsList()
        : _chatService.findingUserList(searchQuery);

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          style: ButtonStyle(
            elevation: WidgetStateProperty.all(0.0),
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
        backgroundColor: AppColors.white,
        title: Text(
          'Create message',
          style: AppTheme.messageStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding:
            const EdgeInsets.only(left: 30, right: 30, top: 25, bottom: 10),
        child: Column(
          children: [
            // Search field to enter the tag name to search
            DebouncedTextField(
              controller: _searchController,
              hintText: "Search by tag-name...",
              onChangedDebounced: (value) {
                setState(() {
                  searchQuery = value.trim();
                });
              },
            ),
            const SizedBox(height: 40),
            // FutureBuilder that uses the selected future
            Expanded(
              child: FutureBuilder<List<UserModel>>(
                future: futureUsers,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return NoPublicDataAvailablePlaceholder(
                        width: deviceWidth * 0.9);
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: deviceHeight * 0.3,
                      child: const Center(
                          child: CircularProgressIndicator(
                        color: AppColors.iris,
                      )),
                    );
                  }

                  List<UserModel> users = snapshot.data ?? [];

                  if (users.isEmpty) {
                    if (searchQuery.isNotEmpty) {
                      return NoUserResultPlaceholder(width: deviceWidth * 0.9);
                    }
                    return NoFollowingsPlaceholder(width: deviceWidth * 0.9);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 18.0, bottom: 30),
                        child: Text(
                          searchQuery.isEmpty
                              ? 'Users that you are following'
                              : 'Search result',
                          style: AppTheme.messageStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            DocumentReference otherUserRef =
                                _chatService.getUserRef(users[index].id!);
                            return UserListTile(
                              currentUser: widget.currentUser,
                              userName: users[index].name,
                              userAvatar: users[index].avatar,
                              currentUserId: users[index].id!,
                              otherUserRef: otherUserRef,
                              userTagName: users[index].tagName,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserListTile extends StatelessWidget {
  final String userName;
  final String userTagName;
  final String userAvatar;
  final String currentUserId;
  final UserModel currentUser;
  final DocumentReference otherUserRef;

  const UserListTile({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.currentUserId,
    required this.otherUserRef,
    required this.userTagName,
    required this.currentUser,
  });

  @override
  @override
  Widget build(BuildContext context) {
    ChatService _chatService = ChatServiceImpl();
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.iris.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 40,
              backgroundImage: CachedNetworkImageProvider(userAvatar),
            ),
            title: Text(userName,
                style: AppTheme.blackUsernameMobileStyle
                    .copyWith(fontWeight: FontWeight.w700)),
            subtitle: Text(
              'Tag name : $userTagName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.blackUsernameMobileStyle.copyWith(
                fontSize: 16,
                color: AppColors.trolleyGrey,
              ),
            ),
            onTap: () async {
              bool isUser1 = await _chatService.checkIsUser1(otherUserRef.id);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    isUser1: isUser1,
                    receiverUserName: userName,
                    receiverUserID: otherUserRef.id,
                    receiverAvatar: userAvatar,
                    currentUser: currentUser,
                  ),
                ),
              );
            }),
      ),
    );
  }
}
