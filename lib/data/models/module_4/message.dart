import 'package:socialapp/utils/import.dart';

class ChatMessage {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final String? imageUrl; // Add this field
  final Timestamp timestamp;

  ChatMessage({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    this.imageUrl,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'imageUrl': imageUrl, // Include imageUrl
      'timestamp': timestamp,
    };
  }

  static ChatMessage fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      senderId: map['senderId'],
      senderEmail: map['senderEmail'],
      receiverId: map['receiverId'],
      message: map['message'],
      imageUrl: map['imageUrl'],
      timestamp: map['timestamp'],
    );
  }
}
