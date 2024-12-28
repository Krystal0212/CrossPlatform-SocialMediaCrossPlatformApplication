import 'package:flutter/material.dart';
import 'package:socialapp/domain/entities/topic.dart';
import 'package:socialapp/utils/styles/colors.dart';
import 'package:socialapp/utils/styles/text_style.dart';

class TopicScreen extends StatelessWidget {
  TopicScreen({super.key, required this.topics});

  List<TopicModel>? topics;

  @override
  Widget build(BuildContext context) {
    // print('topics: $topics');
    // print('topics: ${topics![1].name}');
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BackButton(
              color: AppColors.carbon,  
            ),

            topics == null ?
              const CircularProgressIndicator() :
              Expanded(
                child: ListView.builder(
                  itemBuilder: (
                    BuildContext context, int index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 140,
                                decoration: BoxDecoration(
                                  color: AppColors.carbon.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(image: 
                                    NetworkImage(topics![index].thumbnailUrl), fit: BoxFit.cover
                                  )
                                ),
                              ),
                            ),
                            Positioned(
                              // left: 50,
                              top: 48,
                              left: (index % 2 == 0) ? MediaQuery.of(context).size.width * 0.2 : MediaQuery.of(context).size.width * 0.6,
                              // child: Text(topics![index].name)
                              child: Text(topics![index].name.toUpperCase(), style: AppTextStyle.uppercaseWhiteBigStyle)
                            ),
                          ],
                        ),
                      );
                    },
                  itemCount: topics?.length ?? 0
                ),
              ),
          ],
        )
      )
    );
  }
}