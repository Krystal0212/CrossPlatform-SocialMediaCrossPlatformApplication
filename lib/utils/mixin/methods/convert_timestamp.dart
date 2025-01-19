
import 'package:socialapp/utils/import.dart';

mixin Methods {
  String calculateTimeFromNow(Timestamp timestamp) {
    // Convert the Timestamp to DateTime
    DateTime time = timestamp.toDate();

    var now = DateTime.now();
    var diff = now.difference(time);
    var timeString = '';

    if (diff.inSeconds <= 0) {
      timeString = 'Just now';
    } else if (diff.inMinutes == 0) {
      timeString = 'Just now';
    } else if (diff.inHours == 0) {
      timeString = '${diff.inMinutes} minutes ago';
    } else if (diff.inDays == 0) {
      timeString = '${diff.inHours} hours ago';
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      timeString = '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else {
      timeString = '${(diff.inDays / 7).floor()} week${(diff.inDays / 7).floor() > 1 ? 's' : ''} ago';
    }

    return timeString;
  }

}