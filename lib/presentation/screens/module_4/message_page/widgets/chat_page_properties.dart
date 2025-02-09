import 'package:socialapp/utils/import.dart';

class ChatPageUserPropertyData {
  final bool isUser1;
  final UserModel currentUser;

  ChatPageUserPropertyData({required this.isUser1, required this.currentUser});
}


class ChatPageUserProperty extends InheritedWidget {
  final ChatPageUserPropertyData chatPageUserPropertyData;

  const ChatPageUserProperty({
    super.key,
    required this.chatPageUserPropertyData,
    required super.child,
  });

  // Provide a method to access both values
  static ChatPageUserPropertyData of(BuildContext context) {
    final ChatPageUserProperty? result =
    context.dependOnInheritedWidgetOfExactType<ChatPageUserProperty>();
    assert(result != null, 'No ChatPageUserProperty found in context');
    return result!.chatPageUserPropertyData;
  }

  @override
  bool updateShouldNotify(ChatPageUserProperty oldWidget) {
    return oldWidget.chatPageUserPropertyData.isUser1 != chatPageUserPropertyData.isUser1 ||
        oldWidget.chatPageUserPropertyData.currentUser != chatPageUserPropertyData.currentUser;
  }
}

