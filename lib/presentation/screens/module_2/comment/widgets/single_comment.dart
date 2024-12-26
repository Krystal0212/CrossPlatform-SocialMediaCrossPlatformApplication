import 'package:socialapp/utils/import.dart';

class SingleComment extends StatefulWidget {
  const SingleComment({super.key, required this.comment});

  final CommentModel comment;

  @override
  State<SingleComment> createState() => _SingleCommentState();
}

class _SingleCommentState extends State<SingleComment> with Methods {
  late String timestamp;

  @override
  void initState() {
    super.initState();
    timestamp = calculateTimeFromNow(widget.comment.timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(
                  widget.comment.userAvatar,
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.comment.username),
                  Text(widget.comment.content),
                  Row(
                    children: [
                      Text(
                        timestamp,
                        overflow: TextOverflow.ellipsis,
                      ),
                      InkWell(
                        onTap: () {},
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Like'),
                        ),
                      ),
                      const Spacer(),
                      const Text('02'),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
