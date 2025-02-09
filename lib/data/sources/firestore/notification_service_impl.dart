import 'package:socialapp/utils/import.dart';

abstract class NotificationService {
  Stream<List<NotificationModel>> getNotificationStreamOfCurrentUser();

  Future<UserModel> getUserDataFromRef(DocumentReference otherUserRef);
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

  CollectionReference get _notificationRef =>
      _firestoreDB.collection('Notification');

  CollectionReference _commentPostsRef(String postId) {
    return _postRef.doc(postId).collection('comments');
  }

  // ToDo: Service Functions
  @override
  Stream<List<NotificationModel>> getNotificationStreamOfCurrentUser() {
    return _notificationRef
        .doc(currentUserId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<UserModel> getUserDataFromRef(DocumentReference otherUserRef) async {
     DocumentSnapshot otherUserSnapshot = await otherUserRef.get();
     Map<String, dynamic> otherUserData = otherUserSnapshot.data() as Map<String, dynamic>;

     otherUserData['id'] = otherUserSnapshot.id;
     otherUserData['preferred-topics'] = {};

    return UserModel.fromMap(otherUserData);
}
}
