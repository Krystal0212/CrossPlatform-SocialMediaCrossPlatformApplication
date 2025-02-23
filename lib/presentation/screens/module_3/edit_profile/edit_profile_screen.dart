import '../../../widgets/edit_profile/bottom_rounded_appbar.dart';
import 'cubit/edit_page_cubit.dart';
import 'cubit/edit_page_state.dart';
import 'package:socialapp/utils/import.dart';

class EditProfile extends StatelessWidget {
  final ValueNotifier<UserModel> userDataNotifier;

  const EditProfile({super.key, required this.userDataNotifier});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => EditPageCubit(),
        child: EditProfileBase(
          userDataNotifier: userDataNotifier,
        ));
  }
}

class EditProfileBase extends StatefulWidget {
  final ValueNotifier<UserModel> userDataNotifier;

  const EditProfileBase({super.key, required this.userDataNotifier});

  @override
  State<EditProfileBase> createState() => _EditProfileBaseState();
}

enum ChangeState { noChange, changed, processing }

class _EditProfileBaseState extends State<EditProfileBase>
    with Validator, FlashMessage {
  late TextEditingController nameController;
  late TextEditingController tagNameController;
  late TextEditingController lastNameController;
  late TextEditingController locationController;

  late ValueNotifier<Map<String, dynamic>> avatarMapNotifier;
  late ValueNotifier<ChangeState> changesNotifier;

  late FocusNode nameFocus = FocusNode();
  late FocusNode tagNameFocus = FocusNode();
  late FocusNode lastNameFocus = FocusNode();
  late FocusNode locationFocus = FocusNode();

  late double deviceWidth = 0, deviceHeight = 0;

  final _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    tagNameController = TextEditingController();
    lastNameController = TextEditingController();
    locationController = TextEditingController();
    nameFocus = FocusNode();
    tagNameFocus = FocusNode();
    lastNameFocus = FocusNode();
    locationFocus = FocusNode();

    avatarMapNotifier = ValueNotifier<Map<String, dynamic>>({});
    changesNotifier = ValueNotifier<ChangeState>(ChangeState.noChange);

    final flutterView = PlatformDispatcher.instance.views.first;
    deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    deviceHeight = flutterView.physicalSize.height;
  }

  @override
  void dispose() {
    nameController.dispose();
    tagNameController.dispose();
    lastNameController.dispose();
    locationController.dispose();

    avatarMapNotifier.dispose();
    super.dispose();
  }


  void checkForChanges(UserModel originalUser) {
    bool hasChanges = false;

    if (nameController.text != originalUser.name) {
      hasChanges = true;
    } else if (lastNameController.text != originalUser.lastName) {
      hasChanges = true;
    } else if (locationController.text != originalUser.location) {
      hasChanges = true;
    } else if (avatarMapNotifier.value['localImageData'] != null) {

        hasChanges = true;

    }

    bool isValidated = _formKey.currentState!.validate();

    changesNotifier.value =
    (hasChanges && isValidated) ? ChangeState.changed : ChangeState.noChange;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditPageCubit, EditPageState>(builder: (context, state) {
      if (state is EditPageLoading || state is EditPageInitial) {
        return const Center(child: CircularProgressIndicator());
      } else if (state is EditPageLoaded) {
        final UserModel previousUserData = state.user;
        avatarMapNotifier.value = previousUserData.toMap();

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            child: Column(
              children: [
                HeaderAndAvatar(
                  avatarNotifier: avatarMapNotifier,
                  changesNotifier: changesNotifier,
                  checkAvatarChanged: () => checkForChanges(previousUserData),
                ),

                // TODO: Text fields
                Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextFormField(
                        controller: tagNameController,
                        label: 'Tag Name',
                        hintText: previousUserData.tagName.isNotEmpty
                            ? previousUserData.tagName
                            : 'Your Tag Name',
                        width: deviceWidth * 0.8,
                        focusNode: tagNameFocus,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (value.length > 15) {
                              return AppStrings.tagNameTooLong;
                            }

                            final regex = RegExp(r'^[a-z0-9_]+$');
                            if (!regex.hasMatch(value)) {
                              return AppStrings.invalidTagName;
                            }
                          }

                          return null;
                        },
                        onChanged: (_) => checkForChanges(previousUserData),
                        keyboardType: TextInputType.name,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(nameFocus);
                        },
                      ),
                      const SizedBox(height: 22),
                      AppTextFormField(
                        controller: nameController,
                        label: 'Name',
                        hintText: previousUserData.name.isNotEmpty
                            ? previousUserData.name
                            : 'Name',
                        width: deviceWidth * 0.8,
                        focusNode: nameFocus,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (value.length > 20) {
                              return AppStrings.nameTooLong;
                            }
                            final regex = RegExp(r'^[a-zA-Z_ ]+$');
                            if (!regex.hasMatch(value)) {
                              return AppStrings.invalidName;
                            }
                          }
                          return null;
                        },
                        onChanged: (_) => checkForChanges(previousUserData),
                        keyboardType: TextInputType.text,
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(lastNameFocus);
                        },
                      ),
                      const SizedBox(height: 22),
                      AppTextFormField(
                        controller: lastNameController,
                        label: 'Last Name',
                        hintText: previousUserData.lastName.isNotEmpty
                            ? previousUserData.lastName
                            : 'Last Name',
                        width: deviceWidth * 0.8,
                        focusNode: lastNameFocus,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (value.length > 20) {
                              // First & last names max 30 characters each
                              return AppStrings.nameTooLong;
                            }
                            final regex = RegExp(r'^[a-zA-Z_ ]+$');
                            if (!regex.hasMatch(value)) {
                              return AppStrings.invalidName;
                            }
                          }
                          return null;
                        },
                        onChanged: (_) => checkForChanges(previousUserData),
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(locationFocus);
                        },
                      ),
                      const SizedBox(height: 22),
                      AppTextFormField(
                        controller: locationController,
                        label: 'Location',
                        hintText: previousUserData.location.isNotEmpty
                            ? previousUserData.location
                            : 'Your Location',
                        width: deviceWidth * 0.8,
                        focusNode: locationFocus,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (value.length > 50) {
                              // Location max 50 characters
                              return AppStrings.locationTooLong;
                            }
                            final regex = RegExp(r'^[a-zA-Z_ ]+$');
                            if (!regex.hasMatch(value)) {
                              return AppStrings.invalidName;
                            }
                          }
                          return null;
                        },
                        onChanged: (_) => checkForChanges(previousUserData),
                        onFieldSubmitted: (value) {},
                      ),
                      SizedBox(height: deviceHeight * 0.2)
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: ValueListenableBuilder<ChangeState>(
            valueListenable: changesNotifier,
            builder: (context, noChanges, child) {
              return Container(
                width: deviceWidth * 0.8,
                decoration: (noChanges == ChangeState.noChange)? AppTheme.gradientDisableFabBoxDecoration : AppTheme.gradientFabBoxDecoration,
                child: FloatingActionButton.extended(
                  onPressed: () async {
                    if (noChanges == ChangeState.changed) {
                      UserModel updatedUserData = previousUserData.copyWith();

                      String tagName = tagNameController.text.trim();
                      String newName = nameController.text.trim();
                      String lastname = lastNameController.text.trim();
                      String location = locationController.text.trim();
                      Uint8List? newAvatar =
                          avatarMapNotifier.value['localImageData'];

                      if (tagName.isNotEmpty) {
                        updatedUserData =
                            updatedUserData.copyWith(tagName: tagName);
                      }

                      if (newName.isNotEmpty) {
                        updatedUserData =
                            updatedUserData.copyWith(name: newName);
                      }

                      if (lastname.isNotEmpty) {
                        updatedUserData =
                            updatedUserData.copyWith(lastName: lastname);
                      }

                      if (location.isNotEmpty) {
                        updatedUserData =
                            updatedUserData.copyWith(location: location);
                      }


                      if(avatarMapNotifier.value['isNSFW'] == true){
                        if (!context.mounted) return;
                        showAttentionMessage(
                          context: context,
                          title: 'This image is NSFW, can not set as avatar',
                        );
                        return;
                      }

                      changesNotifier.value = ChangeState.processing;
                      UpdateState updateState = await context
                          .read<EditPageCubit>()
                          .updateCurrentUserData(
                              updatedUserData, previousUserData, newAvatar);

                      if (updateState == UpdateState.success) {
                        if (!context.mounted) return;
                        widget.userDataNotifier.value = updatedUserData;
                        Navigator.of(context).pop();
                      } else if (updateState == UpdateState.tagNameTaken) {
                        if (!context.mounted) return;
                        showAttentionMessage(
                          context: context,
                          title: AppStrings.tagTaken,
                        );
                      }
                    } else {
                      if (!context.mounted) return;
                      showAttentionMessage(
                        context: context,
                        title: AppStrings.noChangeDetected,
                      );
                    }
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  label: Center(
                    child: (noChanges == ChangeState.processing)
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            AppStrings.saveChange,
                            textAlign: TextAlign.center,
                            style: AppTheme.buttonGradientStyle,
                          ),
                  ),
                ),
              );
            },
          ),
        );
      } else {
        return NoUserDataAvailablePlaceholder(width: deviceWidth * 0.9);
      }
    });
  }
}

class HeaderAndAvatar extends StatefulWidget {
  final ValueNotifier<Map<String, dynamic>> avatarNotifier;
  final ValueNotifier<ChangeState> changesNotifier;
  final VoidCallback checkAvatarChanged;

  const HeaderAndAvatar(
      {super.key,
      required this.avatarNotifier,
      required this.checkAvatarChanged,
      required this.changesNotifier});

  @override
  State<HeaderAndAvatar> createState() => _HeaderAndAvatarState();
}

class _HeaderAndAvatarState extends State<HeaderAndAvatar> {
  late double avatarRadius = 90,
      deviceHeight = 0,
      deviceWidth = 0,
      appBarBackgroundHeight = 0,
      appBarContainerHeight = 0;

  @override
  initState() {
    super.initState();
    final flutterView = PlatformDispatcher.instance.views.first;
    deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    deviceHeight = flutterView.physicalSize.height;

    appBarBackgroundHeight = avatarRadius * 2 / 0.8;
    appBarContainerHeight = avatarRadius * (1 + 2 / 0.8);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: appBarContainerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: appBarBackgroundHeight,
              width: deviceWidth,
              child: const BottomRoundedAppBar(
                bannerPath: AppImages.editProfileAppbarBackground,
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.only(top: 40),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ValueListenableBuilder(
                        valueListenable: widget.changesNotifier,
                        builder: (context, changeState, _) {
                          return IconButton(
                            onPressed: () {
                              if (changeState == ChangeState.processing) {
                                return;
                              }
                              context.pop();
                            },
                            icon: const Icon(
                              Icons.arrow_back_sharp,
                              size: 35,
                            ),
                          );
                        }),
                    Text(
                      'Edit profile',
                      textAlign: TextAlign.center,
                      style: AppTheme.headerStyle.copyWith(fontSize: 25),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.arrow_back_sharp,
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: avatarRadius * 2,
              height: avatarRadius * 2,
              child: Stack(
                children: [
                  Align(
                    child: ValueListenableBuilder<Map<String, dynamic>>(
                      valueListenable: widget.avatarNotifier,
                      builder: (context, avatarData, _) {
                        bool isLoading = avatarData['isLoading'] ?? false;
                        if (avatarData['avatar'] != null) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: avatarRadius,
                                backgroundImage: CachedNetworkImageProvider(
                                    avatarData['avatar']),
                              ),
                              if (isLoading)
                                const Positioned.fill(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          );
                        } else if (avatarData['localImageData'] != null) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: avatarRadius * 2,
                                backgroundImage:
                                    MemoryImage(avatarData['localImageData']),
                              ),
                              if (isLoading)
                                const Positioned.fill(
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                            ],
                          );
                        } else {
                          return CircleAvatar(
                            radius: avatarRadius,
                            child: const Icon(Icons.person),
                          );
                        }
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          gradient: AppTheme.mainGradient,
                        ),
                        child: Center(
                          child: IconButton(
                            color: Colors.white,
                            icon: const Icon(Icons.camera),
                            onPressed: () async {
                              context.read<EditPageCubit>().pickImagesByMobile(
                                    widget.avatarNotifier,
                                    context,
                                  );
                              widget.checkAvatarChanged();
                            },
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
