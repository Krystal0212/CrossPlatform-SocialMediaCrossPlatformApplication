
import 'package:socialapp/presentation/screens/module_3/notification/cubit/notification_state.dart';
import 'package:socialapp/utils/import.dart';
import 'cubit/notification_cubit.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationCubit(),
      child: const NotificationBase(),
    );
  }
}

class NotificationBase extends StatefulWidget {
  const NotificationBase({super.key});

  @override
  State<NotificationBase> createState() => _NotificationBaseState();
}

class _NotificationBaseState extends State<NotificationBase> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return const Center(child: CircularProgressIndicator());
          } else
          if(state is NotificationLoaded){
            final UserModel user = state.user;
          String userId = user.id!;

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection("notifications").doc(userId).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data?.data() == null) {
                return const Center(child: Text("No notifications yet"));
              }

              Map<String, dynamic> notifications = snapshot.data!.data() as Map<String, dynamic>;

              List<Widget> notificationWidgets = notifications.entries.map((entry) {
                final data = entry.value;
                return Dismissible(
                  key: Key(entry.key),
                  onDismissed: (_) async {
                    await FirebaseFirestore.instance.collection("notifications").doc(userId).update({
                      entry.key: FieldValue.delete(),
                    });
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    leading: Icon(_getNotificationIcon(data["type"])),
                    title: Text(_getNotificationText(data)),
                    subtitle: Text(
                      _formatTimestamp(data["timestamp"]),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }).toList();

              return ListView(children: notificationWidgets);
            },
          );
        }
        else {
          return NoUserDataAvailablePlaceholder(width: MediaQuery.of(context).size.width*0.9);
          }
        }
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case "like":
        return Icons.favorite;
      case "comment":
        return Icons.comment;
      case "add_to_collection":
        return Icons.bookmark;
      case "message":
        return Icons.message;
      case "send_asset":
        return Icons.attach_file;
      default:
        return Icons.notifications;
    }
  }

  String _getNotificationText(Map<String, dynamic> data) {
    String fromUser = data["fromUserId"];
    switch (data["type"]) {
      case "like":
        return "$fromUser liked your post.";
      case "comment":
        return "$fromUser commented on your post.";
      case "add_to_collection":
        return "$fromUser added your post to a collection.";
      case "message":
        return "$fromUser sent you a message.";
      case "send_asset":
        return "$fromUser sent you a file.";
      default:
        return "You have a new notification.";
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return "${date.hour}:${date.minute}, ${date.day}/${date.month}/${date.year}";
  }

}
