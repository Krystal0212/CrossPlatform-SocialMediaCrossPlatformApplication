import 'package:socialapp/utils/import.dart';

import 'message_list_screen_state.dart';

class MessageListScreenCubit extends Cubit<MessageListScreenState> {
  final ChatService _chatService = ChatServiceImpl();

  MessageListScreenCubit() : super(MessageListScreenInitial()) {
    _initialize();
  }

  void _initialize() async {
    await fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? currentUser = await serviceLocator<AuthRepository>().getCurrentUser();

      if (currentUser != null) {
        final UserModel? userModel =
        await serviceLocator<UserRepository>().getCurrentUserData();
        emit(MessageListScreenLoaded(userModel!));
      } else {
        throw "User data not found";
      }
    } catch (e) {


      if (kDebugMode) {
        print("Error fetching profile for message list page: $e");
      }
      emit(MessageListScreenError());
    }
  }

  Stream<List<Map<String, dynamic>>>? getContactList(){
   return _chatService.getCurrentUserContactListSnapshot();
  }
}