import 'dart:ui';

import 'package:socialapp/utils/import.dart';

import '../../collection/collection_viewing_screen.dart';
import '../cubit/collection_state.dart';
import '../cubit/collection_cubit.dart';

class CollectionTab1 extends StatefulWidget {
  final String userId;

  const CollectionTab1({super.key, required this.userId});

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
      create: (context) => CollectionPostCubit(userId: widget.userId),
      child: BlocBuilder<CollectionPostCubit, CollectionPostState>(
        builder: (context, state) {
          if (state is CollectionPostLoaded) {
            return StreamBuilder<List<CollectionModel>>(
              stream: state.collections,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('There is something wrong, can get data.'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No collections found.'));
                }

                List<CollectionModel> collections = snapshot.data!;

                return Padding(
                  padding: EdgeInsets.only(
                    top: 30,
                    left: deviceWidth * 0.07,
                    right: deviceWidth * 0.07,
                  ),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns in the grid
                      crossAxisSpacing: 10.0,
                      // mainAxisSpacing: 10.0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: collections.length,
                    itemBuilder: (context, index) {
                      CollectionModel collection = collections[index];

                      bool isNSFW = collection.isNSFW ?? false;
                      String? collectionPostImages = collection.presentationUrl;
                      String? collectionDominantColor =
                          collection.dominantColor;
                      int shotsNumber = collection.shotsNumber;

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              GridTile(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CollectionViewingScreen(
                                                  userId: collection.userData.id!,
                                                  collection: collection,
                                                  isInSavedCollections: true,
                                                )));
                                  },
                                  child: RadiusTile(
                                    presentationUrl: collectionPostImages,
                                    tileDominantColor: collectionDominantColor,
                                    isNSFW: isNSFW,
                                  ),
                                ),
                              ),
                              Center(
                                child: Text(
                                  collection.title,
                                  style: AppTheme.gridItemStyle
                                      .copyWith(fontSize: 18),
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
                );
              },
            );
          }

          return Center(child: SvgPicture.asset(AppImages.empty));
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class RadiusTile extends StatelessWidget {
  final String? presentationUrl;
  final String? tileDominantColor;
  final bool isNSFW;

  const RadiusTile({
    super.key,
    required this.presentationUrl,
    required this.tileDominantColor,
    required this.isNSFW,
  });

  @override
  Widget build(BuildContext context) {
    // Default to Color(0xFFDCDCDC) if tileDominantColor is null
    Color dominantColor = tileDominantColor != null
        ? Color(int.parse('0x$tileDominantColor'))
        : AppColors.trolleyGrey;

    return LayoutBuilder(
      builder: (context, constraints) {
        double size = constraints.maxWidth;

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Container(
                width: size,
                height: size,
                color: dominantColor,
                child: presentationUrl != null
                    ? CachedNetworkImage(
                  imageUrl: presentationUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: dominantColor),
                  errorWidget: (context, url, error) =>
                  const ImageErrorPlaceholder(),
                )
                    : null, // Show only background color if presentationUrl is null
              ),

              // Apply NSFW Blur Overlay
              if (isNSFW)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      color: dominantColor.withOpacity(0.9), // Keep dominant color with opacity
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

