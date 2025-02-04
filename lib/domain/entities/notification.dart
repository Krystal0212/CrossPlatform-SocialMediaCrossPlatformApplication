import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
   String? id;
  final String type; // "like", "comment", "add_to_collection", "message", "send_asset"
  final String fromUserId; // User who triggered the notification
  final String toUserId; // User receiving the notification
  final String? postId; // Post ID (if related to post interaction)
  final String? messageId; // Message ID (if related to messages)
  final Timestamp timestamp;

  NotificationModel({
    required this.id,
    required this.type,
    required this.fromUserId,
    required this.toUserId,
    this.postId,
    this.messageId,
    required this.timestamp,
  });

  // Convert NotificationModel to Firestore-compatible Map
  Map<String, dynamic> toMap() {
    return {
      "type": type,
      "fromUserId": fromUserId,
      "toUserId": toUserId,
      "postId": postId,
      "messageId": messageId,
      "timestamp": timestamp,
    };
  }

  // Create NotificationModel from Firestore Document
  factory NotificationModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NotificationModel(
      id: documentId,
      type: map["type"],
      fromUserId: map["fromUserId"],
      toUserId: map["toUserId"],
      postId: map["postId"],
      messageId: map["messageId"],
      timestamp: map["timestamp"] ?? Timestamp.now(),
    );
  }
}
