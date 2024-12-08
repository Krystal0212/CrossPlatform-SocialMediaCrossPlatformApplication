import 'package:socialapp/utils/import.dart';

class AuthScrollView extends StatelessWidget {
  final Widget? child;

  const AuthScrollView({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
    child: SingleChildScrollView(
    child: child ?? const AppPlaceHolder())
    );
  }
}
