import 'package:socialapp/presentation/widgets/edit_profile/bottom_rounded_appbar.dart';
import 'package:socialapp/utils/import.dart';

import '../profile_and_setting/widgets/collection_tab.dart';
import '../profile_and_setting/widgets/shot_tab.dart';
import 'cubit/Viewing_state.dart';
import 'cubit/viewing_cubit.dart';

class UserViewingProfileScreen extends StatefulWidget {
  final String userId;

  const UserViewingProfileScreen({super.key, required this.userId});

  @override
  State<UserViewingProfileScreen> createState() =>
      _UserViewingProfileScreenState();
}

class _UserViewingProfileScreenState extends State<UserViewingProfileScreen>
    with SingleTickerProviderStateMixin {
  double avatarRadius = 75;
  late double appBarBackgroundHeight = avatarRadius * 2 / 0.6;
  late double appBarContainerHeight = avatarRadius * (1 + 2 / 0.6);
  late double deviceHeight, deviceWidth;

  bool isDrawerOpen = false;

  late TabController _tabController;

  final ValueNotifier<int> _selectedIndexNotifier = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      _onTabChanged();
    });
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
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
  }

  void _onTabChanged() {
    _selectedIndexNotifier.value = _tabController.index;
  }

  void _onTabSelected(int index) {
    _tabController.animateTo(index);
    _selectedIndexNotifier.value = index; // Update ValueNotifier
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ViewingCubit(userId: widget.userId),
      child: Scaffold(
        body: Container(
          color: AppColors.white,
          child: DefaultTabController(
            length: 2,
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
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 40.0, top: 35),
                                    child: IconButton(
                                      onPressed: () {
                                        context.pop();
                                      },
                                        icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30,),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: IntrinsicHeight(
                                    child:
                                        BlocBuilder<ViewingCubit, ViewingState>(
                                            builder: (context, state) {
                                      return Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          (state is ViewingLoaded)
                                              ? state.userModel.tagName
                                              : 'Tag name',
                                          textAlign: TextAlign.center,
                                          style: AppTheme.profileTagStyle,
                                        ),
                                      );
                                    }),
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
                                        BlocBuilder<ViewingCubit, ViewingState>(
                                          builder: (context, state) {
                                            return Align(
                                              child: CircleAvatar(
                                                radius: avatarRadius,
                                                backgroundColor:
                                                    state is ViewingLoaded
                                                        ? Colors.transparent
                                                        : AppColors.roseDragee,
                                                backgroundImage: state
                                                        is ViewingLoaded
                                                    ? CachedNetworkImageProvider(
                                                        state.userModel.avatar)
                                                    : null,
                                                child: state is! ViewingLoaded
                                                    ? Icon(
                                                        Icons.person,
                                                        size: avatarRadius,
                                                        color: Colors
                                                            .grey.shade600,
                                                      )
                                                    : null,
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

                          // Viewing Information
                          IgnorePointer(
                            ignoring: isDrawerOpen,
                            child: BlocBuilder<ViewingCubit, ViewingState>(
                                builder: (context, state) {
                              if (state is ViewingLoaded) {
                                return ViewingInformationBox(
                                  key: ValueKey(state.userModel.id),
                                  userModel: state.userModel,
                                  userFollowers: state.userFollowers,
                                  userFollowings: state.userFollowings,
                                  isFollowed: state.isFollowed,
                                );
                              }
                              // return const Center(child: CircularProgressIndicator(color: AppColors.iris,)
                              else {
                                return const ViewingInformationBox(
                                  userModel: null,
                                  userFollowers: null,
                                  userFollowings: null,
                                  isFollowed: null,
                                );
                              }
                            }),
                          ),

                          // Nested Tab
                          IgnorePointer(
                            ignoring: isDrawerOpen,
                            child: SizedBox(
                              width: deviceWidth * 0.9,
                              child: BlocBuilder<ViewingCubit, ViewingState>(
                                  builder: (context, state) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ProfileTab(
                                      index: 0,
                                      selectedIndexNotifier:
                                          _selectedIndexNotifier,
                                      label: (state is ViewingLoaded)
                                          ? '${state.mediasNumber} Shots'
                                          : '0 Shots',
                                      onTabSelected: _onTabSelected,
                                    ),
                                    // ProfileTab(
                                    //   index: 1,
                                    //   selectedIndexNotifier:
                                    //   _selectedIndexNotifier,
                                    //   label: (state is ProfileLoaded)
                                    //       ? '${state.recordsNumber} Records'
                                    //       : '0 Records',
                                    //   onTabSelected: _onTabSelected,
                                    // ),
                                    ProfileTab(
                                      index: 1,
                                      selectedIndexNotifier:
                                          _selectedIndexNotifier,
                                      label: (state is ViewingLoaded)
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
                    child: BlocBuilder<ViewingCubit, ViewingState>(
                        builder: (context, state) {
                      return TabBarView(
                        controller: _tabController,
                        children: [
                          if (state is ViewingLoaded)
                            ShotTab1(userId: state.userModel.id ?? '')
                          else
                            const Center(
                                child: CircularProgressIndicator(
                                    color: AppColors.iris)),
                          // const ShotTab1(),
                          if (state is ViewingLoaded)
                            CollectionTab1(userId: state.userModel.id ?? '')
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

class ViewingInformationBox extends StatefulWidget {
  final UserModel? userModel;
  final List<String>? userFollowers;
  final List<String>? userFollowings;
  final bool? isFollowed;

  const ViewingInformationBox(
      {super.key,
      required this.userModel,
      required this.userFollowers,
      required this.userFollowings,
      required this.isFollowed});

  @override
  State<ViewingInformationBox> createState() => _ViewingInformationBoxState();
}

class _ViewingInformationBoxState extends State<ViewingInformationBox> with FlashMessage {
  late bool isFollowed;
  late int followersCount;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    isFollowed = widget.isFollowed ?? false;
    followersCount = widget.userFollowers?.length ?? 0;
  }

  void toggleFollow() async {
    if (isFollowed) {
      // Show confirmation dialog before unfollowing
      bool confirmUnfollow = await showDialog(
        context: context,
        builder: (buildContext) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            title: Text('Unfollow ${widget.userModel?.name ?? "this user"}?'),
            content: const Text('Are you sure you want to unfollow this user?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false), // Cancel
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<ViewingCubit>().removeFollowing();
                  showSuccessMessage(context: context, title: 'Unfollowed ${widget.userModel!.name}', );
                  Navigator.of(buildContext).pop(true);
                }, // Confirm
                child: const Text('Unfollow'),
              ),
            ],
          );
        },
      );

      if (!confirmUnfollow) return; // Exit if user cancels
    }else{
      context.read<ViewingCubit>().addFollowing();
      showSuccessMessage(context: context, title: 'Followed ${widget.userModel!.name}', );
    }

    setState(() {
      isFollowed = !isFollowed;
      followersCount += isFollowed ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(
              '${widget.userModel?.name ?? "Name"} ${widget.userModel?.lastName ?? "Last name"}',
              style: AppTheme.blackHeaderStyle),
          const SizedBox(height: 5),
          if ((widget.userModel != null) &&
              (widget.userModel?.location.isNotEmpty ?? false))
            Text(
              widget.userModel!.location,
              style: AppTheme.profileLocationStyle,
            ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.lynxWhite,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: followersCount.toString(),
                        style: AppTheme.profileNumberStyle,
                      ),
                      TextSpan(
                        text: '  Followers',
                        style: AppTheme.profileCasualStyle,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.userFollowings?.length.toString() ?? '0',
                        style: AppTheme.profileNumberStyle,
                      ),
                      TextSpan(
                        text: '  Following',
                        style: AppTheme.profileCasualStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.message_outlined,
                    color: AppColors.goshawkGrey,
                    size: 35,
                  ),
                ),
                SvgPicture.asset(AppIcons.gradientDot),
                IconButton(
                  onPressed: toggleFollow,
                  icon: Image.asset(
                    (isFollowed) ? AppIcons.unfollow : AppIcons.follow,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
