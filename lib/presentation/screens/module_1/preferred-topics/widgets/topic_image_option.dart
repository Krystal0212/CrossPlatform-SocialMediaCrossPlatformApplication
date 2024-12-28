import 'package:socialapp/utils/import.dart';

class TopicImageOption extends StatelessWidget {
  final Map<TopicModel, bool> currentTopicMap;
  final TopicModel topic;

  const TopicImageOption(
      {super.key, required this.currentTopicMap, required this.topic});

  @override
  Widget build(BuildContext context) {
    bool isChosen = currentTopicMap[topic] ?? false;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: AppTheme.smallBorderRadius,
          ),
          child: ClipRRect(
            borderRadius: AppTheme.smallBorderRadius,
            child: Stack(
              children: [
                CachedNetworkImage(imageUrl: topic.thumbnailUrl),
                if (!isChosen)
                  Opacity(
                    opacity: 0.9,
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: AppColors.carbon,
                          blurRadius: 10,
                          spreadRadius: 20,
                          offset: Offset(0, 30),
                        ),
                        // BoxShadow(
                        //   color: AppColors.carbon,
                        //   offset: Offset(-12, 0),
                        //   blurRadius: 32,
                        //   spreadRadius: -2,
                        // ),
                        // BoxShadow(
                        //   color: AppColors.carbon,
                        //   offset: Offset(12, 0),
                        //   blurRadius: 32,
                        //   spreadRadius: -2,
                        // ),
                        // BoxShadow(
                        //   color: AppColors.carbon,
                        //   offset: Offset(0, 12),
                        //   blurRadius: 32,
                        //   spreadRadius: -2,
                        // ),
                        // BoxShadow(
                        //   color: AppColors.white.withValues(alpha: .8)
                        // )
                      ]),
                    ),
                  ),
                // Opacity(
                //   opacity: 0.3,
                //   child: Transform(
                //     alignment: Alignment.center,
                //     transform: Matrix4.rotationY(3.14159),
                //     child: Container(
                //       decoration:
                //       AppTheme.profileBackgroundBoxDecoration,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 5,
          bottom: 20,
          child: Text(
            topic.name,
            style: AppTheme.drawerItemStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
