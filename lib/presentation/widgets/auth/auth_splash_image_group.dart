import 'splash_image.dart';
import '../../../../../utils/import.dart';

//Group create splash image
class SplashImageGroup extends StatelessWidget {
  final EdgeInsets? margin;
  const SplashImageGroup({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    double baseLength = (PlatformConfig.of(context)?.isWeb ?? false) ? 500 : 325;
    double containerWidth = baseLength/0.8125;
    double splash1Length= baseLength*0.4;
    double splash2Length= baseLength*0.492;
    double splash3Length= baseLength*0.415;
    double splash1MarginTop = baseLength*(5/325);
    double splash2MarginTop = baseLength*(25/325);
    double splash3MarginTop = baseLength*(125/325);
    double splash4MarginTop = baseLength*(250/325);
    double splash5MarginTop = baseLength*(200/325);

    return Container(
      // margin: margin,
      width: baseLength,
      height: containerWidth,
      padding: const EdgeInsets.all(10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SplashImage(
            top: splash1MarginTop,
            width: splash1Length,
            height: splash1Length,
            gradient: const LinearGradient(colors: [
              AppColors.lightIris,
              AppColors.iris,
            ]),
          ),
          SplashImage(
            width: splash2Length,
            height: splash2Length,
            top: splash2MarginTop,
            image: const DecorationImage(
              image: AssetImage(AppImages.splash1),
            ),
          ),
          SplashImage(
            width: splash3Length,
            height: splash3Length,
            top: splash3MarginTop,
            left: splash1MarginTop,
            image: const DecorationImage(
              image: AssetImage(AppImages.splash2),
            ),
          ),
          SplashImage(
            width: splash3Length,
            height: splash3Length,
            top: splash3MarginTop,
            right: splash1MarginTop,
            image: const DecorationImage(
              image: AssetImage(AppImages.splash3),
            ),
          ),
          SplashImage(
            top: splash4MarginTop,
            width: splash1Length,
            height: splash1Length,
            gradient: const LinearGradient(colors: [
              AppColors.iris,
              AppColors.lightIris,
            ]),
          ),
          SplashImage(
            width: splash2Length,
            height: splash2Length,
            top: splash5MarginTop,
            image: const DecorationImage(
              image: AssetImage(AppImages.splash4),
            ),
          ),
        ],
      ),
    );
  }
}
