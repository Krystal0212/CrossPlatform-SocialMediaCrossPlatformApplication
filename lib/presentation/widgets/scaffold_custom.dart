import 'package:flutter/material.dart';
import 'package:socialapp/presentation/screens/discover/discover_screen.dart';
import 'package:socialapp/presentation/screens/home/home_screen.dart';
import 'package:socialapp/presentation/screens/notification/notification_screen.dart';
import 'package:socialapp/presentation/screens/profile_and_setting/main_profile_screen.dart';
import 'package:socialapp/utils/styles/colors.dart';

class ScaffoldCustom extends StatefulWidget {
  final Widget body;
  final AppBar? appBar;
  final bool bottomNavBarEnabled;

  const ScaffoldCustom({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavBarEnabled = false,
  });

  @override
  State<ScaffoldCustom> createState() => _ScaffoldCustomState();
}

class _ScaffoldCustomState extends State<ScaffoldCustom> with AutomaticKeepAliveClientMixin<ScaffoldCustom> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: widget.appBar,
      body: widget.body,
      floatingActionButton: FloatingActionButton(
        // backgroundColor: Colors.transparent,
          onPressed: () {},
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
          ),
          child: const Icon(Icons.add,
          ),
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: widget.bottomNavBarEnabled
        ? BottomAppBar(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            height: 76,
            color: Colors.white,
            shape: const CircularNotchedRectangle(),
            notchMargin: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.home, size: 20, color: AppColors.carbon),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.category_sharp, size: 20, color: AppColors.carbon),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DiscoverScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.notifications, size: 20, color: AppColors.carbon),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationScreen())
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.person, size: 20, color: AppColors.carbon),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfileScreen())
                    );
                  },
                ),
              ],
            ),
          )
        : null, // No bottom navigation if it's not enabled
    );
  }
  @override
  bool get wantKeepAlive => true;
}
