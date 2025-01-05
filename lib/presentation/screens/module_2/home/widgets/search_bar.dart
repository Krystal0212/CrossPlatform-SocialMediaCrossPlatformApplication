import 'package:socialapp/utils/import.dart';

class CustomSearchBar extends StatefulWidget {
  final double searchBarWidth;

  const CustomSearchBar({super.key, required this.searchBarWidth});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController searchController;
  late double deviceWidth, searchBarWidth;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    deviceWidth = MediaQuery.of(context).size.width;
    searchBarWidth = widget.searchBarWidth;
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
          height: 46,
          width: searchBarWidth,
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search',
              prefixIcon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SvgPicture.asset(
                  AppIcons.search,
                  fit: BoxFit.contain,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ));
  }
}
