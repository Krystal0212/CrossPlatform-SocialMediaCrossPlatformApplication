import 'package:socialapp/utils/import.dart';

class TopicImageOption extends StatelessWidget {
  final Map<TopicModel, bool> currentTopicMap;
  final double optionSize;
  final TopicModel topic;

  const TopicImageOption({
    super.key,
    required this.currentTopicMap,
    required this.topic,
    required this.optionSize,
  });

  @override
  Widget build(BuildContext context) {
    bool isChosen = currentTopicMap[topic] ?? false;

    double scale = isChosen ? 0.85 : 1.0;
    double boxShadowScale = isChosen ? 1.35 : 1.0;
    double padding = optionSize * 0.07;

    return Stack(
      children: [
        Transform.scale(
          scale: scale,
          child: ClipRRect(
            borderRadius: AppTheme.smallBorderRadius,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: CachedNetworkImage(imageUrl: topic.thumbnailUrl, fit: BoxFit.cover,
                    placeholder: (context, url) => const CircularProgressIndicator(
                      color: AppColors.iris,
                      strokeWidth: 2,
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: isChosen
                          ? AppTheme.topicChosenOptionBoxShadow
                          : AppTheme.topicNotChosenOptionBoxShadow,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: padding * boxShadowScale,
          bottom: padding * boxShadowScale,
          child: SizedBox(
            width: optionSize * 0.6,
            child: Text(
              topic.name,
              style: AppTheme.gridItemTitleStyle,
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        if (isChosen)
          ...[
            Positioned(
              top: padding+3,
              right: padding,
              child: SvgPicture.asset(
                AppIcons.checked,
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.black, width: 5.0),
                  borderRadius: AppTheme.smallBorderRadius,
                ),
              ),
            ),
          ],
      ],
    );
  }
}
