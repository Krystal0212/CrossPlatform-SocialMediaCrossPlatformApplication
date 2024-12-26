import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialapp/presentation/screens/category/cubit/category_cubit.dart';
import 'package:socialapp/presentation/screens/category/cubit/category_state.dart';
import 'package:socialapp/presentation/screens/category/widgets/category_image_group.dart';
import 'package:socialapp/presentation/widgets/auth/auth_elevated_button.dart';
import 'package:socialapp/presentation/widgets/forgot_password/linear_gradient_title.dart';
import 'package:socialapp/utils/styles/colors.dart';
import 'package:socialapp/utils/styles/themes.dart';

import '../../../utils/constants/image_path.dart';
import '../../widgets/edit_profile/bottom_rounded_appbar.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(
                top: 160, left: 20, right: 20, bottom: 20),
            width: double.infinity,
            height: double.infinity,
            color: AppColors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Who are you?",
                  style: AppTheme.categoryLabelStyle,
                ),
                const SizedBox(
                  height: 15,
                ),
                const CategoryImageGroup(),
                LinearGradientTitle(
                    text: "SHARE - INSPIRE - CONNECT",
                    textStyle: AppTheme.categoryBottomTitle),
                const SizedBox(
                  height: 15,
                ),
                BlocBuilder<CategoryCubit, CategoryState>(
                    builder: (context, state) {
                  return state is GetCategoryIDSuccess
                      ? AuthElevatedButton(
                          width: double.infinity,
                          height: 42,
                          inputText: "EXPLORE NOW",
                          isLoading: (state is AddUserLoading ? true : false),
                          onPressed: () => context
                              .read<CategoryCubit>()
                              .addCurrentUserData(context))
                      : Opacity(
                          opacity: 0.5,
                          child: AuthElevatedButton(
                              width: double.infinity,
                              height: 42,
                              inputText: "EXPLORE NOW",
                              isLoading: false,
                              onPressed: () {}));
                })
              ],
            ),
          ),
          const BottomRoundedAppBar(
              bannerPath: AppImages.editProfileAppbarBackground),
        ],
      ),
    );
  }
}
