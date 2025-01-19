import 'package:socialapp/utils/import.dart';

import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import 'home_appbar_search_bar.dart';
import 'home_appbar_segmented_tab_controller.dart';

class HomeScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double deviceWidth;

  const HomeScreenAppBar({
    required this.deviceWidth,
    super.key,
  });

  bool get isCompactView => deviceWidth < 680;

  @override
  Widget build(BuildContext context) {
    final double sidePartWidth = deviceWidth * 0.28;
    final double searchBarWidth = deviceWidth * 0.77;

    final double paddingHorizontal = deviceWidth < 1200 && !(deviceWidth < 680)
        ? 30
        : deviceWidth < 680
            ? 25
            : 60;

    return AppBar(
      backgroundColor: AppColors.white,
      automaticallyImplyLeading: false,
      flexibleSpace: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLeftSection(context, sidePartWidth, searchBarWidth),
                if (deviceWidth >= 680 && deviceWidth < 1200)
                  _buildSegmentedTabControl(230),
                if (deviceWidth >= 1200) _buildSegmentedTabControl(400),
                SizedBox(
                  width: isCompactView ? deviceWidth * 0.08 : sidePartWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (deviceWidth >= 1200)
                        ElevatedButton.icon(
                          style: AppTheme.actionSignUpButtonStyle,
                          icon: Image.asset(AppIcons.signUp,
                              width: 20, height: 20),
                          label: Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              AppStrings.signUp,
                              textAlign: TextAlign.center,
                              style: AppTheme.signInWhiteText,
                            ),
                          ),
                          onPressed: () => context.go('/sign-up'),
                        ),
                      if (!(deviceWidth < 680))
                        SizedBox(width: deviceWidth * 0.01),
                      (!(deviceWidth < 680))
                          ? ElevatedButton.icon(
                              style: AppTheme.actionSignInButtonStyle,
                              icon: Image.asset(AppIcons.signIn,
                                  width: 20, height: 20),
                              label: Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: Text(
                                  AppStrings.signIn,
                                  textAlign: TextAlign.center,
                                  style: AppTheme.signInWhiteText,
                                ),
                              ),
                              onPressed: () => context.go('/sign-in'),
                            )
                          : SizedBox(
                              height: isCompactView
                                  ? deviceWidth * 0.08
                                  : sidePartWidth,
                              width: isCompactView
                                  ? deviceWidth * 0.08
                                  : sidePartWidth,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: AppTheme.actionNoEffectCircleButtonStyle
                                    .copyWith(
                                        backgroundColor:
                                            const WidgetStatePropertyAll(
                                                AppColors.systemShockBlue)),
                                child: Image.asset(
                                  AppIcons.userSignIn,
                                  width: 25,
                                  height: 25,
                                ),
                              )),
                      if (deviceWidth >= 680) const SizedBox(width: 10),
                      if (deviceWidth >= 1200)
                        ElevatedButton(
                          onPressed: () {},
                          style: AppTheme.actionNoEffectCircleButtonStyle,
                          child: SvgPicture.asset(AppIcons.threeDots,
                              width: 25, height: 25),
                        ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
      bottom: deviceWidth < 680
          ? PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: SizedBox(
                  height: 35,
                  child: SegmentedTabControl(
                    splashColor: Colors.transparent,
                    tabTextColor: AppColors.iris,
                    selectedTabTextColor: AppColors.white,
                    squeezeIntensity: 2.0,
                    indicatorPadding: deviceWidth < 1200
                        ? EdgeInsets.zero
                        : const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 5),
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
                      SegmentTab(
                        label: 'Trending',
                        color: AppColors.officeNeonLight,
                        backgroundColor:
                            AppColors.officeNeonLight.withOpacity(0.1),
                      ),
                      SegmentTab(
                        label: 'Following',
                        color: AppColors.limeShot,
                        backgroundColor: AppColors.limeShot.withOpacity(0.1),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildLeftSection(
      BuildContext context, double sidePartWidth, double searchBarWidth) {
    return SizedBox(
      width: isCompactView ? searchBarWidth : sidePartWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (deviceWidth >= 1200)
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
            searchBarWidth: isCompactView
                ? searchBarWidth
                : deviceWidth < 1200
                    ? sidePartWidth
                    : sidePartWidth - 55 - deviceWidth * 0.015,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabControl(double width) {
    return Container(
      width: width,
      height: kToolbarHeight - 15,
      decoration: BoxDecoration(
        color: AppColors.tropicalBreeze,
        borderRadius: BorderRadius.circular(10),
      ),
      child: SegmentedTabControl(
        splashColor: Colors.transparent,
        tabTextColor: AppColors.iris,
        selectedTabTextColor: AppColors.white,
        squeezeIntensity: 2.0,
        indicatorPadding: deviceWidth < 1200
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(
            vertical: 5, horizontal: 5),
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
          SegmentTab(
            label: 'Trending',
            color: AppColors.officeNeonLight,
            backgroundColor:
            AppColors.officeNeonLight.withOpacity(0.1),
          ),
          SegmentTab(
            label: 'Following',
            color: AppColors.limeShot,
            backgroundColor: AppColors.limeShot.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (deviceWidth < 680 ? 60 : 0));
}
