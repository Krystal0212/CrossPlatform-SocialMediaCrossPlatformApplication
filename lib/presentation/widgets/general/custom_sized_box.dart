import 'package:socialapp/utils/import.dart';

class AuthSizedBox extends StatelessWidget {
  final Widget child;
  final bool isWeb;
  final double deviceWidth;
  final double deviceHeight;

  const AuthSizedBox({
    super.key,
    required this.child,
    required this.isWeb,
    required this.deviceWidth,
    required this.deviceHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: (isWeb && deviceWidth < 530) ? deviceHeight : deviceHeight * 0.9,
        child: child,
      ),
    );
  }
}
