import 'package:socialapp/utils/import.dart';
import 'package:shimmer/shimmer.dart';

class ChatImagePlaceholder extends StatelessWidget {
  final double height;
  final double width;

  const ChatImagePlaceholder({
    super.key,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: AppColors.tangledWeb,
        highlightColor:  AppColors.white,
        child: Container(
          color: AppColors.corona,
          width: width,
          height: height,
        ));
  }
}
