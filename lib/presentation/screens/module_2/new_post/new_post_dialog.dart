import 'package:socialapp/presentation/screens/module_2/new_post/cubit/new_post_cubit.dart';
import 'package:socialapp/presentation/screens/module_2/new_post/providers/new_post_properties_provider.dart';
import 'package:socialapp/presentation/screens/module_2/new_post/widgets/dialog_body.dart';
import 'package:socialapp/presentation/screens/module_2/new_post/widgets/dialog_header.dart';

import 'package:socialapp/utils/import.dart';

class CreateNewPostDialogContent extends StatefulWidget {
  final UserModel currentUser;

  const CreateNewPostDialogContent({super.key, required this.currentUser});

  @override
  State<CreateNewPostDialogContent> createState() =>
      _CreateNewPostDialogContentState();
}

class _CreateNewPostDialogContentState
    extends State<CreateNewPostDialogContent> {
  final double sideWidth = 25;
  final double avatarSize = 45;

  late double deviceWidth, deviceHeight, contentInsertWidth;
  late bool isCompactView, isMediumView, isLargeView;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;

    isCompactView = deviceWidth < 680;
    isMediumView = deviceWidth >= 680 && deviceWidth < 1200;
    isLargeView = deviceWidth >= 1200;

    double contentWidthFactor = (isLargeView) ? 0.45 : 0.82;
    contentInsertWidth = deviceWidth * contentWidthFactor;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewPostCubit(),
      child: NewPostPropertiesProvider(
        newPostProperties: NewPostProperties(
            user: widget.currentUser,),
        child: Dialog(
          insetPadding: AppTheme.bottomDialogPaddingEdgeInsets(deviceHeight),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            width: contentInsertWidth,
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.whiteDialogDecoration,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogHeader(sideWidth: sideWidth),
                const SizedBox(height: 14),
                const Divider(
                  color: AppColors.iris,
                  thickness: 1,
                ),
                const SizedBox(height: 6),
                DialogBody(
                  avatarSize: avatarSize,
                  insertBoxWidth:
                      (isLargeView) ? deviceWidth * 0.32 : deviceWidth * 0.45,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
