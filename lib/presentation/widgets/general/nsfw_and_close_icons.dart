import 'package:socialapp/utils/import.dart';

class CloseIconButton extends StatelessWidget {
  final VoidCallback onTap;

  const CloseIconButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: AppTheme.redDecoration,
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 15,
        ),
      ),
    );
  }
}

class NSFWIcon extends StatelessWidget {
  const NSFWIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: 10,
      right: 10,
      child: MouseRegion(
        child: Tooltip(
          message: AppStrings.alertNSFW,
          child: CircleAvatar(
            backgroundColor: AppColors.circus,
            radius: 20,
            child: Icon(
              Icons.warning,
              color: AppColors.dynamicBlack,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}