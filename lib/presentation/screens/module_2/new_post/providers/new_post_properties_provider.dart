import 'package:socialapp/utils/import.dart';

import '../cubit/new_post_cubit.dart';

class NewPostProperties {
  final UserModel? user;
  final BuildContext homeContext;
  final bool? isCompactView, isMediumView, isLargeView;
  List<TopicModel>? topics;

  NewPostProperties( {required this.homeContext,   this.isCompactView, this.isMediumView,  this.isLargeView,
    required this.user, this.topics,
  });
}

class NewPostPropertiesProvider extends InheritedWidget {
  final NewPostProperties newPostProperties;

  const NewPostPropertiesProvider({
    super.key,
    required this.newPostProperties,
    required super.child,
  });

  static NewPostProperties? of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<NewPostPropertiesProvider>();
    return provider?.newPostProperties;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return oldWidget is NewPostPropertiesProvider &&
        (oldWidget.newPostProperties != newPostProperties);
  }
}
