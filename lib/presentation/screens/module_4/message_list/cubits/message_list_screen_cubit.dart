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
      final UserModel? userModel =
      await serviceLocator<UserRepository>().getCurrentUserData();

      if (userModel != null) {
        emit(MessageListScreenLoaded(userModel));
      } else {
        throw "User data not found";
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching profile: $e");
      }
      emit(MessageListScreenError());
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>>? getChatListSnapshot(){
   return _chatService.getCurrentUserSnapshot();
  }
}