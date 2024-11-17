import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/presentation/screens/category/cubit/category_cubit.dart';
import 'package:socialapp/presentation/screens/category/cubit/category_state.dart';
import 'package:socialapp/utils/styles/colors.dart';
import 'package:socialapp/utils/styles/themes.dart';

import '../../../../domain/repository/user/user_repository.dart';
import '../../../../service_locator.dart';
import '../../../../utils/constants/image_path.dart';

class CategoryImageGroup extends StatefulWidget {
  const CategoryImageGroup({super.key});

  @override
  State<CategoryImageGroup> createState() => _CategoryImageGroupState();
}

class _CategoryImageGroupState extends State<CategoryImageGroup> {
  static List<String> imageList = [
    AppImages.category1,
    AppImages.category2,
    AppImages.category3,
    AppImages.category4
  ];

  String? categoryId;
  static List<Map<String, String>> categories = [];

  @override
  void initState() {
    categoryId = null;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchCategoriesData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            categories = snapshot.data!;
            return SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.5,
                child: BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    return GridView.count(
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.9,
                      crossAxisCount: 2,
                      children: [
                        for (var i = 0; i < categories.length; i++)
                          GestureDetector(
                            onTap: () {
                              categoryId = categories[i]['id'];
                              context
                                  .read<CategoryCubit>()
                                  .getCategoryId(categoryId);
                              if (kDebugMode) {
                                print("ID được nhấn: $categoryId");
                              }
                            },
                            child: Opacity(
                              opacity:
                                  categoryId != categories[i]['id'] ? 1.0 : 0.6,
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    alignment: Alignment.bottomCenter,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(12)),
                                      image: DecorationImage(
                                        image: AssetImage(imageList[i]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Opacity(
                                    opacity: 0.3,
                                    child: Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationY(3.14159),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          image: DecorationImage(
                                            image: AssetImage(AppImages
                                                .editProfileAppbarBackground),
                                            fit: BoxFit.cover,
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 20,
                                    child: Text(
                                      categories[i]['name']!,
                                      style: AppTheme.drawerItemStyle,
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ));
          } else {
            return Container(
              color: AppColors.white,
            );
          }
        });
  }

  Future<List<Map<String, String>>> fetchCategoriesData() async {
    List<Map<String, String>> categories = [];
    try {
      categories = await serviceLocator<UserRepository>().fetchCategoriesData();
    } catch (e) {
      if (kDebugMode) {
        print("Error");
      }
    }
    return categories;
  }
}
