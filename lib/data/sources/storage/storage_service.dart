import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

abstract class StorageService {
  // Future<String> uploadFile(File file, String path);
  // Future<void> deleteFile(String path);
  Future<String>? uploadPostImage(String folderName, File image);
  Future<String>? uploadAvatar( File image, String uid);

}

class StorageServiceImpl implements StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // @override
  // Future<String> uploadFile(File file) async {
  //   uploadImage('Image', file);
  // }
  //
  // @override
  // Future<String> uploadUserAvatar(File file) async {
  //   uploadImage('User', file);
  // }

  @override
  Future<String>? uploadPostImage(String folderName, File image) async {
    try {
      final storageReference = _storage.ref().child('images/${DateTime.now().toString()}');

      UploadTask uploadTask = storageReference.putFile(image);

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('Uploaded Image URL: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String>? uploadAvatar( File image, String uid) async {
    try {
      final storageReference = _storage.ref().child('/user_avatars/$uid');

      UploadTask uploadTask = storageReference.putFile(image);

      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      print('Uploaded Image URL: $downloadUrl');

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }
}


