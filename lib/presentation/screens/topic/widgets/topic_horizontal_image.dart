
import 'package:flutter/material.dart';
import 'package:socialapp/domain/entities/topic.dart';

import '../../../../utils/import.dart';

class TopicHorizontalImage extends StatelessWidget {
  TopicHorizontalImage({super.key, required this.topic, required this.topicIndex});

  TopicModel topic;
  int topicIndex;
  
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print('topic: $topic.');
    }
    if (kDebugMode) {
      print('topicIndex: $topicIndex');
    }
    return Stack(
      children: [
        Positioned(
          left: 10,
          // left: MediaQuery.of(context).size.width * 0.05,
          top: 0,
          child: Container(
            // width: MediaQuery.of(context).size.width * 0.9,
            width: 200,
            height: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(topic.thumbnail),
                fit: BoxFit.cover
              )
            ),
          ),
        ),
    
        Positioned(
          left: topicIndex % 2 == 0 ? 16 : 168,
          top: 48,
          child: Text(topic.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14
            ),
          ),
        )
      ],
    );
  }
}