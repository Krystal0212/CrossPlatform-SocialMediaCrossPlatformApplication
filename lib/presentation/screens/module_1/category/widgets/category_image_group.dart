import 'package:socialapp/utils/import.dart';
import '../cubit/category_cubit.dart';
import '../cubit/category_state.dart';

class CategoryImageGroup extends StatefulWidget {
  const CategoryImageGroup({super.key});

  @override
  State<CategoryImageGroup> createState() => _CategoryImageGroupState();
}

class _CategoryImageGroupState extends State<CategoryImageGroup> {
  late double deviceWidth, deviceHeight;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchCategoriesData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            categories = snapshot.data!;
            return SizedBox(
                width: deviceWidth,
                height: deviceHeight * 0.5,
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
                                print("Category ID pressed: $categoryId");
                              }
                            },
                            child: Opacity(
                              opacity:
                                  categoryId != categories[i]['id'] ? 1.0 : 0.6,
                              child: Stack(
                                children: [
                                  Container(
                                    padding: AppTheme.paddingBottom,
                                    alignment: Alignment.bottomCenter,
                                    decoration: BoxDecoration(
                                      borderRadius: AppTheme.smallBorderRadius,
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
                                        decoration: AppTheme.profileBackgroundBoxDecoration,
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
