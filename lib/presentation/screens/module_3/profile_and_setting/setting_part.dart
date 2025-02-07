import 'package:socialapp/utils/import.dart';

import '../change_password/change_password_screen.dart';
import '../create_password/create_password_screen.dart';
import 'cubit/setting_page_cubit.dart';
import 'cubit/setting_page_state.dart';
import 'widgets/rounded_icon_image.dart';

class SettingPart extends StatelessWidget {
  const SettingPart({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingPartBase();
  }
}

class SettingPartBase extends StatefulWidget {
  const SettingPartBase({super.key});

  @override
  State<SettingPartBase> createState() => _SettingPartBaseState();
}

class _SettingPartBaseState extends State<SettingPartBase> with FlashMessage {
  late double deviceWidth;
  late double deviceHeight;
  final Connectivity _connectivity = Connectivity();
  final ValueNotifier<bool> isSetPassword = ValueNotifier<bool>(false);
  final ValueNotifier<UserModel> currentUserNotifier =
      ValueNotifier<UserModel>(UserModel.empty());

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
  }

  @override
  void dispose() {
    super.dispose();
    isSetPassword.dispose();
    currentUserNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
        stream: _connectivity.onConnectivityChanged,
        builder: (context, snapshot) {
          final List<ConnectivityResult> connectivityResult =
              snapshot.data ?? [];
          bool isOffline = connectivityResult.contains(ConnectivityResult.none);

          return BlocProvider(
            create: (context) => SettingPartCubit(),
            child: BlocBuilder<SettingPartCubit, SettingPartState>(
              builder: (providerContext, state) {
                if (state is SettingPartLoaded) {
                  isSetPassword.value = state.isGoogleUserWithoutPassword;
                  currentUserNotifier.value = state.user;
                }

                return Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.only(top: deviceHeight * 0.25),
                    width: deviceWidth * 0.45,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ValueListenableBuilder(
                            valueListenable: isSetPassword,
                            builder: (context, isGoogleUserWithoutPassword, _) {
                              return DrawerItem(
                                title: (isGoogleUserWithoutPassword)
                                    ? AppStrings.setNewPasswordForGG
                                    : AppStrings.changePassword,
                                onPressed: () async {
                                  if (isOffline) {
                                    showNotOnlineMassage(
                                        context: context, description: '');
                                  } else if (isGoogleUserWithoutPassword) {
                                    bool isPasswordJustSet =
                                        await showDialog<bool>(
                                              context: context,
                                              builder: (context) =>
                                                  CreatePasswordScreen(
                                                      parentContext: context),
                                            ) ??
                                            false;

                                    isSetPassword.value = !isPasswordJustSet;
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (context) =>
                                          ChangePasswordScreen(
                                              parentContext: context),
                                    );
                                  }
                                },
                              );
                            }),
                        ValueListenableBuilder<UserModel>(
                            valueListenable: currentUserNotifier,
                            builder: (context, currentUser, _) {
                              return DrawerItem(
                                  title: AppStrings.nsfwFilter,
                                  onPressed: () async {
                                    if (isOffline) {
                                      showNotOnlineMassage(
                                          context: context, description: '');
                                    } else if (state is SettingPartLoaded) {
                                      bool? isOptionSubmit = await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) => NSFWToggleScreen(
                                            parentContext: providerContext,
                                            currentUser: currentUser),
                                      );
                                      if (isOptionSubmit ?? false){
                                        currentUserNotifier.value = currentUser.copyWith(
                                            isNSFWFilterTurnOn: !currentUser.isNSFWFilterTurnOn);
                                      }

                                    }
                                  });
                            }),
                        DrawerItem(
                            title: AppStrings.aboutZineround, onPressed: () {}),
                        DrawerItem(
                            title: AppStrings.termPrivacy, onPressed: () {}),
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: LogOutButton(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}

class DrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const DrawerItem({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: deviceWidth * 0.7,
          height: deviceHeight * 0.06,
          padding: const EdgeInsets.only(left: 16, right: 0, top: 7, bottom: 7),
          decoration: ShapeDecoration(
            color: Colors.white.withOpacity(0.3),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: AppTheme.drawerItemStyle,
              ),
              const Spacer(),
              RoundedTrailingIcon(
                ovalColor: AppTheme.white.withOpacity(0.4),
                iconSize: 36,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NSFWToggleScreen extends StatefulWidget {
  final UserModel currentUser;
  final BuildContext parentContext;

  const NSFWToggleScreen(
      {super.key, required this.currentUser, required this.parentContext});

  @override
  State<NSFWToggleScreen> createState() => _NSFWToggleScreenState();
}

class _NSFWToggleScreenState extends State<NSFWToggleScreen> {
  late ValueNotifier<bool> isNSFWFilterTurnOn;
  late ValueNotifier<bool> isLoading;

  @override
  void initState() {
    super.initState();
    isNSFWFilterTurnOn = ValueNotifier(widget.currentUser.isNSFWFilterTurnOn);
    isLoading = ValueNotifier(false); // Initialize loading state
  }

  @override
  void dispose() {
    isNSFWFilterTurnOn.dispose();
    isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NSFWToggleScreenCubit(),
      child: AlertDialog(
        title: const Text("NSFW Content Filter"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<bool>(
              valueListenable: isNSFWFilterTurnOn,
              builder: (context, value, child) {
                return Column(
                  children: [
                    Text(value
                        ? "NSFW filter is currently ON. Do you want to turn it OFF?"
                        : "NSFW filter is currently OFF. Do you want to turn it ON?"),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(value ? "Turn Off" : "Turn On"),
                      value: value,
                      onChanged: (newValue) {
                        isNSFWFilterTurnOn.value = newValue;
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, loading, child) {
              return AuthElevatedButton(
                width: double.infinity,
                height: 45,
                inputText: AppStrings.submit,
                onPressed: loading
                    ? null
                    : () async {
                  isLoading.value = true; // Set loading to true before operation
                  await context.read<NSFWToggleScreenCubit>().updateNSFWFilter(isNSFWFilterTurnOn.value);
                  isLoading.value = false; // Set loading to false after completion
                  Navigator.pop(context, isNSFWFilterTurnOn.value); // Submit with new value
                },
                isLoading: loading, // Update button state based on loading
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: isLoading,
            builder: (context, loading, child) {
              return AuthElevatedNoBackgroundButton(
                width: double.infinity,
                height: 45,
                onPressed: loading ? null : () => Navigator.pop(context, false),
                inputText: 'Cancel',
                isLoading: loading, // Disable when loading
              );
            },
          ),
        ],
      ),
    );
  }
}