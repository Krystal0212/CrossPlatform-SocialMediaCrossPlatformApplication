import 'package:socialapp/utils/import.dart';

class CreateNewPostDialogContent extends StatefulWidget {
  final UserModel currentUser;

  const CreateNewPostDialogContent({super.key, required this.currentUser});

  @override
  State<CreateNewPostDialogContent> createState() =>
      _CreateNewPostDialogContentState();
}

class _CreateNewPostDialogContentState
    extends State<CreateNewPostDialogContent> {
  final double sideWidth = 25;

  late double deviceWidth;
  late bool isCompactView, isMediumView, isLargeView;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceWidth = MediaQuery.of(context).size.width;

    isCompactView = deviceWidth < 680;
    isMediumView = deviceWidth >= 680 && deviceWidth < 1200;
    isLargeView = deviceWidth >= 1200;
  }



  @override
  Widget build(BuildContext context) {
    return Container(
      width: deviceWidth * 0.4,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: sideWidth,
                width: sideWidth,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: AppTheme.actionNoEffectCircleButtonStyle.copyWith(
                    backgroundColor: const WidgetStatePropertyAll(
                      Colors.transparent,
                    ),
                  ),
                  child:
                      SvgPicture.asset(AppIcons.cross, width: 18, height: 18),
                ),
              ),
              const Text(
                'Create New Post',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: sideWidth,
              )
            ],
          ),
          const SizedBox(height: 14),
          const Divider(
            color: AppColors.iris,
            thickness: 1,
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 45,
                  height: 45,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundImage: CachedNetworkImageProvider(
                        widget.currentUser.avatar,
                        maxWidth: 25,
                        maxHeight: 25),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.currentUser.name,
                        style: AppTheme.blackUsernameStyle),
                    SizedBox(
                      width: (isLargeView)
                          ? deviceWidth * 0.27
                          : deviceWidth * 0.1,
                      child: Row(
                        children: <Widget>[
                          Container(
                            width: 0.1,
                          ),
                          Flexible(
                            child: TextField(
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                                fillColor: AppTheme.white,
                                filled: true,
                                hoverColor: AppTheme.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(color: AppTheme.white),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(color: AppTheme.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(color: AppTheme.white),
                                ),
                                hintText: 'What\'s new ?',
                              ),
                              maxLines: null, // Allow multiple lines
                              keyboardType: TextInputType
                                  .multiline, // Allow multiline input
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                      },
                      icon: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return AppTheme.mainGradient.createShader(bounds);
                        },
                        child: const Icon(Icons.perm_media_outlined,
                            color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                      },
                      icon: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return AppTheme.mainGradient.createShader(bounds);
                        },
                        child:
                            const Icon(Icons.mic_rounded, color: Colors.white),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                      },
                      icon: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return AppTheme.mainGradient.createShader(bounds);
                        },
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HashtagTextField extends StatefulWidget {
  const HashtagTextField({super.key});

  @override
  State<HashtagTextField> createState() => HashtagTextFieldState();
}

class HashtagTextFieldState extends State<HashtagTextField> {
  final TextEditingController _controller = TextEditingController();
  String _text = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _text = _controller.text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextSpan _buildTextSpan(String text) {
    final RegExp hashtagRegex = RegExp(r'(#[a-zA-Z0-9_]+)');
    final List<TextSpan> spans = [];
    int start = 0;

    hashtagRegex.allMatches(text).forEach((match) {
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: AppTheme.blackHeaderStyle,
          ),
        );
      }

      spans.add(
        TextSpan(
          text: match.group(0),
          style: AppTheme.highlightedHashtagStyle,
        ),
      );

      start = match.end;
    });

    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: AppTheme.blackHeaderStyle,
        ),
      );
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // The TextField
            TextField(
              controller: _controller,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type something with #hashtags...',
              ),
            ),
            const SizedBox(height: 20),

            // The RichText
            RichText(
              text: _buildTextSpan(_text),
            ),
          ],
        ),
      ),
    );
  }
}