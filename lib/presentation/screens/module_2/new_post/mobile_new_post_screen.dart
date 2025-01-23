import 'package:socialapp/utils/import.dart';
import 'package:video_compress/video_compress.dart';

import 'cubit/new_post_cubit.dart';
import 'providers/new_post_properties_provider.dart';
import 'widgets/dialog_body_mobile_layout.dart';
import 'widgets/dialog_header.dart';
import 'widgets/styleable_text_field_controller.dart';

class NewPostScreen extends StatelessWidget {
  final BuildContext parentContext;

  const NewPostScreen({super.key, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewPostCubit(),
      child: NewPostBase(parentContext: parentContext),
    );
  }
}

class NewPostBase extends StatefulWidget {
  final BuildContext parentContext;

  const NewPostBase({super.key, required this.parentContext});

  @override
  State<NewPostBase> createState() => _NewPostBaseState();
}

class _NewPostBaseState extends State<NewPostBase> with FlashMessage {
  final double sideWidth = 25;
  final double avatarSize = 45;

  late UserModel currentUser = UserModel.empty();
  late List<TopicModel> topics = [];

  final TextEditingController styleableTextFieldController =
      StyleableTextFieldController(
    styles: TextPartStyleDefinitions(
      definitionList: <TextPartStyleDefinition>[
        TextPartStyleDefinition(
          style: AppTheme.highlightedHashtagStyleMobile,
          pattern: r'(#[a-zA-Z0-9_]+)',
        ),
      ],
    ),
  );

  late ValueNotifier<List<Map<String, dynamic>>> imagePathNotifier =
      ValueNotifier([]);
  late ValueNotifier<List<TopicModel>> topicSelectedNotifier =
      ValueNotifier([]);
  late ValueNotifier<bool> isRecordingMode = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    currentUser = (await context.read<NewPostCubit>().getCurrentUser())!;

    if (currentUser.id == null && context.mounted) {
      context.go(
        '/sign-in',
        extra: true,
      );
    }
  }

  @override
  void dispose() {
    topicSelectedNotifier.dispose();
    imagePathNotifier.dispose();
    styleableTextFieldController.dispose();
    isRecordingMode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NewPostPropertiesProvider(
      newPostProperties: NewPostProperties(
        user: currentUser,
        topics: topics,
        homeContext: context,
      ),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Container(
            decoration: AppTheme.whiteDialogDecoration,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MobileDialogHeader(
                    sideWidth: sideWidth,
                    imagePathNotifier: imagePathNotifier,
                    styleableTextFieldController: styleableTextFieldController,
                    topicSelectedNotifier: topicSelectedNotifier,
                    isRecordingMode: isRecordingMode,
                  ),
                  const Divider(
                    color: AppColors.iris,
                    thickness: 1,
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: MobileDialogBody(
                      avatarSize: avatarSize,
                      styleableTextFieldController:
                          styleableTextFieldController,
                      imagePathNotifier: imagePathNotifier,
                      topicSelectedNotifier: topicSelectedNotifier,
                      isRecordingMode: isRecordingMode,
                    ),
                  ),
                  // Add more widgets as necessary
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
