import 'package:socialapp/utils/import.dart';

import '../cubit/collection_state.dart';
import '../cubit/collection_cubit.dart';

class CollectionTab1 extends StatefulWidget {
  final String uid;

  const CollectionTab1({super.key, required this.uid});

  @override
  State<CollectionTab1> createState() => _CollectionTab1State();
}

class _CollectionTab1State extends State<CollectionTab1>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    double deviceWidth = MediaQuery.of(context).size.width;
    return BlocProvider(
      create: (context) => CollectionPostCubit(widget.uid),
      child: BlocBuilder<CollectionPostCubit, CollectionPostState>(
        builder: (context, state) {
          if (state is CollectionPostLoaded) {
            return Padding(
              padding: EdgeInsets.only(top:30, left: deviceWidth * 0.07,
                  right: deviceWidth * 0.07),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,  // Keep 2 columns for your grid
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: 0.5
                ),
                itemCount: state.collections.length,
                itemBuilder: (context, index) {
                  CollectionModel collection = state.collections[index];
                  String? collectionPostImages = collection.presentationUrl;
                  String? collectionDominantColor = collection.dominantColor;
                  int shotsNumber = collection.shotsNumber;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          GridTile(
                            child: RadiusTile(
                              presentationUrl: collectionPostImages,
                              tileDominantColor: collectionDominantColor,
                            ),
                          ),
                          Center(
                            child: Text(
                              collection.title,
                              style: AppTheme.gridItemStyle.copyWith(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          '$shotsNumber shots',
                          style: AppTheme.blackHeaderStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );          }
          return Center(child: SvgPicture.asset(AppImages.empty));
        },
      ),
    );  }

  @override
  bool get wantKeepAlive => true;
}

class RadiusTile extends StatelessWidget {
  final String? presentationUrl;
  final String? tileDominantColor;

  const RadiusTile({
    super.key,
    required this.presentationUrl,
    required this.tileDominantColor,
  });

  @override
  Widget build(BuildContext context) {
    if (presentationUrl == null) {
      return Center(child: SvgPicture.asset(AppImages.empty));
    }

    Color dominantColor = Color(int.parse('0x$tileDominantColor'));

    return LayoutBuilder(
      builder: (context, constraints) {
        double size = constraints.maxWidth;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: size,
            height: size,
            color: dominantColor,
            child: CachedNetworkImage(
              imageUrl: presentationUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: dominantColor,
              ),
              errorWidget: (context, url, error) =>
                  const ImageErrorPlaceholder(),
            ),
          ),
        );
      },
    );
  }
}
