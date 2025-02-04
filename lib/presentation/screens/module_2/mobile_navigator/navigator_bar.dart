import 'package:socialapp/utils/import.dart';

import 'providers/mobile_navigator_provider.dart';

class CustomNavigatorBar extends StatefulWidget {
  const CustomNavigatorBar({super.key});

  @override
  State<CustomNavigatorBar> createState() => _CustomNavigatorBarState();
}

class _CustomNavigatorBarState extends State<CustomNavigatorBar> {
  int _screenIndex = 0;

  final List<Widget> _screens = [
    const MobileHomeScreen(),
    const DiscoverScreen(),
    const NotificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MobileNavigatorPropertiesProvider(
      mobileNavigatorProperties: MobileNavigatorProperties(
          navigateToCurrentUserProfile: () {
            setState(() {
              _screenIndex = 3;
            });
          },
          navigateToOtherUserProfile: (String userId) {
             Navigator.of(context).push(MaterialPageRoute(builder: (context) {
               return UserViewingProfileScreen(userId: userId,);
             }));
          }),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          resizeToAvoidBottomInset: false,
          body: IndexedStack(
            index: _screenIndex,
            children: _screens,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.lavenderBlueShadow,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return NewPostScreen(
                  parentContext: context,
                );
              }));
              // context.go('/new-post');
            },
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
            ),
            child: const Icon(
              Icons.add_box,
              color: AppColors.white,
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 76,
            color: AppColors.white,
            shape: const CircularNotchedRectangle(),
            // elevation: 0,
            notchMargin: 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.home,
                        size: 20,
                        color: _screenIndex == 0
                            ? AppColors.lavenderBlueShadow
                            : AppColors.erieBlack.withOpacity(0.4)),
                    onPressed: () {
                      setState(() {
                        _screenIndex = 0;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.category_sharp,
                        size: 20,
                        color: _screenIndex == 1
                            ? AppColors.lavenderBlueShadow
                            : AppColors.erieBlack.withOpacity(0.4)),
                    onPressed: () {
                      setState(() {
                        _screenIndex = 1;
                      });
                    },
                  ),
                ),
                const Spacer(),
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.notifications,
                        size: 20,
                        color: _screenIndex == 2
                            ? AppColors.lavenderBlueShadow
                            : AppColors.erieBlack.withOpacity(0.4)),
                    onPressed: () {
                      setState(() {
                        _screenIndex = 2;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: IconButton(
                    icon: Icon(Icons.person,
                        size: 20,
                        color: _screenIndex == 3
                            ? AppColors.lavenderBlueShadow
                            : AppColors.erieBlack.withOpacity(0.4)),
                    onPressed: () {
                      setState(() {
                        _screenIndex = 3;
                      });
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
