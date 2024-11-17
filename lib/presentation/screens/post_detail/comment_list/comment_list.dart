import 'package:flutter/material.dart';
import 'package:socialapp/domain/entities/comment.dart';

class CommentList extends StatelessWidget {
  CommentList({super.key, required this.comments});

  List<CommentModel>? comments;
  
  @override
  Widget build(BuildContext context) {
    return comments == null ? const Center(child: Text('No comments')) :
      ListView.builder(
      itemBuilder: (context, index) {
        return const Text('213');
      },
      itemCount: comments!.length,
    );
  }
}

class UserComment extends StatelessWidget {
  const UserComment({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: CircleAvatar(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('username'),
                  const Text('comment'),
                  Row(
                    children: [
                      const Text('timestamp'),
                      InkWell(
                        onTap: () {},
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('like'),
                        ),
                      ),
                      const Spacer(),
                      const Text('02'),
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {},
                      ),
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