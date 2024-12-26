
import 'package:socialapp/utils/import.dart';

final serviceLocator = GetIt.instance;

Future<void> initializeDependencies() async {
  serviceLocator.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  serviceLocator.registerSingleton<FirestoreService>(FirestoreServiceImpl());
  serviceLocator.registerSingleton<StorageService>(StorageServiceImpl());
  serviceLocator.registerSingleton<DeepLinkService>(DeepLinkServiceImpl());

  serviceLocator.registerSingleton<AuthRepository>(AuthRepositoryImpl());
  serviceLocator.registerSingleton<UserRepository>(UserRepositoryImpl());
  serviceLocator.registerSingleton<TopicRepository>(TopicRepositoryImpl());
  serviceLocator.registerSingleton<PostRepository>(PostRepositoryImpl());
  serviceLocator.registerSingleton<CollectionRepository>(CollectionRepositoryImpl());
  serviceLocator.registerSingleton<DeepLinkRepository>(DeepLinkRepositoryImpl());
}
