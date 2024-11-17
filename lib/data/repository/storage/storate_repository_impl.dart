import 'dart:io';

import 'package:socialapp/data/sources/storage/storage_service.dart';
import 'package:socialapp/domain/repository/storage/storage_repository.dart';
import 'package:socialapp/service_locator.dart';

class StorageRepositoryImpl extends StorageRepository {
  @override
  Future<String>? uploadPostImage(String folderName, File image) {
    return serviceLocator<StorageService>().uploadPostImage(folderName, image);
  }

  @override
  Future<String>? uploadAvatar(File image, String uid) {
    return serviceLocator<StorageService>().uploadAvatar(image, uid);
  }
}
