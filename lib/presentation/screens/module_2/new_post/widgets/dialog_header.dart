import 'package:socialapp/utils/import.dart';

import '../cubit/new_post_cubit.dart';
import '../providers/new_post_properties_provider.dart';

class WebsiteDialogHeader extends StatelessWidget {
  final double sideWidth;

  const WebsiteDialogHeader({super.key, required this.sideWidth});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: sideWidth,
            width: sideWidth,
            child: ElevatedButton(
              onPressed: () => context.pop(),
              style: AppTheme.actionNoEffectCircleButtonStyle.copyWith(
                backgroundColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
              ),
              child: SvgPicture.asset(AppIcons.cross, width: 18, height: 18),
            ),
          ),
        ),
        const Align(
          alignment: Alignment.center,
          child: Text(
            'Create New Post',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),

      ],
    );
  }
}

class MobileDialogHeader extends StatelessWidget {
  final double sideWidth;
  final ValueNotifier<List<Map<String, dynamic>>> imagePathNotifier;
  final TextEditingController styleableTextFieldController;
  final ValueNotifier<List<TopicModel>> topicSelectedNotifier;

  const MobileDialogHeader({
    super.key,
    required this.sideWidth,
    required this.imagePathNotifier,
    required this.styleableTextFieldController,
    required this.topicSelectedNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: SizedBox(
        height: 45,
        width: double.infinity,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: sideWidth,
                width: sideWidth,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: AppTheme.actionNoEffectCircleButtonStyle.copyWith(
                    backgroundColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                  ),
                  child: SvgPicture.asset(AppIcons.cross, width: 20, height: 20),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(-0.5,0),
              child: Text(
                'Create New Post',
                style: AppTheme.newPostTitleStyle,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      context.read<NewPostCubit>().pickImagesMobile(imagePathNotifier, context);
                    },
                    icon: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return AppTheme.mainGradient.createShader(bounds);
                      },
                      child: const Icon(
                        Icons.perm_media_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<NewPostCubit>().pickVideoMobile(
                        imagePathNotifier,
                        NewPostPropertiesProvider.of(context)!.homeContext,
                      );
                    },
                    icon: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return AppTheme.mainGradient.createShader(bounds);
                      },
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // _showRecordingDialog(context)
                    },
                    icon: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return AppTheme.mainGradient.createShader(bounds);
                      },
                      child: const Icon(
                        Icons.mic_rounded,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<NewPostCubit>().sendPost(
                          NewPostPropertiesProvider.of(context)!.homeContext,
                          context,
                          styleableTextFieldController,
                          imagePathNotifier,
                          topicSelectedNotifier);
                    },
                    icon: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return AppTheme.mainGradient.createShader(bounds);
                      },
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),


                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
