import 'package:socialapp/utils/import.dart';

import '../../../../../data/sources/firestore/notification_service_impl.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;
  UserModel? currentUser;
  final Connectivity connectivity = Connectivity();

  final NotificationService _notificationService = NotificationServiceImpl();
  final Map<String, bool> readNotificationCache = {};

  NotificationCubit() : super(NotificationInitial()) {
    _initialize();
  }

  void _initialize() async {
    await fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final User? currentUser = await serviceLocator<AuthRepository>().getCurrentUser();


      if (currentUser != null) {
        final UserModel? userModel =
        await serviceLocator<UserRepository>().getCurrentUserData();

        Stream<List<NotificationModel>> notificationSnapshot =
        _notificationService.getNotificationStreamOfCurrentUser();

        _startPeriodicSync();
        _listenToConnectivity();

        emit(NotificationLoaded(userModel!, notificationSnapshot));
      } else {
        throw "user-data-not-found";
      }
    } catch (error) {
      if(error == "user-data-not-found"){
        emit(NotificationNotSignedIn());
        return;
      }

      if (kDebugMode) {
        print("Error fetching profile: $error");
      }
      emit(NotificationError());
    }
  }

  Future<void> removeReadNotification() async {
    try {
      emit(NotificationDeleting());
      await _notificationService.deleteReadNotifications();
      emit(NotificationDeleteSuccess());
    } catch (error) {
      if (kDebugMode) {
        print('Error delete read notification: $error');
      }
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      // await _notificationService.deleteNotification(notificationId);
    } catch (error) {
      if (kDebugMode) {
        print('Error delete single notification: $error');
      }
    }
  }

  Future<void> deleteAllNotifications() async {
    try {
      // await _notificationService.deleteAllNotifications();
    } catch (error) {
      if (kDebugMode) {
        print('Error delete notification: $error');
      }
    }
  }

  Future<UserModel> getUserDataFromUserRef(
      DocumentReference otherUserRef) async {
    return await _notificationService.getUserDataFromRef(otherUserRef);
  }

  Future<bool> checkOnline() async {
    final List<ConnectivityResult> result =
        await Connectivity().checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
        result.contains(ConnectivityResult.wifi);
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      bool isOnline = await checkOnline();
      if (isOnline) {
        await _notificationService
            .syncReadStatusToFirestore(readNotificationCache);
      }
    });
  }

  void _listenToConnectivity() {
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      (connectivityList) {
        final connectivityResult = connectivityList.isNotEmpty
            ? connectivityList.first
            : ConnectivityResult.none;

        if (connectivityResult != ConnectivityResult.none) {}
      },
    );
  }

  void triggerSync() async {
    bool isOnline = await checkOnline();
    if (isOnline) {
      await _notificationService
          .syncReadStatusToFirestore(readNotificationCache);
    }
  }

  void addNotificationReadStatus(String notificationId) {
    readNotificationCache.putIfAbsent(notificationId, () => true);
    readNotificationCache[notificationId] = true;
  }

  @override
  Future<void> close() {
    triggerSync();
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    return super.close();
  }
}
