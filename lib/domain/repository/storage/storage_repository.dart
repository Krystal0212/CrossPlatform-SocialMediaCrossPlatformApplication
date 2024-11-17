import 'dart:io';

abstract class StorageRepository{
  Future<String>? uploadPostImage(String folderName, File image);
  Future<String>? uploadAvatar( File image, String uid);
}