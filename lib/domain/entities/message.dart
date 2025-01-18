import 'package:socialapp/utils/import.dart';

class ChatMessageModel {
  final bool isFromUser1;
  final String message;
  final Timestamp timestamp;
  final Map<String, ImageData>? media;

  ChatMessageModel({
    this.media,
    required this.isFromUser1,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'isFromUser1': isFromUser1,
      'message': message,
      'timestamp': timestamp,
      'media': media?.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  static ChatMessageModel fromMap(Map<String, dynamic> map) {
    return ChatMessageModel(
      message: map['message'],
      timestamp: map['timestamp'],
      isFromUser1: map['isFromUser1'],
      media: (map['media'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, ImageData.fromMap(value))),
    );
  }
}

class ImageData {
  final String imageUrl;
  final String type;
  final bool isNSFW;
  final bool isLandscape;
  final double width;
  final double height;
  final String dominantColor;

  ImageData( {
    required this.imageUrl,
    required this.type,
    required this.isNSFW,
    required this.isLandscape,
    required this.dominantColor,
    required this.width, required this.height,
  });

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'type': type,
      'isNSFW': isNSFW,
      'isLandscape': isLandscape,
      'dominantColor': dominantColor,
      'width': width,
      'height': height,
    };
  }

  static ImageData fromMap(Map<String, dynamic> map) {
    return ImageData(
      imageUrl: map['imageUrl'],
      type: map['type'],
      isNSFW: map['isNSFW'],
      isLandscape: map['isLandscape'],
      dominantColor: map['dominantColor'], width: map['width'], height: map['height'],
    );
  }
}
