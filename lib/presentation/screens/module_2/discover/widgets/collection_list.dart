import 'package:flutter/material.dart';
import 'package:socialapp/domain/entities/collection.dart';
import 'package:socialapp/utils/styles/colors.dart';
import 'package:socialapp/utils/styles/text_style.dart';

class CollectionList extends StatelessWidget {
  CollectionList({super.key, required this.collections});

  List<CollectionModel>? collections;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Collection',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
              ),

              InkWell(
                onTap: () {},
                child: const Text('View more', style: TextStyle(color: AppColors.mutedLavender),),
              )
            ],
          ),

          const SizedBox(height: 16,),

          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return SingleCollection(collection: collections![index],);
              },
              separatorBuilder: (context, index) {
                return const SizedBox(width: 10);
              },
              itemCount: collections!.length),
          ),
          // CollectionImageCustom()
        ],
      ),
    );
  }
}

class SingleCollection extends StatelessWidget {
  SingleCollection({super.key, required this.collection});

  CollectionModel collection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 232,
      width: 150,
      child: Column(
        children: [
          CollectionImageCustom(collection: collection),
          Center(
            child: Text(collection.title),
          )
        ],
      ),
    );
  }
}
class CollectionImageCustom extends StatelessWidget {
  CollectionImageCustom({super.key, required this.collection});

  CollectionModel collection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 150,
      child: Stack(
        children: [
          // Container(
          //   decoration: BoxDecoration(
          //     borderRadius: const BorderRadius.all(Radius.circular(16)),
          //     image: DecorationImage(
          //       image: NetworkImage(collection.thumbnail),
          //       fit: BoxFit.fill
          //     )
          //   ),
          // ),
          Center(
            child: Text(collection.title.toUpperCase(), style: AppTextStyle.uppercaseWhiteNormalStyle,),
          )
        ],
      ),
    );
  }
}
