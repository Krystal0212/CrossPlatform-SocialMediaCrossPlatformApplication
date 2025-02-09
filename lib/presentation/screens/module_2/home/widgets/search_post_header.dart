import 'package:socialapp/presentation/screens/module_2/home/providers/home_properties_provider.dart';
import 'package:socialapp/utils/import.dart';

import '../../mobile_navigator/providers/mobile_navigator_provider.dart';
import '../cubit/home_cubit.dart';

class SearchPostHeader extends StatefulWidget {
  const SearchPostHeader({super.key, required this.post});

  final OnlinePostModel post;

  @override
  State<SearchPostHeader> createState() => _SearchPostHeaderState();
}

class _SearchPostHeaderState extends State<SearchPostHeader> with Methods, FlashMessage {
  bool isExpanded = false;
  late String truncatedContent, postContent;
  late ValueNotifier<bool> isExpandedNotifier;

  final int maxCharactersPerLine = 52; // Approximate characters per line
  final int maxLines = 4;
  late bool isOwner = false;

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
  void dispose() {
    isExpandedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String timeAgo = calculateTimeFromNow(widget.post.timestamp);
    String userOwnerId = widget.post.userId;
    bool isSignedIn = serviceLocator<AuthRepository>().isSignedIn();
    UserModel? currentUser = HomePropertiesProvider.of(context)?.currentUser;

    return Padding(
      padding: AppTheme.postHorizontalPaddingEdgeInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InkWell(
                onTap: () async {
                  if (isSignedIn && currentUser?.id == userOwnerId) {
                    if (!context.mounted) return;
                    MobileNavigatorPropertiesProvider.of(context)!
                        .navigateToCurrentUserProfile();
                  } else {
                    if (!context.mounted) return;
                    MobileNavigatorPropertiesProvider.of(context)!
                        .navigateToOtherUserProfile(userOwnerId);
                  }
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage:
                  CachedNetworkImageProvider(widget.post.userAvatarUrl),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () async {
                      if (isSignedIn && currentUser?.id == userOwnerId) {
                        if (!context.mounted) return;
                        MobileNavigatorPropertiesProvider.of(context)!
                            .navigateToCurrentUserProfile();
                      } else {
                        if (!context.mounted) return;
                        MobileNavigatorPropertiesProvider.of(context)!
                            .navigateToOtherUserProfile(userOwnerId);
                      }
                    },
                    child: Text(
                      widget.post.username,
                      style: AppTheme.blackUsernameMobileStyle
                          .copyWith(fontSize: 22),
                      softWrap: true,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (currentUser != null) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => PostDetailScreen(
                              post: widget.post,
                              currentUser: currentUser,
                            )));
                      } else {
                        showNotSignedInMassage(
                            context: context,
                            description:
                            AppStrings.notSignedInCollectionDescription);
                      }
                    },
                    child: Text(
                      timeAgo,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.timestampStyle,
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
          if (postContent.isNotEmpty) ...[
            const SizedBox(height: 25),
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
                        ..._buildContentSpans(truncatedContent),
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
        ],
      ),
    );
  }

  TextSpan _buildHashtagText(String content) {
    return TextSpan(
      children: _buildContentSpans(content),
      style: AppTheme.blackHeaderStyle.copyWith(fontSize: 20),
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
            style: AppTheme.blackHeaderStyle.copyWith(fontSize: 20),
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
          style: AppTheme.blackHeaderStyle.copyWith(fontSize: 20),
        ));
      }

      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return spans;
  }
}
