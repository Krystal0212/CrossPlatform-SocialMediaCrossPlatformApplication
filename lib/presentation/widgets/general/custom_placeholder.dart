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
