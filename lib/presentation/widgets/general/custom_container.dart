import 'package:socialapp/utils/import.dart';

class BackgroundContainer extends StatelessWidget {
  const BackgroundContainer({super.key, this.center, this.column, this.opacity});

  final Widget? center;
  final Column? column;
  final double? opacity;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      width: deviceWidth,
      height: deviceHeight,
      decoration: AppTheme.splashBackgroundBoxDecoration,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: opacity ?? 0.4,
            child: Container(
              color: AppColors.iric,
            ),
          ),
          center ?? Container(),
          column ?? Container(),
        ],
      ),
    );
  }
}
