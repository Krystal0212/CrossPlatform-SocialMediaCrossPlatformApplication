import 'package:flutter/material.dart';
import 'package:socialapp/utils/constants/strings.dart';
import 'package:socialapp/utils/import.dart';
import 'package:socialapp/utils/styles/colors.dart';

class AddCollectionIcon extends StatelessWidget {
  const AddCollectionIcon({super.key});

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return IconButton(
        onPressed: () {
          showModalBottomSheet<void>(
              isScrollControlled: true,
              context: context,
              builder: (BuildContext context) {
                return Container(
                    height: deviceHeight * 0.7,
                    decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                        color: AppColors.white),
                    // height: 400,
                    child: const AddPostModal());
              });
        },
        icon: const Icon(
          Icons.add_circle_outline,
          color: AppColors.carbon,
        ));
  }
}

class AddPostModal extends StatelessWidget {
  const AddPostModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const Text(
                    'Save to collection',
                    style: TextStyle(fontSize: 12),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet<void>(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return const NewCollectionModal();
                          });
                    },
                    child: const Text(
                      'New collection',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    )
                  )
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Your collections',
                style: TextStyle(fontSize: 12),
              )
            ),

            GridView.builder(
              shrinkWrap: true,
              itemCount: 4,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
              ),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Center(
                    child: Text(
                      'Item $index',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class NewCollectionModal extends StatelessWidget {
  const NewCollectionModal({super.key});

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      height: deviceHeight * 0.65,
      decoration: AppTheme.addCollectionBoxDecoration,
      child: Center(
        child: Padding(
          padding: AppTheme.addCollectionPadding,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: AppStrings.collectionName,
                ),
              ),

              const SizedBox(height: 16,),

              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: deviceWidth,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.teal
                  ),
                  child: const Center(child: Text(AppStrings.createCollection)),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
