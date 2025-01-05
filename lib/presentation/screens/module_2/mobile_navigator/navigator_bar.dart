// import 'package:custom_navigation_bar/custom_navigation_bar.dart';

import 'package:socialapp/presentation/screens/module_2/discover/discover_screen.dart';
import 'package:socialapp/presentation/screens/module_2/home/mobile_home_screen.dart';
import 'package:socialapp/utils/import.dart';

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
    // NewPostScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<<< HEAD:lib/presentation/screens/module_2/mobile_navigator/navigator_bar.dart
      backgroundColor: Colors.transparent,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: IndexedStack(
        index: _screenIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.lavenderBlueShadow,
========
        backgroundColor: Colors.transparent,
        extendBody: true,
        resizeToAvoidBottomInset: false,
        // body: _screens[_screenIndex],
        body: IndexedStack(
          index: _screenIndex,
          children: _screens,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.lavenderBlueShadow,
>>>>>>>> origin/feature/module2/browse_posts:lib/presentation/widgets/general/navigator_bar.dart
          onPressed: () {
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => const NewPostScreen()),
            // );
          },
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ),
          child: const Icon(
            Icons.add_box,
            color: AppColors.white,
          ),
        ),
<<<<<<<< HEAD:lib/presentation/screens/module_2/mobile_navigator/navigator_bar.dart
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
              icon: Icon(
                Icons.home,
                size: 20,
                color: _screenIndex == 0 ?
                  AppColors.lavenderBlueShadow :
                  AppColors.erieBlack.withOpacity(0.4)),
                onPressed: () {
                  setState(() {
                  _screenIndex = 0;
                  });
                },
              ),
            ),
            Expanded(
              child: IconButton(
              icon: Icon(
                Icons.category_sharp,
                size: 20,
                color: _screenIndex == 1 ?
                  AppColors.lavenderBlueShadow :
                  AppColors.erieBlack.withOpacity(0.4)
========
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
>>>>>>>> origin/feature/module2/browse_posts:lib/presentation/widgets/general/navigator_bar.dart
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
<<<<<<<< HEAD:lib/presentation/screens/module_2/mobile_navigator/navigator_bar.dart
            ),
            const Spacer(),
            Expanded(
              child: IconButton(
              icon: Icon(
                Icons.notifications,
                size: 20,
                color: _screenIndex == 2 ?
                  AppColors.lavenderBlueShadow :
                  AppColors.erieBlack.withOpacity(0.4)

              ),
              onPressed: () {
                setState(() {
                _screenIndex = 2;
                });
              },
              ),
            ),
            Expanded(
              child: IconButton(
              icon: Icon(
                Icons.person,
                size: 20,
                color: _screenIndex == 3 ?
                  AppColors.lavenderBlueShadow :
                  AppColors.erieBlack.withOpacity(0.4)
              ),
              onPressed: () {
                setState(() {
                _screenIndex = 3;
                });
              },
              ),
            ),
          ],
        ),
      )
    );
========
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
        ));
>>>>>>>> origin/feature/module2/browse_posts:lib/presentation/widgets/general/navigator_bar.dart
  }
}
