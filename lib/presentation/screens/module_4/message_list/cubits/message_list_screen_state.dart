import 'package:socialapp/utils/import.dart';

abstract class MessageListScreenState{}

class MessageListScreenInitial extends MessageListScreenState {}

class MessageListScreenLoaded extends MessageListScreenState {
  final UserModel userModel;

  MessageListScreenLoaded(this.userModel);
}

class MessageListScreenError extends MessageListScreenState {
}