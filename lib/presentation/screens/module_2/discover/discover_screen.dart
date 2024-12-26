import 'package:flutter/material.dart';
import 'package:socialapp/domain/entities/collection.dart';
import 'package:socialapp/domain/entities/topic.dart';
import 'package:socialapp/domain/repository/collection/collection_repository.dart';
import 'package:socialapp/domain/repository/topic/topic_repository.dart';
import 'package:socialapp/presentation/screens/module_2/discover/widgets/collection_list.dart';
import 'package:socialapp/presentation/screens/module_2/discover/widgets/topic_list.dart';
import 'package:socialapp/service_locator.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  // late List<TopicModel>? topics;

  @override
  void initState() {
    super.initState();
    // topics = fetchTopicData();
    // topics = serviceLocator<TopicRepository>().getTopicsData();
    // serviceLocator<TopicRepository>().getTopicsData()?.then((value) {
    //   setState(() {
    //     topics = value;
    //   });
    // });
    // serviceLocator<UserRepository>().getCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    // print('topics: $topics');
    return SafeArea(
      bottom: false,
      child: 
      Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<List<TopicModel>?>(
                future: serviceLocator<TopicRepository>().getTopicsData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No topics available');
                  } else {
                    // topics = snapshot.data;
                    return TopicList(topics: snapshot.data);
                  }
                }
              ),

              const SizedBox(height: 24,),
              // TopicList(topics: topics),
              // CollectionList(),
              FutureBuilder<List<CollectionModel>?>(
                future: serviceLocator<CollectionRepository>().getCollections(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No collections available');
                  } else {
                    // topics = snapshot.data;
                    return CollectionList(collections: snapshot.data);
                  }
                }
              ),
          ],),
        ), 
      ),
    );
  }
}

