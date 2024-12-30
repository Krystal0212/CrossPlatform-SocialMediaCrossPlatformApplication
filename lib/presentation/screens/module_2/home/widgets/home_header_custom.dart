import 'package:socialapp/utils/import.dart';

import 'search_bar.dart';

class HomeHeaderCustom extends StatefulWidget {
  const HomeHeaderCustom({super.key});

  @override
  State<HomeHeaderCustom> createState() => _HomeHeaderCustomState();
}

class _HomeHeaderCustomState extends State<HomeHeaderCustom> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: const CustomSearchBar(),
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


class SwitchTabButton extends StatelessWidget {
  const SwitchTabButton({super.key, required this.tabText, required this.switchTab});

  final String tabText;
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
