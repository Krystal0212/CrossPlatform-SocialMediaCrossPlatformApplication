import 'package:flutter/material.dart';
import 'package:socialapp/domain/entities/topic.dart';
import 'package:socialapp/presentation/screens/module_2/topic/topic_screen.dart';
import 'package:socialapp/utils/styles/colors.dart';
import 'package:socialapp/utils/styles/text_style.dart';

class TopicList extends StatelessWidget {
  TopicList({super.key, required this.topics});

  List<TopicModel>? topics;
  @override
  Widget build(BuildContext context) {
    print('topics: $topics');
    return SizedBox(
      height: 148,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Topic',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TopicScreen(topics: topics)
                    )
                  );
                },
                child: const Text('View more', style: TextStyle(color: AppColors.mutedLavender),),
              )
            ],
          ),

          const SizedBox(height: 16,),

          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return TopicImageCustom(topic: topics![index],);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(width: 16);
              },
              itemCount: topics?.length ?? 0),
          ),
          // TopicImageCustom()
        ],
      ),
    );
  }
}

class TopicImageCustom extends StatelessWidget {
  TopicImageCustom({super.key, required this.topic});

  TopicModel topic;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      width: 148,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(16)),
              image: DecorationImage(
                // image: AssetImage(
                //   'assets/images/appscyclone.png'
                // ),
                image: NetworkImage(topic.thumbnailUrl),
                fit: BoxFit.cover,
              )
            ),
          ),
          Center(
            child: Text(topic.name.toUpperCase(), style: AppTextStyle.uppercaseWhiteNormalStyle,),
          )
        ],
      ),
    );
  }
}
