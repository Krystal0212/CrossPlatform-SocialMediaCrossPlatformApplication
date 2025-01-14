import 'package:socialapp/utils/import.dart';

class ChatPageUserProperty extends InheritedWidget {
  final bool isUser1;

  const ChatPageUserProperty({
    super.key,
    required this.isUser1,
    required super.child,
  });

  // Provide a method to access the isUser1 value
  static bool of(BuildContext context) {
    final ChatPageUserProperty? result =
    context.dependOnInheritedWidgetOfExactType<ChatPageUserProperty>();
    assert(result != null, 'No UserStatus found in context');
    return result!.isUser1;
  }

  @override
  bool updateShouldNotify(ChatPageUserProperty oldWidget) {
    return oldWidget.isUser1 != isUser1;
  }
}
