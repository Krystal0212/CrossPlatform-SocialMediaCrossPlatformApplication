import 'package:socialapp/utils/import.dart';

class IconElevatedButton extends StatelessWidget {
  final ButtonStyle? style;
  final Widget? icon;
  final String label;
  final TextStyle? textStyle;
  final void Function()? onPressed;
  final EdgeInsets padding;

  const IconElevatedButton(
      {super.key,
        required this.style,
        required this.icon,
        required this.label,
        this.textStyle,
        required this.onPressed,
        this.padding = const EdgeInsets.only(bottom: 2)});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: style,
      icon: icon,
      label: Padding(
        padding: padding,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: textStyle,
        ),
      ),
      onPressed: onPressed,
    );
  }
}

class CircularIconButton extends StatelessWidget {
  final Widget icon;
  final void Function()? onPressed;
  final Color backgroundColor;

  const CircularIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return
      ElevatedButton(
        style: AppTheme.actionSignInCircleButtonStyle,
        onPressed: onPressed,
        child: icon,

      );
  }
}