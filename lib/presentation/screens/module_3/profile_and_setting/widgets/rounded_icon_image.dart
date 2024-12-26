

import 'package:socialapp/utils/import.dart';

class RoundedTrailingIcon extends StatelessWidget {
  // final String assetPath;
  final double iconSize;
  final Color ovalColor;

  const RoundedTrailingIcon({
    super.key,
    // required this.assetPath,
    this.iconSize = 18.0,
    this.ovalColor = Colors.transparent, // Default to transparent if no color is set
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: ovalColor,
      radius: (iconSize + 12) / 2, // Set the radius to half the desired diameter
      child: SvgPicture.asset(
        AppIcons.whiteChevronRightButton,
        height: iconSize,
        width: iconSize,
      ),
    );
  }
}

