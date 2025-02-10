import 'package:socialapp/utils/import.dart';

import '../../new_post/website_new_post_dialog.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../providers/home_properties_provider.dart';
import 'home_appbar_segmented_tab_controller.dart';

class HomeScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double deviceWidth;
  final ValueNotifier<UserModel?> currentUserNotifier;
  final TabController tabController;

  const HomeScreenAppBar({
    required this.deviceWidth,
    super.key,
    required this.currentUserNotifier,
    required this.tabController,
  });

  bool get isCompactView => deviceWidth < 680;

  bool get isMediumView => deviceWidth >= 680 && deviceWidth < 1200;

  bool get isLargeView => deviceWidth >= 1200;

  @override
  Widget build(BuildContext context) {
    final double sidePartWidth = deviceWidth * 0.27;

    final double compactSearchBarWidth = deviceWidth * 0.65;
    final double compactActionButtonsWidth = deviceWidth * 0.25;

    double paddingHorizontal, controlWidth;
    double controlHeight = kToolbarHeight - 15;

    if (isMediumView) {
      paddingHorizontal = 30;
      controlWidth = 230;
    } else if (isCompactView) {
      paddingHorizontal = 18;
      controlWidth = deviceWidth;
      controlHeight = 35;
    } else {
      paddingHorizontal = 30;
      controlWidth = 400;
    }

    return ValueListenableBuilder<UserModel?>(
      valueListenable: currentUserNotifier,
      builder: (context, currentUser, _) {
        return AppBar(
          backgroundColor: AppColors.white,
          automaticallyImplyLeading: false,
          flexibleSpace: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
                child: Stack(
                  children: [
                    // Left Section (centered horizontally at the top)
                    Align(
                      alignment:
                          isCompactView ? Alignment.topLeft : Alignment.center,
                      child: LeftSection(
                        deviceWidth: deviceWidth,
                        sidePartWidth: sidePartWidth,
                        searchBarWidth: compactSearchBarWidth,
                        sectionWidth: isCompactView
                            ? compactSearchBarWidth
                            : sidePartWidth,
                        isCompactView: isCompactView,
                        isLargeView: isLargeView,
                      ),
                    ),

                    // Segmented Tab Control (centered horizontally)
                    if (isMediumView || isLargeView)
                      Align(
                        alignment: Alignment.center,
                        child: HomeAppBarSegmentedTabControl(
                          deviceWidth: deviceWidth,
                          controlWidth: controlWidth,
                          controlHeight: controlHeight,
                          isCompactView: isCompactView,
                          tabController: tabController,
                        ),
                      ),

                    // Action Buttons (centered horizontally at the bottom)
                    Align(
                      alignment:
                          isCompactView ? Alignment.topRight : Alignment.center,
                      child: HomeAppBarActionButtons(
                        rightWidth: isCompactView
                            ? compactActionButtonsWidth
                            : sidePartWidth,
                        deviceWidth: deviceWidth,
                        isCompactView: isCompactView,
                        currentUser: currentUser,
                        isLargeView: isLargeView,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          bottom: isCompactView
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(40),
                  child: HomeAppBarSegmentedTabControl(
                    deviceWidth: deviceWidth,
                    controlWidth: controlWidth,
                    controlHeight: controlHeight,
                    isCompactView: isCompactView,
                    tabController: tabController,
                  ),
                )
              : null,
        );
      },
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (deviceWidth < 680 ? 60 : 0));
}

class LeftSection extends StatelessWidget {
  final double deviceWidth, sectionWidth, sidePartWidth, searchBarWidth;
  final bool isCompactView, isLargeView;


  LeftSection({
    required this.deviceWidth,
    required this.sidePartWidth,
    required this.searchBarWidth,
    super.key,
    required this.sectionWidth,
    required this.isCompactView,
    required this.isLargeView,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController searchController = HomePropertiesProvider.of(context)!.searchController;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (isLargeView)
          Row(
            children: [
              SizedBox(
                width: 55,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  style: AppTheme.navigationLogoButtonStyle,
                  child: Image.asset(AppImages.logo, fit: BoxFit.cover),
                ),
              ),
              SizedBox(width: deviceWidth * 0.015),
            ],
          ),
        CustomSearchBar(
          controller: searchController,
          searchBarHeight: 46,
          searchBarWidth: isCompactView
              ? searchBarWidth
              : !isLargeView
                  ? sidePartWidth
                  : sidePartWidth - 55 - deviceWidth * 0.015,
          onSearchDebounce: (String) {},
        ),
      ],
    );
  }
}

class HomeAppBarSegmentedTabControl extends StatelessWidget {
  final double deviceWidth, controlWidth, controlHeight;
  final bool isCompactView;
  final TabController tabController;

  const HomeAppBarSegmentedTabControl({
    super.key,
    required this.deviceWidth,
    required this.controlWidth,
    required this.controlHeight,
    required this.isCompactView,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<bool> isSearchHiddenNotifier = HomePropertiesProvider.of(context)!.isSearchHiddenNotifier;

    return Padding(
      padding:
          (isCompactView) ? const EdgeInsets.all(8) : const EdgeInsets.all(0),
      child: Container(
        width: controlWidth,
        height: controlHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: ValueListenableBuilder(
            valueListenable: isSearchHiddenNotifier,
            builder: (context, isHidden, _) {
            return SegmentedTabControl(
              controller: tabController,
              splashColor: Colors.transparent,
              tabTextColor: AppColors.iris,
              selectedTabTextColor: AppColors.white,
              squeezeIntensity: 2.0,
              textStyle: AppTheme.boldTextStyle,
              selectedTextStyle: AppTheme.boldTextStyle,
              indicatorPadding: isCompactView
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
              barDecoration: const BoxDecoration(
                color: AppColors.tropicalBreeze,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              tabs: [
                SegmentTab(
                  label: 'Explore',
                  color: AppColors.bneiBrakBay,
                  backgroundColor: AppColors.bneiBrakBay.withOpacity(0.1),
                ),
                isHidden
                    ? SegmentTab(
                  label: 'Following',
                  color: AppColors.bneiBrakBay,
                  backgroundColor: AppColors
                      .bneiBrakBay
                      .withOpacity(0.1),
                )
                    : SegmentTab(
                  label: 'Result',
                  color: AppColors.lightIris,
                  backgroundColor: AppColors
                      .lightIris
                      .withOpacity(0.1),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}

class HomeAppBarActionButtons extends StatelessWidget {
  final double rightWidth, deviceWidth;
  final bool isCompactView, isLargeView;
  final UserModel? currentUser;

  final double avatarRadius = 50;

  const HomeAppBarActionButtons({
    super.key,
    required this.rightWidth,
    required this.deviceWidth,
    required this.isCompactView,
    required this.currentUser,
    required this.isLargeView,
  });

  @override
  Widget build(BuildContext homeContext) {
    final bool showSignUp = isLargeView && currentUser == null;
    final bool showSignInFull = currentUser == null && !isCompactView;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (currentUser != null) ...[
            if (isLargeView) ...[
              IconElevatedButton(
                style: AppTheme.actionSignInButtonStyle,
                icon: SvgPicture.asset(AppIcons.createNewPost,
                    width: 20, height: 20),
                label: AppStrings.createNewPost,
                textStyle: AppTheme.signInWhiteText,
                onPressed: () {
                  showDialog(
                    context: homeContext,
                    builder: (BuildContext context) {
                      return CreateNewPostDialogContent(
                        currentUser: currentUser!,
                        homeContext: context,
                      );
                    },
                  );
                },
              ),
              const SizedBox(
                width: 20,
              ),
            ] else ...[
              CircularIconButton(
                icon: SvgPicture.asset(AppIcons.createNewPost, width: 46),
                onPressed: () {
                  showDialog(
                    context: homeContext,
                    builder: (BuildContext context) {
                      return CreateNewPostDialogContent(
                        currentUser: currentUser!,
                        homeContext: homeContext,
                      );
                    },
                  );
                },
              ),
            ],
            SizedBox(
              width: 46,
              height: 46,
              child: CircleAvatar(
                radius: 17,
                backgroundImage: CachedNetworkImageProvider(currentUser!.avatar,
                    maxWidth: 46, maxHeight: 46),
              ),
            ),
          ],
          if (showSignUp)
            ElevatedButton.icon(
              style: AppTheme.actionSignUpButtonStyle,
              icon: Image.asset(AppIcons.signUp, width: 20, height: 20),
              label: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  AppStrings.signUp,
                  textAlign: TextAlign.center,
                  style: AppTheme.signInWhiteText,
                ),
              ),
              onPressed: () => homeContext.go('/sign-up'),
            ),
          if (showSignInFull) SizedBox(width: deviceWidth * 0.01),
          if (currentUser == null)
            (isCompactView)
                ? SizedBox(
                    height: rightWidth,
                    width: rightWidth,
                    child: ElevatedButton(
                      onPressed: () => homeContext.go('/sign-in'),
                      style: AppTheme.actionNoEffectCircleButtonStyle.copyWith(
                        backgroundColor: const WidgetStatePropertyAll(
                          AppColors.systemShockBlue,
                        ),
                      ),
                      child: Image.asset(AppIcons.userSignIn,
                          width: 25, height: 25),
                    ),
                  )
                : IconElevatedButton(
                    style: AppTheme.actionSignInButtonStyle,
                    icon: Image.asset(AppIcons.signIn, width: 20, height: 20),
                    label: AppStrings.signIn,
                    textStyle: AppTheme.signInWhiteText,
                    onPressed: () => homeContext.go('/sign-in'),
                  ),
          if (!isCompactView) const SizedBox(width: 10),
          if (isLargeView)
            PopupMenuButton<String>(
              color: AppTheme.white,
              icon: SvgPicture.asset(AppIcons.threeDots, height: 30),
              offset: const Offset(0, kToolbarHeight),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: AppStrings.about,
                  child: IconElevatedButton(
                    style: AppTheme.navigationIconButtonStyle,
                    icon: const Icon(
                      Icons.social_distance,
                      color: AppColors.dynamicBlack,
                    ),
                    label: AppStrings.about,
                    textStyle: AppTheme.blackUsernameStyle,
                    onPressed: () => context.go('/sign-in'),
                  ),
                ),
                PopupMenuItem(
                  value: AppStrings.term,
                  child: IconElevatedButton(
                    style: AppTheme.navigationIconButtonStyle,
                    icon: const Icon(
                      Icons.earbuds,
                      color: AppColors.dynamicBlack,
                    ),
                    label: AppStrings.term,
                    textStyle: AppTheme.blackUsernameStyle,
                    onPressed: () {},
                  ),
                ),
                if (currentUser != null)
                  PopupMenuItem(
                    value: AppStrings.signOut,
                    child: IconElevatedButton(
                      style: AppTheme.navigationIconButtonStyle,
                      icon: const Icon(
                        Icons.logout,
                        color: AppColors.dynamicBlack,
                      ),
                      label: AppStrings.signOut,
                      textStyle: AppTheme.blackUsernameStyle,
                      onPressed: () {
                        context.read<HomeCubit>().logout();
                        context.go('/sign-in');
                      },
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
