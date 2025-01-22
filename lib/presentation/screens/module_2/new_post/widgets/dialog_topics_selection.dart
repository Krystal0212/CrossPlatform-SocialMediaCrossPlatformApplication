import 'package:socialapp/utils/import.dart';

class TopicChipSelector extends StatefulWidget {
  final List<TopicModel> topics;
  final ValueNotifier<List<TopicModel>> topicSelectedNotifier;
  final double searchBarWidth, searchBarHeight;
  final TextStyle? chipTextStyle;

  const TopicChipSelector(
      {super.key,
      required this.topics,
      required this.topicSelectedNotifier,
      required this.searchBarWidth,
      required this.searchBarHeight,
      this.chipTextStyle});

  @override
  State<TopicChipSelector> createState() => _TopicChipSelectorState();
}

class _TopicChipSelectorState extends State<TopicChipSelector> {
  final ValueNotifier<List<TopicModel>> filteredTopics =
      ValueNotifier<List<TopicModel>>([]);
  final TextEditingController searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    filteredTopics.value = List.from(widget.topics);
    searchController.addListener(_filterTopics);
  }

  @override
  void dispose() {
    // searchController.dispose();
    filteredTopics.dispose();
    super.dispose();
  }

  void _filterTopics() {
    final query = searchController.text.toLowerCase();
    filteredTopics.value = widget.topics
        .where((topic) =>
            !widget.topicSelectedNotifier.value.contains(topic) &&
            topic.name.toLowerCase().contains(query))
        .toList();
  }

  void _selectTopic(TopicModel topic) {
    if (widget.topicSelectedNotifier.value.length < 5) {
      widget.topicSelectedNotifier.value =
          List.from(widget.topicSelectedNotifier.value)..add(topic);
      filteredTopics.value = List.from(filteredTopics.value)..remove(topic);
    }
  }

  void _deselectTopic(TopicModel topic) {
    widget.topicSelectedNotifier.value =
        List.from(widget.topicSelectedNotifier.value)..remove(topic);
    if (topic.name
        .toLowerCase()
        .contains(searchController.text.toLowerCase())) {
      filteredTopics.value = List.from(filteredTopics.value)..add(topic);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<List<TopicModel>>(
          valueListenable: widget.topicSelectedNotifier,
          builder: (context, selected, _) {
            return Wrap(
              spacing: 8.0,
              children: selected.map((topic) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Chip(
                    label: (widget.chipTextStyle != null)
                        ? Text(
                            topic.name,
                            style: widget.chipTextStyle,
                          )
                        : Text(topic.name),
                    onDeleted: () => _deselectTopic(topic),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 10.0),
        CustomSearchBar(
          padding: (kIsWeb) ? null : const EdgeInsets.all(0),
          searchBarWidth: widget.searchBarWidth,
          searchBarHeight: widget.searchBarHeight,
          label: AppStrings.searchTopics,
          onSearchDebounce: (text) async {
            if (text.isEmpty ) {
              filteredTopics.value = List.from(widget.topics);
              return;
            }
            try {
              final result = await serviceLocator<FirestoreService>()
                  .fetchTopicsByField(widget.topicSelectedNotifier.value, text);

                filteredTopics.value = result;

            } catch (e) {
              if (kDebugMode) {
                print("Error fetching topics: $e");
              }
              filteredTopics.value = List.from(widget.topics);
            }
          },
        ),
        ValueListenableBuilder<List<TopicModel>>(
          valueListenable: filteredTopics,
          builder: (context, unselected, _) {
            return Wrap(
              spacing: 8.0,
              children: unselected.map((topic) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: ActionChip(
                    backgroundColor: AppColors.lavenderMist,
                    label: (widget.chipTextStyle != null)
                        ? Text(
                      topic.name,
                      style: widget.chipTextStyle,
                    )
                        : Text(topic.name),
                    onPressed: () => _selectTopic(topic),

                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// class MobileTopicChipSelector extends StatefulWidget {
//   final List<TopicModel> topics;
//   final ValueNotifier<List<TopicModel>> topicSelectedNotifier;
//   final double searchBarWidth, searchBarHeight;
//   final TextStyle? chipTextStyle;
//
//   const MobileTopicChipSelector(
//       {super.key,
//         required this.topics,
//         required this.topicSelectedNotifier,
//         required this.searchBarWidth,
//         required this.searchBarHeight,
//         this.chipTextStyle});
//
//   @override
//   State<MobileTopicChipSelector> createState() => _MobileTopicChipSelectorState();
// }
//
// class _MobileTopicChipSelectorState extends State<MobileTopicChipSelector> {
//   final ValueNotifier<List<TopicModel>> filteredTopics =
//   ValueNotifier<List<TopicModel>>([]);
//   final TextEditingController searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     filteredTopics.value = List.from(widget.topics);
//     searchController.addListener(_filterTopics);
//   }
//
//   @override
//   void dispose() {
//     searchController.dispose();
//     filteredTopics.dispose();
//     super.dispose();
//   }
//
//   void _filterTopics() {
//     final query = searchController.text.toLowerCase();
//     filteredTopics.value = widget.topics
//         .where((topic) =>
//     !widget.topicSelectedNotifier.value.contains(topic) &&
//         topic.name.toLowerCase().contains(query))
//         .toList();
//   }
//
//   void _selectTopic(TopicModel topic) {
//     if (widget.topicSelectedNotifier.value.length < 5) {
//       widget.topicSelectedNotifier.value =
//       List.from(widget.topicSelectedNotifier.value)..add(topic);
//       filteredTopics.value = List.from(filteredTopics.value)..remove(topic);
//     }
//   }
//
//   void _deselectTopic(TopicModel topic) {
//     widget.topicSelectedNotifier.value =
//     List.from(widget.topicSelectedNotifier.value)..remove(topic);
//     if (topic.name
//         .toLowerCase()
//         .contains(searchController.text.toLowerCase())) {
//       filteredTopics.value = List.from(filteredTopics.value)..add(topic);
//     }
//   }
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ValueListenableBuilder<List<TopicModel>>(
//           valueListenable: widget.topicSelectedNotifier,
//           builder: (context, selected, _) {
//             return Wrap(
//               spacing: 8.0,
//               children: selected.map((topic) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 5),
//                   child: Chip(
//                     label: (widget.chipTextStyle != null)
//                         ? Text(
//                       topic.name,
//                       style: widget.chipTextStyle,
//                     )
//                         : Text(topic.name),
//                     onDeleted: () => _deselectTopic(topic),
//                   ),
//                 );
//               }).toList(),
//             );
//           },
//         ),
//         const SizedBox(height: 10.0),
//         Padding(
//           padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
//           child: SizedBox(
//             height: widget.searchBarHeight,
//             width: widget.searchBarWidth,
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 labelText: AppStrings.searchTopics,
//                 contentPadding: EdgeInsets.only(
//                   bottom: widget.searchBarHeight / 2,  // HERE THE IMPORTANT PART
//                 ),
//                 prefixIcon: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: SvgPicture.asset(
//                     AppIcons.search,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 16.0),
//         ValueListenableBuilder<List<TopicModel>>(
//           valueListenable: filteredTopics,
//           builder: (context, unselected, _) {
//             return Wrap(
//               spacing: 8.0,
//               children: unselected.map((topic) {
//                 return Padding(
//                   padding: const EdgeInsets.only(bottom: 5),
//                   child: ActionChip(
//                     backgroundColor: AppColors.lavenderMist,
//                     label: (widget.chipTextStyle != null)
//                         ? Text(
//                       topic.name,
//                       style: widget.chipTextStyle,
//                     )
//                         : Text(topic.name),
//                     onPressed: () => _selectTopic(topic),
//
//                   ),
//                 );
//               }).toList(),
//             );
//           },
//         ),
//       ],
//     );
//   }
// }
