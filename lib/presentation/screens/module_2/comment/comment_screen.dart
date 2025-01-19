

import 'package:socialapp/utils/import.dart';
import 'widgets/single_comment.dart';

class CommentScreen extends StatelessWidget {
  const CommentScreen({super.key, required this.post});

  final OnlinePostModel post;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              height: 40,
              color: AppColors.lavenderBlueShadow,
              child: Stack(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,  
                    children: [
                      IconButton(
                        onPressed: () {
                     
                        },
                        icon: const Icon(Icons.arrow_back, color: AppColors.white,),
                      ),
                      
                      IconButton(onPressed: () {}, icon: const Icon(Icons.flag_outlined))
                    ],
                  ),
                
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: SizedBox(
                      child: Center(
                        child: Text(
                          'Comments',
                          style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)
                        ),
                      ),
                    )
                  ),
                ]    
              ),
            ),

            Expanded(
              child: FutureBuilder(
                future: serviceLocator<PostRepository>().getCommentPost(post),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No comments available'));
                  }
                  
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: SingleComment(comment: snapshot.data![index]),
                      );
                    }
                  );
                }
              )
            )
          ],
        )
      )
    );
  }
}
