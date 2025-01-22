import 'package:socialapp/presentation/screens/module_2/new_post/cubit/new_post_cubit.dart';
import 'package:socialapp/utils/import.dart';

import 'dialog_topics_selection.dart';

class WebsiteDialogActionBox extends StatelessWidget {
  final double topicBoxWidth, topicBoxHeight;
  final ValueNotifier<List<TopicModel>> topicSelectedNotifier;

  const WebsiteDialogActionBox({super.key, required this.topicBoxWidth, required this.topicSelectedNotifier, required this.topicBoxHeight});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.chooseTopic,
            style: AppTheme.blackUsernameStyle
                .copyWith(color: AppColors.lightIris)),
        SizedBox(
          width: topicBoxWidth,
          child: FutureBuilder<List<TopicModel>>(
            future: context.read<NewPostCubit>().getRandomTopics(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.lightIris,
                  ),
                ); // Show loading indicator
              } else if (snapshot.hasError) {
                return Center(
                    child: Text(
                        'Error: ${snapshot.error}')); // Show error message
              } else if (snapshot.hasData) {
                return TopicChipSelector(
                  topics: snapshot.data!,
                  topicSelectedNotifier: topicSelectedNotifier,
                  searchBarWidth: topicBoxWidth - 10, searchBarHeight: topicBoxHeight,
                ); // Pass the data to TopicChipSelector
              } else {
                return const Center(child: Text('No topics available.'));
              }
            },
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}

class MobileDialogActionBox extends StatelessWidget {
  final ValueNotifier<List<TopicModel>> topicSelectedNotifier;



  const MobileDialogActionBox({
    super.key,
    required this.topicSelectedNotifier,
  });

  @override
  Widget build(BuildContext context) {

    double topicBoxHeight = 430;
    double topicBoxWidth = 490;

    return SizedBox(
      width: topicBoxWidth,
      height: topicBoxHeight,
      // color: Colors.redAccent,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.chooseTopic,
              style: AppTheme.blackUsernameStyle.copyWith(
                color: AppColors.lightIris,
                fontSize: 25,
              ),
            ),
            // FutureBuilder for fetching topics
            FutureBuilder<List<TopicModel>>(
              future: context.read<NewPostCubit>().getRandomTopics(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.lightIris,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  return TopicChipSelector(
                    topics: snapshot.data!,
                    topicSelectedNotifier: topicSelectedNotifier,
                    searchBarWidth: topicBoxWidth - 10,
                    searchBarHeight: topicBoxHeight/4,
                    chipTextStyle: const TextStyle(fontSize: 18),
                  );
                } else {
                  return const Center(child: Text('No topics available.'));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}