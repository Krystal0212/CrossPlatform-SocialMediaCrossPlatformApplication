import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/utils/import.dart';

enum NotificationType {
  like, // roi
  comment, // roi
  commentLike, // roi
  textMessage, // roi
  singleImageMessage, // roi
  multipleImageMessage, // roi
  commentReply, // roi
}

class NotificationModel {
  final bool isRead;
   String id;
  final String type; // "like", "comment", "add_to_collection", "message", "send_image"
  final DocumentReference fromUserRef; // User who triggered the notification
  final String toUserId; // User receiving the notification
  final String? postId; // Post ID (if related to post interaction)
  final String? chatRoomId; // (if related to messages)
  final Timestamp timestamp;

  NotificationModel( {required this.isRead,
    required this.id,
    required this.type,
    required this.fromUserRef,
    required this.toUserId,
    this.postId,
    this.chatRoomId,
    required this.timestamp,
  });

   NotificationModel.newNotification({
     required this.type,
     required this.fromUserRef,
     required this.toUserId,
     this.postId,
     this.chatRoomId,
     required this.timestamp,})
   : id = '', isRead = false;


  // Convert NotificationModel to Firestore-compatible Map
  Map<String, dynamic> toMap() {
    return {
      "isRead": isRead,
      "type": type,
      "fromUserRef": fromUserRef,
      "toUserId": toUserId,
      "postId": postId,
      "chatRoomId": chatRoomId,
      "timestamp": timestamp,
      "titleLowercase": type.toLowerCase(),
    };
  }

  // Create NotificationModel from Firestore Document
  factory NotificationModel.fromMap(Map<String, dynamic> map, String documentId) {
    try {
      return NotificationModel(
        isRead: map["isRead"],
        id: documentId,
        type: map["type"],
        fromUserRef: map["fromUserRef"],
        toUserId: map["toUserId"],
        postId: map["postId"],
        chatRoomId: map["chatRoomId"],
        timestamp: map["timestamp"] ?? Timestamp.now(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating NotificationModel from Map: $e');
      }
      rethrow;
    }
  }
}
