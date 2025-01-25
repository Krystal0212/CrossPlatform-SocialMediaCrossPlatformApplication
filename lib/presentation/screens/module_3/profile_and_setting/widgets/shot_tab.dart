import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:socialapp/presentation/screens/module_2/home/cubit/tab_cubit.dart';
import 'package:socialapp/utils/import.dart';

import '../cubit/media_cubit.dart';
import '../cubit/media_state.dart';

class ShotTab1 extends StatefulWidget {
  const ShotTab1({super.key});

  @override
  State<ShotTab1> createState() => _ShotTab1State();
}

class _ShotTab1State extends State<ShotTab1>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    double deviceWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (context) => MediaPostCubit(),
      child: Padding(
        padding: EdgeInsets.only(top:30, left: deviceWidth * 0.07,
            right: deviceWidth * 0.07),
        child: SingleChildScrollView(
          child: BlocBuilder<MediaPostCubit, MediaPostState>(
            builder: (context, state) {
              if (state is MediaPostLoaded) {
                return MasonryGridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.imageUrls.length,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  itemBuilder: (context, index) {
                    if (index < state.imageUrls.length) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: state.imageUrls[index].mediasOrThumbnailUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                );
              }
              return Center(child: SvgPicture.asset(AppImages.empty));
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // Keep the widget alive
}

