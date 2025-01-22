import 'package:socialapp/utils/import.dart';

class PostHeader extends StatefulWidget {
  const PostHeader({super.key, required this.post});

  final OnlinePostModel post;

  @override
  State<PostHeader> createState() => _PostHeaderState();
}

class _PostHeaderState extends State<PostHeader> with Methods {
  bool isExpanded = false;
  late String truncatedContent, postContent;
  late ValueNotifier<bool> isExpandedNotifier;

  final int maxCharactersPerLine = 52; // Approximate characters per line
  final int maxLines = 4;

  @override
  void initState() {
    super.initState();
    isExpandedNotifier = ValueNotifier<bool>(true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final int maxCharacters = maxLines * maxCharactersPerLine;

    truncatedContent = widget.post.content;
    postContent = widget.post.content;

    if (!isExpanded && truncatedContent.length > maxCharacters) {
      final words = postContent.split(' ');
      final StringBuffer buffer = StringBuffer();
      int currentLength = 0;

      for (String word in words) {
        if (currentLength + word.length > maxCharacters) break;
        if (currentLength > 0) {
          buffer.write(' ');
          currentLength++; // Account for the space
        }
        buffer.write(word);
        currentLength += word.length;
      }

      truncatedContent = '${buffer.toString()}... ';
      isExpandedNotifier.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String timeAgo = calculateTimeFromNow(widget.post.timestamp);

    return Padding(
      padding: AppTheme.postHorizontalPaddingEdgeInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {},
                child: CircleAvatar(
                  radius: 19,
                  backgroundImage:
                      CachedNetworkImageProvider(widget.post.userAvatarUrl),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.post.username,
                    style: AppTheme.blackUsernameStyle,
                    softWrap: true,
                  ),
                  Text(
                    timeAgo,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.timestampStyle,
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 5),
          if(postContent.isNotEmpty)
          ValueListenableBuilder<bool>(
            valueListenable: isExpandedNotifier,
            builder: (context, isExpanded, child) {
              return GestureDetector(
                onTap: () {
                  if (!isExpanded) {
                    isExpandedNotifier.value = true;
                  }
                },
                child: isExpanded
                    ? RichText(
                  text: _buildHashtagText(postContent),
                )
                    : RichText(
                  text: TextSpan(
                    children: [
                      ..._buildContentSpans(truncatedContent), // Use _buildContentSpans here
                      TextSpan(
                        text: 'show more',
                        style: AppTheme.showMoreTextStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            isExpandedNotifier.value = true;
                          },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  TextSpan _buildHashtagText(String content) {
    return TextSpan(
      children: _buildContentSpans(content),
      style: AppTheme.blackHeaderStyle,
    );
  }

  List<TextSpan> _buildContentSpans(String content) {
    final RegExp hashtagRegex = RegExp(r'(#[a-zA-Z0-9_]+)');
    final List<TextSpan> spans = [];
    content = content.replaceAll('\\n', '\n');
    final lines = content.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      int lastMatchEnd = 0;

      for (final match in hashtagRegex.allMatches(line)) {
        if (match.start > lastMatchEnd) {
          spans.add(TextSpan(
            text: line.substring(lastMatchEnd, match.start),
            style: AppTheme.blackHeaderStyle,
          ));
        }

        spans.add(TextSpan(
          text: match.group(0),
          style: AppTheme.highlightedHashtagStyle,
          recognizer: TapGestureRecognizer()
            ..onTap = () {
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
          style: AppTheme.blackHeaderStyle,
        ));
      }

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }
}
