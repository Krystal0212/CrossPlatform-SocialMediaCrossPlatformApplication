import 'package:socialapp/presentation/screens/module_3/profile_and_setting/widgets/information_box.dart';

import 'package:socialapp/presentation/widgets/edit_profile/bottom_rounded_appbar.dart';
import 'package:socialapp/utils/import.dart';

import 'cubit/profile_cubit.dart';
import 'cubit/profile_state.dart';
import 'widgets/collection_tab.dart';
import 'widgets/shot_tab.dart';
import 'widgets/sound_tab.dart';

class ProfilePart extends StatefulWidget {
  const ProfilePart({super.key});

  @override
  State<ProfilePart> createState() => _ProfilePartState();
}

class _ProfilePartState extends State<ProfilePart>
    with SingleTickerProviderStateMixin {
  late double avatarRadius = 75,
      appBarBackgroundHeight = 0,
      appBarContainerHeight = 0,
      xOffset = 0,
      yOffset = 0,
      scaleFactor = 1;

  bool isDrawerOpen = false;

  late TabController _tabController;

  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      _onTabChanged();
    });

    appBarBackgroundHeight = avatarRadius * 2 / 0.6;
    appBarContainerHeight = avatarRadius * (1 + 2 / 0.6);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
  }

  void _onTabChanged() {
    _selectedIndexNotifier.value = _tabController.index;
  }

  void _onTabSelected(int index) {
    _tabController.animateTo(index);
    _selectedIndexNotifier.value = index; // Update ValueNotifier
  }

  void toggleContainer() {
    setState(() {
      if (isDrawerOpen) {
        xOffset = 0;
        yOffset = 0;
        scaleFactor = 1;
        isDrawerOpen = false;
      } else {
        xOffset = 330;
        yOffset = 200;
        scaleFactor = 0.65;
        isDrawerOpen = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: GestureDetector(
        onTap: () {
          if (isDrawerOpen) {
            toggleContainer(); // Tap anywhere to enlarge when smaller
          }
        },
        child: AnimatedContainer(
          curve: Curves.easeIn,
          transform: Matrix4.translationValues(xOffset, yOffset, 0)
            ..scale(scaleFactor)
            ..rotateY(isDrawerOpen ? -0.5 : 0),
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(isDrawerOpen ? 40 : 0.0)),
          child: DefaultTabController(
            length: 3,
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: NestedScrollView(
                physics: isDrawerOpen
                    ? const NeverScrollableScrollPhysics()
                    : const ClampingScrollPhysics(),
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          // AppBar Background
                          SizedBox(
                            height: appBarContainerHeight,
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: SizedBox(
                                    height: appBarBackgroundHeight,
                                    width: deviceWidth,
                                    child: const BottomRoundedAppBar(
                                      bannerPath:
                                          AppImages.editProfileAppbarBackground,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: IntrinsicHeight(
                                    child: Stack(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 56.0),
                                            child: IconButton(
                                              onPressed: () {
                                                if (!isDrawerOpen) {
                                                  // Tap anywhere to enlarge when smaller
                                                  toggleContainer();
                                                }
                                              },
                                              icon: SvgPicture.asset(
                                                AppIcons.setting,
                                                colorFilter:
                                                    const ColorFilter.mode(
                                                  AppColors.white,
                                                  BlendMode.srcIn,
                                                ),
                                                width: 30,
                                                height: 30,
                                              ),
                                            ),
                                          ),
                                        ),
                                    BlocBuilder<ProfileCubit, ProfileState>(
                                      builder: (context, state) {
                                        if (state is ProfileLoaded) {
                                          return StreamBuilder<UserModel?>(
                                            stream: state.userDataStream,
                                            builder: (context, snapshot) {
                                              return Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  snapshot.hasData ? snapshot.data!.tagName : 'Username',
                                                  textAlign: TextAlign.center,
                                                  style: AppTheme.profileTagStyle,
                                                ),
                                              );
                                            },
                                          );
                                        }
                                        return Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Username',
                                            textAlign: TextAlign.center,
                                            style: AppTheme.profileTagStyle,
                                          ),
                                        );
                                      },
                                    )
                                      ],
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: avatarRadius * 2,
                                    height: avatarRadius * 2,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.white,
                                        width: 6.0,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        BlocBuilder<ProfileCubit, ProfileState>(
                                          builder: (context, state) {
                                            if (state is ProfileLoaded) {
                                              return StreamBuilder<UserModel?>(
                                                stream: state.userDataStream,
                                                builder: (context, snapshot) {
                                                  return Align(
                                                    child: CircleAvatar(
                                                      radius: avatarRadius,
                                                      backgroundColor: AppColors.iris,
                                                      backgroundImage: snapshot.hasData
                                                          ? CachedNetworkImageProvider(snapshot.data!.avatar)
                                                          : null,
                                                      child: !snapshot.hasData
                                                          ? Icon(
                                                        Icons.person,
                                                        size: avatarRadius,
                                                        color: Colors.grey.shade600,
                                                      )
                                                          : null,
                                                    ),
                                                  );
                                                },
                                              );
                                            }
                                            return Align(
                                              child: CircleAvatar(
                                                radius: avatarRadius,
                                                backgroundColor: AppColors.roseDragee,
                                                child: Icon(
                                                  Icons.person,
                                                  size: avatarRadius,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Profile Information
                          IgnorePointer(
                            ignoring: isDrawerOpen,
                            child: BlocBuilder<ProfileCubit, ProfileState>(
                              builder: (context, state) {
                                if (state is ProfileLoaded) {
                                  return StreamBuilder<UserModel?>(
                                    stream: state.userDataStream,
                                    builder: (context, snapshot) {
                                      return InformationBox(
                                        userModel: snapshot.data,
                                        userFollowers: state.userFollowers,
                                        userFollowings: state.userFollowings,
                                      );
                                    },
                                  );
                                }
                                return const InformationBox(
                                  userModel: null,
                                  userFollowers: null,
                                  userFollowings: null,
                                );
                              },
                            ),
                          ),

                          // Nested Tab
                          IgnorePointer(
                            ignoring: isDrawerOpen,
                            child: SizedBox(
                              width: deviceWidth * 0.9,
                              child: BlocBuilder<ProfileCubit, ProfileState>(
                                  builder: (context, state) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ProfileTab(
                                      index: 0,
                                      selectedIndexNotifier:
                                          _selectedIndexNotifier,
                                      label: (state is ProfileLoaded)
                                          ? '${state.mediasNumber} Shots'
                                          : '0 Shots',
                                      onTabSelected: _onTabSelected,
                                    ),
                                    ProfileTab(
                                      index: 1,
                                      selectedIndexNotifier:
                                      _selectedIndexNotifier,
                                      label: (state is ProfileLoaded)
                                          ? '${state.recordsNumber} Records'
                                          : '0 Records',
                                      onTabSelected: _onTabSelected,
                                    ),
                                    ProfileTab(
                                      index: 2,
                                      selectedIndexNotifier:
                                          _selectedIndexNotifier,
                                      label: (state is ProfileLoaded)
                                          ? '${state.collectionsNumber} Collections'
                                          : '0 Collections',
                                      onTabSelected: _onTabSelected,
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    )
                  ];
                },
                body: IgnorePointer(
                  ignoring: isDrawerOpen,
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 8, bottom: deviceWidth * 0.15),
                    child: BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, state) {
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          if (state is ProfileLoaded)
                            const ShotTab1()
                          else
                            const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.iris)),

                          if (state is ProfileLoaded)
                            const SoundTab1()
                          else
                            const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.iris)),

                          // const ShotTab1(),
                          if (state is ProfileLoaded)
                            const CollectionTab1()
                          else
                            const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.iris)),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  final int index;
  final ValueNotifier<int> selectedIndexNotifier; // Changed to ValueNotifier
  final String label;
  final Function(int) onTabSelected;

  const ProfileTab({
    super.key,
    required this.index,
    required this.selectedIndexNotifier,
    required this.label,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<int>(
        valueListenable: selectedIndexNotifier,
        builder: (context, selectedIndex, child) {
          return GestureDetector(
            onTap: () => onTabSelected(index),
            child: Container(
              decoration: BoxDecoration(
                color: selectedIndex == index
                    ? AppColors.foundationWhite
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: AppTheme.profileTabStyle.copyWith(
                  fontSize: 18,
                  color: selectedIndex == index
                      ? AppColors.iris
                      : AppColors.noghreiSilver,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
