import 'package:socialapp/utils/import.dart';

class AuthContainer extends StatelessWidget {
  final Widget child;
  final bool isSmallView;
  final double deviceWidth;
  final double deviceHeight;
  final EdgeInsets padding;

  const AuthContainer(
      {super.key,
      required this.child,
      required this.isSmallView,
      required this.deviceWidth,
      required this.deviceHeight,
      required this.padding,});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            isSmallView ? BorderRadius.circular(0) : BorderRadius.circular(20),
      ),
      padding: isSmallView
          ? const EdgeInsets.all(0)
          : padding,
      // padding: isSmallView
      //     ? AppTheme.preferredTopicMobilePaddingEdgeInsets
      //     : AppTheme.preferredTopicWebsitePaddingEdgeInsets(deviceWidth),
      height: isSmallView ? deviceHeight : deviceHeight * 0.9,
      child: child,
    );
  }
}
