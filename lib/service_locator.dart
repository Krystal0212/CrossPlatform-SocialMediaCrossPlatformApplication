import 'package:get_it/get_it.dart';
import 'package:socialapp/data/repository/collection/collection_repository_impl.dart';
import 'package:socialapp/data/repository/post/post_repository_impl.dart';
import 'package:socialapp/data/repository/topic/topic_repository_impl.dart';
import 'package:socialapp/domain/repository/post/post_repository.dart';
import 'package:socialapp/domain/repository/topic/topic_repository.dart';
import 'data/repository/auth/auth_repository_impl.dart';
import 'data/repository/user/user_repository_impl.dart';
import 'data/sources/auth/auth_firebase_service.dart';
import 'data/sources/firestore/firestore_service.dart';
import 'data/sources/storage/storage_service.dart';
import 'domain/repository/auth/auth_repository.dart';
import 'domain/repository/collection/collection_repository.dart';
import 'domain/repository/user/user_repository.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  serviceLocator
      .registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  serviceLocator.registerSingleton<FirestoreService>(FirestoreServiceImpl());
  serviceLocator.registerSingleton<StorageService>(StorageServiceImpl());

  serviceLocator.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  serviceLocator.registerSingleton<UserRepository>(UserRepositoryImpl());
  serviceLocator.registerSingleton<TopicRepository>(TopicRepositoryImpl());
  serviceLocator.registerSingleton<PostRepository>(PostRepositoryImpl());
  serviceLocator.registerSingleton<CollectionRepository>(CollectionRepositoryImpl());
}