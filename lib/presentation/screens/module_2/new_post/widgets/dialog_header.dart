import 'package:socialapp/utils/import.dart';

class DialogHeader extends StatelessWidget {
  final double sideWidth;

  const DialogHeader({super.key, required this.sideWidth});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: sideWidth,
          width: sideWidth,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: AppTheme.actionNoEffectCircleButtonStyle.copyWith(
              backgroundColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
            ),
            child:
            SvgPicture.asset(AppIcons.cross, width: 18, height: 18),
          ),
        ),
        const Text(
          'Create New Post',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: sideWidth,
        )
      ],
    );
  }
}
