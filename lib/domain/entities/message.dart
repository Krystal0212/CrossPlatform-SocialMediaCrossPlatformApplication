import 'package:socialapp/utils/import.dart';

class ChatMessageModel {
  final bool isFromUser1;
  final String message;
  final String? imageUrl; // Add this field
  final Timestamp timestamp;

  ChatMessageModel({
    required this.isFromUser1,
    required this.message,
    this.imageUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'isFromUser1':isFromUser1,
      'message': message,
      'imageUrl': imageUrl, // Include imageUrl
      'timestamp': timestamp,
    };
  }

  static ChatMessageModel fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      message: map['message'],
      imageUrl: map['imageUrl'],
      timestamp: map['timestamp'],
      isFromUser1: map['isFromUser1'],
    );
  }
}
