import 'package:socialapp/utils/import.dart';

class CustomSearchBar extends StatefulWidget {
  final double searchBarWidth, searchBarHeight;
  final Function(String) onSearchDebounce;
  final Duration debounceDuration;
  final String? label;
  final EdgeInsets? padding;

  const CustomSearchBar({
    super.key,
    required this.searchBarWidth,
    required this.searchBarHeight,
    required this.onSearchDebounce,
    this.debounceDuration = const Duration(milliseconds: 500), this.label, this.padding
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController searchController;
  late double deviceWidth, searchBarWidth;

  Timer? _debounceTimer; // Timer for debounce

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    searchController.addListener(_onSearchTextChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceWidth = MediaQuery.of(context).size.width;
    searchBarWidth = widget.searchBarWidth;
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchTextChanged);
    searchController.dispose();
    _debounceTimer?.cancel(); // Cancel any active debounce timer
    super.dispose();
  }

  // Debounce logic for search text changes
  void _onSearchTextChanged() {
    final query = searchController.text;

    // Cancel any existing debounce timer
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    // Start a new debounce timer
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearchDebounce(query); // Trigger the search callback
    });
  }



  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.fromLTRB(0, 12, 0, 12),
      child: SizedBox(
        height: widget.searchBarHeight,
        width: searchBarWidth,
        child: TextField(
          controller: searchController,
          decoration: InputDecoration(
            labelText: widget.label ?? 'Search',
              contentPadding: EdgeInsets.only(
                bottom: widget.searchBarHeight / 2,  // HERE THE IMPORTANT PART
              ),
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
      ),
    );
  }
}