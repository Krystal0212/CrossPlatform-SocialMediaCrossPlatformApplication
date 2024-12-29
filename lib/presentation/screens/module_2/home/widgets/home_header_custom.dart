import 'package:flutter/material.dart';
import 'package:socialapp/utils/import.dart';
import 'package:socialapp/utils/styles/colors.dart';

class HomeHeaderCustom extends StatefulWidget {
  const HomeHeaderCustom({super.key});

  @override
  State<HomeHeaderCustom> createState() => _HomeHeaderCustomState();
}

class _HomeHeaderCustomState extends State<HomeHeaderCustom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 112,
      color: AppColors.white,
      child: const Column(
        children: [
          SearchBar(),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          //   child: Row(
          //     // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: [
          //       Expanded(
          //         flex: 1,
          //         child: SwitchTabButton(tabText: 'Popular', switchTab: popularTabPress),
          //       ),
          //       Expanded(
          //         flex: 1,
          //         child: SwitchTabButton(tabText: 'Trending', switchTab: trendingTabPress),
          //       ),
          //       Expanded(
          //         flex: 1,
          //         child: SwitchTabButton(tabText: 'Following', switchTab: followingTabPress),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  void popularTabPress() {
    if (kDebugMode) {
      print('popular');
    }
  }

  void trendingTabPress() {
    if (kDebugMode) {
      print('trending');
    }
  }

  void followingTabPress() {
    if (kDebugMode) {
      print('following');
    }
  }
}

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
      child: SizedBox(
        height: 36,
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            // hintText: 'Search',
            labelText: 'Search',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          )
        )
      ),
    );
  }
}

class SwitchTabButton extends StatelessWidget {
  SwitchTabButton({super.key, required this.tabText, required this.switchTab});

  String tabText;
  final VoidCallback switchTab;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: switchTab,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        height: 40,
        width: 120,
        child: Center(child: Text(tabText)),
      )
    );
  }
}
