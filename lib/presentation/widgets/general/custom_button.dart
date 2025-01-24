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
  final ButtonStyle? style;
  final double? boxWidth;

   const CircularIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor = AppColors.systemShockBlue, this.style,  this.boxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return
      boxWidth!= null ?
      Container(
        width: boxWidth,
        height: boxWidth,
        decoration:  BoxDecoration(
          shape: BoxShape.circle,
            color: backgroundColor
        ),
        child: Center(
          child: ElevatedButton(
            style: style ?? AppTheme.actionSignInCircleButtonStyle,
            onPressed: onPressed,
            child: icon,
          ),
        ),
      ):ElevatedButton(
        style: style ?? AppTheme.actionSignInCircleButtonStyle,
        onPressed: onPressed,
        child: icon,
      );
  }
}

class CircularTextButton extends StatelessWidget {
  final Widget text;
  final void Function()? onPressed;
  final Color backgroundColor;
  final ButtonStyle? style;
  final double? boxWidth;
  final IconData? icon; // Add icon parameter

  const CircularTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = AppColors.systemShockBlue,
    this.style,
    this.boxWidth,
    this.icon, // Optional icon parameter
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed, // Handle button press
      child: Container(
        width: boxWidth,
        height: boxWidth,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: Center(
          child: icon != null
              ? Icon(
            icon, // Display icon if provided
            size: 24, // Icon size can be adjusted
            color: Colors.white, // Icon color
          )
              : text, // If no icon, display text
        ),
      ),
    );
  }
}
