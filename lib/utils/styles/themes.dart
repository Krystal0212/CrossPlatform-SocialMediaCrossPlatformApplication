import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socialapp/utils/import.dart';

import 'colors.dart';

class AppTheme {
  //ToDo: Color
  static Color get error => AppColors.sangoRed; // Error color
  static Color get primary => AppColors.iris; // Primary color
  static Color get lightBackground =>
      AppColors.roseDragee; // Background color for light theme
  static Color get hintTextColor => AppColors.noghreiSilver; // Hint text color
  static Color get labelTextColor =>
      AppColors.verifiedBlack; // Label text color
  static Color get white => AppColors.white; // White color
  static Color get black => AppColors.erieBlack; // Black

  //ToDo: Gradient
  static Gradient get mainGradient => const LinearGradient(
        colors: [AppColors.iris, AppColors.lavenderBlueShadow],
      );

  static dynamic get mainGradientShader =>
      AppTheme.mainGradient.createShader(const Rect.fromLTWH(0, 0, 100, 50));

  //ToDo: BoxDecoration
  static BoxDecoration get gradientIconBoxDecoration => BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      gradient: mainGradient);

  static BoxDecoration get gradientFabBoxDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: mainGradient,
      );

  static BoxDecoration get splashBackgroundBoxDecoration => const BoxDecoration(
        image: DecorationImage(
            image: AssetImage(AppImages.webSplashBackground),
            fit: BoxFit.cover),
      );

  static BoxDecoration get maskBoxDecoration => const BoxDecoration(
      image: DecorationImage(
          image: AssetImage(AppImages.authMask), fit: BoxFit.cover));

  static BoxDecoration get gradientBoxDecoration => const BoxDecoration(
          gradient: LinearGradient(
        colors: [
          Color.fromRGBO(82, 82, 199, 0.5),
          Color.fromRGBO(82, 82, 199, 0.1),
        ],
      )
  );

  static BoxDecoration get profileBackgroundBoxDecoration => BoxDecoration(
      image: const DecorationImage(
        image: AssetImage(AppImages
            .editProfileAppbarBackground),
        fit: BoxFit.cover,
      ),
      borderRadius: AppTheme.smallBorderRadius);

  static BoxDecoration get addCollectionBoxDecoration => const BoxDecoration(
  borderRadius: BorderRadius.only(
  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
  color: Colors.white);

  //ToDo: Border Radius
  static BorderRadius get smallBorderRadius=> const BorderRadius.all(
  Radius.circular(12));

  //ToDo:
  static EdgeInsets get paddingBottom => const EdgeInsets.only(bottom: 20);
  static EdgeInsets get addCollectionPadding => const EdgeInsets.fromLTRB(24, 32, 24, 0);

  //ToDo: Style
  static TextStyle get appLabelStyle => GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: labelTextColor,
      letterSpacing: 0.60);

  static TextStyle get appHintStyle => GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: hintTextColor,
      letterSpacing: 0.60);

  static TextStyle get profileLocationStyle => GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.30,
        color: AppColors.delicateViolet,
      );

  static TextStyle get profileTagStyle => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: white,
      );

  static TextStyle get headerStyle => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: white,
      );

  static TextStyle get blackHeaderStyle => GoogleFonts.plusJakartaSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: black,
      );

  static TextStyle get logOutButtonStyle => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: black,
      );

  static TextStyle get categoryLabelStyle => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: black,
      );

  static TextStyle get buttonGradientStyle => GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w700,
        color: white,
        fontSize: 16,
        height: 0.09,
        letterSpacing: 0.60,
      );

  static TextStyle get profileCasualStyle => GoogleFonts.plusJakartaSans(
      color: hintTextColor, fontSize: 16, fontWeight: FontWeight.bold);

  static TextStyle get profileTabStyle => GoogleFonts.plusJakartaSans(
      color: hintTextColor, fontSize: 12, fontWeight: FontWeight.bold);

  static TextStyle get profileNumberStyle => GoogleFonts.plusJakartaSans(
        color: black,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      );

  static TextStyle get drawerItemStyle => GoogleFonts.plusJakartaSans(
        color: white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.1,
      );

  static TextStyle get forgotPasswordLabelStyle => GoogleFonts.plusJakartaSans(
        color: white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      );

  static TextStyle get gridItemStyle => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.white,
        letterSpacing: -0.1,
      );

  static TextStyle get categoryBottomTitle => GoogleFonts.plusJakartaSans(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: AppColors.white,
      letterSpacing: 2);

  static TextStyle get authHeaderStyle => GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w400,
        fontSize: 40,
        foreground: Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 // Độ dày của viền chữ
          ..color = AppColors.white, // Màu
      );

  static TextStyle get authNormalStyle => GoogleFonts.plusJakartaSans(
        color: AppColors.kettleman,
        fontWeight: FontWeight.w400,
        letterSpacing: 2,
        fontSize: 14,
      );

  static TextStyle get authForgotStyle => GoogleFonts.plusJakartaSans(
      color: AppColors.iric,
      fontWeight: FontWeight.w400,
      letterSpacing: 2,
      fontSize: 14);

  static TextStyle get authSignUpStyle => GoogleFonts.plusJakartaSans(
      color: AppColors.iric, fontSize: 16, fontWeight: FontWeight.w500);

  static TextStyle get authWhiteText => const TextStyle(
        color: Colors.white,
        fontSize: 14,
      );

  //ToDo: ButtonStyle
  static ButtonStyle get navigationTextButtonStyle => ElevatedButton.styleFrom(
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      splashFactory: NoSplash.splashFactory,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      overlayColor: Colors.transparent);

  //ToDo: ColorFilter
  static ColorFilter get iconColorFilter => const ColorFilter.mode(
        Color.fromARGB(255, 89, 28, 219),

        BlendMode.srcIn, // Choose the desired blend mode
      );

  //ToDo: Theme
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: white,
    brightness: Brightness.light,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),

    // Customize Slider theme
    sliderTheme: SliderThemeData(
      overlayShape: SliderComponentShape.noOverlay,
    ),

    // Customize Icon theme
    iconTheme: IconThemeData(
      color: white, // Set default color for icons
      size: 24, // Default icon size
    ),

    // Customize Input Decorations
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.chefsHat,
      contentPadding: const EdgeInsets.all(30),
      hintStyle: appHintStyle,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    ),

    // Customize Elevated Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );
}
