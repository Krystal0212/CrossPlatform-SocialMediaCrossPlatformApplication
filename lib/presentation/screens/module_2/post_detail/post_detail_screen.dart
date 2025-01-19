

import 'package:socialapp/utils/import.dart';

import 'post_detail/post_detail.dart';

class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key, required this.post});

  final OnlinePostModel post;
 
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
                    color: AppColors.erieBlack,
                  ),
                  const Spacer(),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border, color: AppColors.erieBlack,)),
                  // const AddCollectionIcon(),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.ios_share, color: AppColors.erieBlack,))
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
