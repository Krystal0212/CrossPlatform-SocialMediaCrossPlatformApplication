import 'package:socialapp/utils/import.dart';

import '../../home/providers/home_properties_provider.dart';
import '../../mobile_navigator/providers/mobile_navigator_provider.dart';

class PostDetailContent extends StatefulWidget {
  final OnlinePostModel post;
  final UserModel user;
  final TextEditingController searchController;
  final ValueNotifier<String> postContentNotifier;

  const PostDetailContent(
      {super.key,
      required this.post,
      required this.user,
      required this.searchController,
      required this.postContentNotifier});

  @override
  State<PostDetailContent> createState() => _PostDetailContentState();
}

class _PostDetailContentState extends State<PostDetailContent> {
  late String postContent;
  late ValueNotifier<bool> isExpandedNotifier;
  late TextEditingController searchController;

  final int maxCharactersPerLine = 52; // Approximate characters per line
  final int maxLines = 4;

  @override
  void initState() {
    super.initState();
    isExpandedNotifier = ValueNotifier<bool>(true);
    searchController = widget.searchController;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    postContent = widget.post.content;
  }

  @override
  void dispose() {
    isExpandedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
        valueListenable: widget.postContentNotifier,
        builder: (context, postContent, child) {
          final RegExp hashtagRegex = RegExp(r'(#[a-zA-Z0-9_]+)');
          final List<TextSpan> spans = [];
          postContent = postContent.replaceAll('\\n', '\n');
          final lines = postContent.split('\n');

          for (var i = 0; i < lines.length; i++) {
            final line = lines[i];
            int lastMatchEnd = 0;

            for (final match in hashtagRegex.allMatches(line)) {
              if (match.start > lastMatchEnd) {
                spans.add(TextSpan(
                  text: line.substring(lastMatchEnd, match.start),
                  style: AppTheme.blackHeaderMobileStyle,
                ));
              }

              spans.add(TextSpan(
                text: match.group(0),
                style: AppTheme.highlightedHashtagStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (!kIsWeb) {
                      searchController.text = match.group(0)!;
                      Navigator.pop(context);

                      if (!context.mounted) return;
                      MobileNavigatorPropertiesProvider.of(context)!
                          .navigateToHome();
                    }

                    if (kDebugMode) {
                      print('Clicked hashtag: ${match.group(0)}');
                    }
                  },
              ));

              lastMatchEnd = match.end;
            }

            if (lastMatchEnd < line.length) {
              spans.add(TextSpan(
                text: line.substring(lastMatchEnd),
                style: AppTheme.blackHeaderMobileStyle,
              ));
            }

            if (i < lines.length - 1) {
              spans.add(const TextSpan(text: '\n'));
            }
          }

          return LayoutBuilder(builder: (context, constraints) {
            double paddingWidth = constraints.maxWidth * 0.06;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (postContent.isNotEmpty) ...[
                  Container(
                    padding: EdgeInsets.only(
                        left: paddingWidth, right: paddingWidth, top: 15),
                    child: RichText(
                      text: TextSpan(
                        children: spans,
                      ),
                    ),
                  ),
                ],
              ],
            );
          });
        });
  }
}
