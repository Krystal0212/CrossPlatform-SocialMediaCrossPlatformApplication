import 'package:socialapp/utils/import.dart';

abstract class NotificationService{

}

enum NotificationType {
  like,
  comment,
  addToCollection,
  message,
  sendAsset,
}

class NotificationServiceImpl extends NotificationService {

  final FirebaseFirestore _firestoreDB = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final int loadSize = 5;
  bool noMoreNotification = false;

  // ToDo : Reference Define
  User? get currentUser => _auth.currentUser;

  CollectionReference get _usersRef => _firestoreDB.collection('User');

  String get currentUserId => currentUser?.uid ?? '';

  CollectionReference get _postRef => _firestoreDB.collection('Post');

  CollectionReference get _notificationRef => _firestoreDB.collection('Notification');

  CollectionReference _commentPostsRef(String postId) {
    return _postRef.doc(postId).collection('comments');
  }

  // ToDo: Service Functions
  Future<void> sendPostNotification(String postId, String postOwnerId, NotificationType type) async {}
}