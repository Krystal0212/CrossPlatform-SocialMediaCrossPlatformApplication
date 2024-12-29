import 'package:socialapp/utils/import.dart';

import 'widgets/home_header_custom.dart';
import 'widgets/post_custom.dart';
import 'widgets/tab_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<dynamic> posts;
  late CollectionReference<Map<String, dynamic>> postCollection;
  // late CollectionReference<Map<String, dynamic>> commentPostCollection;
  late dynamic userInfo;
  
  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    // postCollection = FirebaseFirestore.instance.collection("Post").where(field, isEqualTo: value);

  }

  @override
  void didChangeDependencies() async{
    super.didChangeDependencies();
    // posts = Provider.of<PostRepository>(context).getPostsData();
  }

   @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const HomeHeaderCustom(),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: AppColors.white,
                  // color: Colors.green.shade100,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    indicator: BoxDecoration(
                      color: AppColors.iric.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    labelColor: AppColors.iric,
                    unselectedLabelColor: AppColors.dynamicBlack.withOpacity(0.5),
                    tabs: const [
                      TabItem(title: 'Popular',),
                      TabItem(title: 'Trending'),
                      TabItem(title: 'Following'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [
            PostListView(),
            PostListView(),
            PostListView(),
          ],
        ),
      ),
    );
  }
}

class PostListView extends StatefulWidget {
  const PostListView({super.key});

  @override
  State<PostListView> createState() => _PostListViewState();
}

class _PostListViewState extends State<PostListView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FutureBuilder(
      future: serviceLocator.get<PostRepository>().getPostsData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // return const Center(child: Text('No data found.'));
          return  const Center(
            child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: LogOutButton(),
                    ),
          );
        }

        return Container(
          color: AppColors.orochimaru,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return PostCustom(post: snapshot.data![index]);
              },
            ),

          ),
        );
      },
    );
  }
}