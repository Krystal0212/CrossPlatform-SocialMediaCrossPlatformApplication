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
  static Color get black => AppColors.dynamicBlack; // Black

  //ToDo: Gradient
  static Gradient get mainGradient => const LinearGradient(
        colors: [AppColors.iris, AppColors.lavenderBlueShadow],
      );

  static Gradient get disableGradient => const LinearGradient(
        colors: [AppColors.blackOak, AppColors.kettleman],
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
      ));

  static BoxDecoration get profileBackgroundBoxDecoration => BoxDecoration(
      image: const DecorationImage(
        image: AssetImage(AppImages.editProfileAppbarBackground),
        fit: BoxFit.cover,
      ),
      borderRadius: AppTheme.smallBorderRadius);

  static BoxDecoration get addCollectionBoxDecoration => const BoxDecoration(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      color: Colors.white);

  static BoxDecoration get redDecoration => const BoxDecoration(
  shape: BoxShape.circle,
  color: AppColors.bethlehemRed,
  );

  static BoxDecoration get whiteDialogDecoration => BoxDecoration(
  color: AppTheme.white,
  borderRadius: const BorderRadius.all(Radius.circular(10)),
  );

  //ToDo: Border Radius
  static BorderRadius get smallBorderRadius =>
      const BorderRadius.all(Radius.circular(12));

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
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: black,
      );

  static TextStyle get showMoreTextStyle => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.iris,
      );

  static TextStyle get blackUsernameStyle => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: black,
      );

  static TextStyle get highlightedHashtagStyle => GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.blueDeFrance,
      );

  static TextStyle get gradientShowMoreContentTextStyle =>
      GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: black,
      );

  static TextStyle get logOutButtonStyle => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: black,
      );

  static TextStyle get topicLabelStyle => GoogleFonts.plusJakartaSans(
        color: white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
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

  static TextStyle get gridItemTitleStyle => GoogleFonts.plusJakartaSans(
        color: white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
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

  static TextStyle get topicBottomTitle => GoogleFonts.plusJakartaSans(
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
      color: AppColors.iris,
      fontWeight: FontWeight.w400,
      letterSpacing: 2,
      fontSize: 14);

  static TextStyle get authSignUpStyle => GoogleFonts.plusJakartaSans(
      color: AppColors.iris, fontSize: 16, fontWeight: FontWeight.w500);

  static TextStyle get authWhiteText => GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 14,
      );

  static TextStyle get signInWhiteText => GoogleFonts.plusJakartaSans(
      color: Colors.white, fontSize: 15, fontWeight: FontWeight.normal);

  static TextStyle get signUpBlackText => GoogleFonts.plusJakartaSans(
      color: Colors.black, fontSize: 15, fontWeight: FontWeight.normal);

  static TextStyle get boldTextStyle =>
      GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.bold);

  //ToDo: PaddingEdgeInsetsStyle
  static EdgeInsets get preferredTopicMobilePaddingEdgeInsets =>
      const EdgeInsets.only(top: 160, left: 20, right: 20, bottom: 20);

  static EdgeInsets get postHorizontalPaddingEdgeInsets =>
      const EdgeInsets.symmetric(horizontal: 14.45, vertical: 10);

  static EdgeInsets get iconHorizontalPaddingEdgeInsets =>
      const EdgeInsets.only(right: 3);

  static EdgeInsets bottomDialogPaddingEdgeInsets(double deviceHeight) {
    return EdgeInsets.only(bottom: deviceHeight / 2 - 200);
  }

  static EdgeInsets preferredTopicWebsitePaddingEdgeInsets(
      double deviceWidth,
      double deviceHeight,
      double paddingRatioWidth,
      double paddingRatioHeight) {
    double horizontalPadding = deviceWidth * paddingRatioWidth;
    double verticalPadding = deviceHeight * paddingRatioHeight;
    return EdgeInsets.only(
      top: verticalPadding,
      left: horizontalPadding,
      right: horizontalPadding,
      bottom: verticalPadding,
    );
  }

  static EdgeInsets get bottomPaddingEdgeInsets =>
      const EdgeInsets.only(bottom: 20);

  static EdgeInsets horizontalPostContentPaddingEdgeInsets(
      double horizontalPadding) {
    return EdgeInsets.symmetric(horizontal: horizontalPadding);
  }

  static EdgeInsets get addCollectionPaddingEdgeInsets =>
      const EdgeInsets.fromLTRB(24, 32, 24, 0);

  static EdgeInsets homeListPostPaddingEdgeInsets(double horizontalPadding) {
    return EdgeInsets.symmetric(horizontal: horizontalPadding);
  }

  //ToDo: BoxContainerShadow
  static List<BoxShadow> get topicNotChosenOptionBoxShadow => const [
        BoxShadow(
          color: AppColors.dynamicBlack,
          blurRadius: 65,
          spreadRadius: 8,
          offset: Offset(0, 120),
        ),
        BoxShadow(
          color: AppColors.dynamicBlack,
          blurRadius: 65,
          spreadRadius: 8,
          offset: Offset(-170, 00),
        ),
        BoxShadow(
          color: AppColors.dynamicBlack,
          blurRadius: 65,
          spreadRadius: 8,
          offset: Offset(170, 00),
        ),
      ];

  static List<BoxShadow> get topicChosenOptionBoxShadow => [
        BoxShadow(
          color: AppColors.dynamicBlack.withOpacity(0.65),
        ),
      ];

  //ToDo: ButtonStyle
  static ButtonStyle get navigationTextButtonStyle => ElevatedButton.styleFrom(
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      elevation: 0,
      splashFactory: NoSplash.splashFactory,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      overlayColor: Colors.transparent);

  static ButtonStyle get navigationLogoButtonStyle => ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: AppColors.white,
        elevation: 0,
        splashFactory: NoSplash.splashFactory,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ).copyWith(
        overlayColor:
            const WidgetStatePropertyAll(Colors.transparent), // No hover effect
      );

  static ButtonStyle get actionSignInButtonStyle => TextButton.styleFrom(
        backgroundColor: AppColors.systemShockBlue,
        foregroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(50, 45),
      );

  static ButtonStyle get actionSignUpButtonStyle => TextButton.styleFrom(
        backgroundColor: AppColors.pinkSpyro,
        foregroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(50, 45),
      );

  static ButtonStyle get navigationIconButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.white,
        splashFactory: NoSplash.splashFactory,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ).copyWith(
        overlayColor:
            const WidgetStatePropertyAll(Colors.transparent), // No hover effect
      );

  static ButtonStyle get actionNoEffectCircleButtonStyle =>
      ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: const CircleBorder(),
        splashFactory: NoSplash.splashFactory,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        overlayColor: Colors.transparent,
      );

  //ToDo: ColorFilter
  static ColorFilter get iconColorFilter => const ColorFilter.mode(
        Color.fromARGB(255, 89, 28, 219),

        BlendMode.srcIn, // Choose the desired blend mode
      );

  //ToDo: InputDecoration
  static InputDecoration get whiteInputDecoration => InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        fillColor: AppTheme.white,
        filled: true,
        hoverColor: AppTheme.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppTheme.white),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppTheme.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: AppTheme.white),
        ),
        hintText: AppStrings.whatNew,
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
