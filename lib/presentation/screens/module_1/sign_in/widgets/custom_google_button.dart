import '../../../../../utils/import.dart';

class GoogleButton extends StatelessWidget {
  final void Function() onPressed;

  const GoogleButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.lavenderMist,
        ),
        child: ShaderMask(
          shaderCallback: (Rect bounds) {
            return AppTheme.mainGradient
                .createShader(bounds);
          },
          child: SvgPicture.asset(
            AppIcons.googleLogo,
            width: 20.0,
            height: 20.0,
            colorFilter: AppTheme.iconColorFilter,
          ),
        ),
      ),
    );
  }
}
