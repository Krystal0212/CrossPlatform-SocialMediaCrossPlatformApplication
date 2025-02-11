import 'package:socialapp/utils/import.dart';

class CustomSearchBar extends StatefulWidget {
  final double searchBarWidth, searchBarHeight;
  final Function(String) onSearchDebounce;
  final Duration debounceDuration;
  final String? label;
  final EdgeInsets? padding;
  final TextEditingController? controller;  // Accept external controller


  const CustomSearchBar({
    super.key,
    required this.searchBarWidth,
    required this.searchBarHeight,
    required this.onSearchDebounce,
    this.debounceDuration = const Duration(milliseconds: 500), this.label, this.padding, this.controller
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController searchController;
  late double searchBarWidth;
  Timer? _debounceTimer;
  String? _previousQuery; // Track the last searched text

  @override
  void initState() {
    super.initState();
    searchController = widget.controller ?? TextEditingController();
    searchController.addListener(_onSearchTextChanged);
    searchBarWidth = widget.searchBarWidth;
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchTextChanged);
    if (widget.controller == null) {
      searchController.dispose();
    }
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchTextChanged() {
    final query = searchController.text.trim();

    // Check if the query is the same as before
    if (_previousQuery == query) {
      return; // Do nothing if the text hasn't changed
    }

    _previousQuery = query; // Update previous query

    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onSearchDebounce(query);
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
            labelStyle: AppTheme.blackUsernameMobileStyle.copyWith(
              color: AppColors.trolleyGrey,
            ),
            contentPadding: EdgeInsets.only(
              bottom: widget.searchBarHeight / 2,
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
