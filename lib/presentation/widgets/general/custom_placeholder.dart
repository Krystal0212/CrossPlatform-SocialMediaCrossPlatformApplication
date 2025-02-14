import 'package:socialapp/utils/import.dart';

class AppPlaceHolder extends StatelessWidget {
  const AppPlaceHolder({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.grey.shade300,
        child: const Icon(
          Icons.image_not_supported,
          size: 50,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class ErrorPagePlaceholder extends StatelessWidget {
  const ErrorPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SizedBox(
        width: deviceWidth,
        height: deviceHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 100,
                color: AppColors.sangoRed,
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.pageNotFound,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
               Text(
                AppStrings.noPageExist,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppTheme.white),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(AppStrings.goBack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignInPagePlaceholder extends StatelessWidget {
  final double width;

  const SignInPagePlaceholder({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: width,
        height: 700,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppImages.pleaseSignIn,
                width: 280,
              ),
              const SizedBox(height: 20),
              const Text(
                AppStrings.pleaseSignIn,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 10),
              const Text(
                AppStrings.needSignIn,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageErrorPlaceholder extends StatelessWidget {
  const ImageErrorPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            size: 80,
            color: AppColors.trolleyGrey,
          ),
          SizedBox(height: 10),
          Text(
            AppStrings.notDisplayImage,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class NoMorePostsPlaceholder extends StatelessWidget {
  final double width;

  const NoMorePostsPlaceholder({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    final flutterView = PlatformDispatcher.instance.views.first;
    double deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    double deviceHeight = flutterView.physicalSize.height / flutterView.devicePixelRatio;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackOak.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: deviceWidth * 0.02, vertical: deviceHeight * 0.01),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      width: width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppImages.noMorePosts, height: width*0.5,),
             Text(
              AppStrings.noMorePosts,
              style: AppTheme.gradientShowMoreContentTextStyle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class NoPublicDataErrorPlaceholder extends StatelessWidget {
  final double width;

  const NoPublicDataErrorPlaceholder({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.only(top: 5, left:width*0.1 , right: width*0.1),
      width: width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppImages.noMorePosts, height: width*0.5,),
            const SizedBox(height: 20),

            Text(
              'There is something wrong, can\'t get any public data.',
              style: AppTheme.gradientShowMoreContentTextStyle.copyWith(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class NoPublicDataAvailablePlaceholder extends StatelessWidget {
  final double width;

   const NoPublicDataAvailablePlaceholder({super.key, required this.width,});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.only(top: 5, left:width*0.1 , right: width*0.1),
      width: width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppImages.noMorePosts, height: width*0.5,),
            Text(
              'No public data available',
              style: AppTheme.gradientShowMoreContentTextStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NoCommentDataAvailablePlaceholder extends StatelessWidget {

  const NoCommentDataAvailablePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final flutterView = PlatformDispatcher.instance.views.first;
    double deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    double deviceHeight = flutterView.physicalSize.height;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.only(top: 5, left:deviceWidth*0.1 , right: deviceWidth*0.1),
      width: deviceWidth,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppImages.noMorePosts, height: deviceWidth*0.5,),
            Text(
              'No comments available on this post yet',
              style: AppTheme.gradientShowMoreContentTextStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NoContactsAvailablePlaceholder extends StatelessWidget {
  final double width;

  const NoContactsAvailablePlaceholder({super.key, required this.width,});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.only(top: 5, left:width*0.1 , right: width*0.1),
      width: width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppImages.noMorePosts, height: width*0.5,),
            Text(
              'No contacts available',
              style: AppTheme.gradientShowMoreContentTextStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NoFollowingsPlaceholder extends StatelessWidget {
  final double width;

  const NoFollowingsPlaceholder({super.key, required this.width,});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.only(top: 5, left:width*0.1 , right: width*0.1),
      width: width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppImages.noMorePosts, height: width*0.5,),
            Text(
              'Your followings list is empty, please follow someone or search their tag names to add contact',
              style: AppTheme.gradientShowMoreContentTextStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NoUserResultPlaceholder extends StatelessWidget {
  final double width;

  const NoUserResultPlaceholder({super.key, required this.width,});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.only(top: 5, left:width*0.1 , right: width*0.1),
      width: width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppImages.noMorePosts, height: width*0.5,),
            Text(
              'There is no user match your result',
              style: AppTheme.gradientShowMoreContentTextStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


class ProcessingDataPlaceholder extends StatelessWidget {
  final double width;

  const ProcessingDataPlaceholder({super.key, required this.width,});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.only(top: 5, left:width*0.1 , right: width*0.1),
      width: width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppImages.empty, height: width*0.5,),
            Text(
              'We are processing, wait a little',
              style: AppTheme.gradientShowMoreContentTextStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NoUserDataAvailablePlaceholder extends StatelessWidget {
  final double width;

  const NoUserDataAvailablePlaceholder({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.only(top: 5, left:width*0.1 , right: width*0.1),
      width: width,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(AppImages.noMorePosts, height: width*0.5,),
            Text(
              'No profile data available',
              style: AppTheme.gradientShowMoreContentTextStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class GettingDataPlaceholder extends StatelessWidget {
  const GettingDataPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final flutterView = PlatformDispatcher.instance.views.first;
    double deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    double deviceHeight = flutterView.physicalSize.height / flutterView.devicePixelRatio;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: deviceWidth * 0.05, vertical: deviceHeight * 0.02),
      padding: EdgeInsets.symmetric(horizontal: deviceWidth * 0.1, vertical: 20),
      width: deviceWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(AppImages.noMorePosts, height: deviceWidth * 0.4),
          const SizedBox(height: 16), // Space between image and text
          Text(
            'Wait a little, we are getting data',
            style: AppTheme.gradientShowMoreContentTextStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16), // Space between text and loading indicator
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.iris),
            strokeWidth: 3,
          ),
        ],
      ),
    );
  }
}

class NoUserIsSignedInPlaceholder extends StatelessWidget {

  const NoUserIsSignedInPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final flutterView = PlatformDispatcher.instance.views.first;
    double deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    double deviceHeight = flutterView.physicalSize.height / flutterView.devicePixelRatio;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.only(top: 5, left:deviceWidth*0.1 , right: deviceWidth*0.1),
      width: deviceWidth,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.notSignInNotAllow, height: deviceWidth*0.5,),
            SizedBox(height: deviceHeight*0.05,),
            Text(
              'Oh no!!!\nYou are only allowed to see this page when you are signed in',
              style: AppTheme.gradientShowMoreContentTextStyle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: deviceHeight*0.05,),
            AuthElevatedButton(
              width: deviceWidth,
              height: 45,
              inputText: "GO TO SIGN IN",
              onPressed: () {
                context.go('/sign-in');
              }, isLoading: false,
            ),
          ],
        ),
      ),
    );
  }
}
