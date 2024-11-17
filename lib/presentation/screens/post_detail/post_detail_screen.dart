import 'package:flutter/material.dart';
import 'package:socialapp/domain/entities/post.dart';
import 'package:socialapp/presentation/screens/post_detail/post_detail/post_detail.dart';
import 'package:socialapp/presentation/widgets/add_collection_icon.dart';
import 'package:socialapp/utils/styles/colors.dart';

class PostDetailScreen extends StatelessWidget {
  PostDetailScreen({super.key, required this.post});

  PostModel post;
 
  // CollectionReference<Map<String, dynamic>> postCollection = FirebaseFirestore.instance.collection('NewPost').doc('');
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Row(children: [
                  const BackButton(
                    color: AppColors.carbon,
                  ),
                  const Spacer(),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, color: AppColors.carbon,)),
                  const AddCollectionIcon(),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share, color: AppColors.carbon,))
                ],),
                
                PostUserInfo(post: post),
              ],
            ),

            // Expanded(child: SingleChildScrollView(child: PostDetail(post: post))),
            PostDetail(post: post),
        
            // FutureBuilder(
            //   future: serviceLocator<PostRepository>().getCommentPost(post),
            //   builder: (context, snapshot) {
            //     return Text('hehe');
            //   }
            // )
            // TextField(
            //   onTapOutside: (e) {
            //     FocusManager.instance.primaryFocus?.unfocus();
            //   },
            //   decoration: InputDecoration(
            //     hintText: 'Add a comment',
            //     suffixIcon: IconButton(
            //       icon: Icon(Icons.send),
            //       onPressed: () {
            //         // serviceLocator<PostRepository>().addCommentPost(post, 'hehe');
            //     }
            // )))
          ]
        )
      )
    );
  }
}
