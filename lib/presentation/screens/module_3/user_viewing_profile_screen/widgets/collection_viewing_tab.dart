import 'dart:ui';

import 'package:socialapp/utils/import.dart';

import '../../collection/collection_viewing_screen.dart';
import '../cubit/collection_viewing_cubit.dart';
import '../cubit/collection_viewing_state.dart';

class CollectionViewingTab extends StatefulWidget {
  final String userId;

  const CollectionViewingTab({super.key, required this.userId});

  @override
  State<CollectionViewingTab> createState() => _CollectionViewingTabState();
}

class _CollectionViewingTabState extends State<CollectionViewingTab>
    with AutomaticKeepAliveClientMixin, FlashMessage {
  late double deviceHeight = 0, deviceWidth = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return BlocProvider(
      create: (context) => CollectionViewingPostCubit(userId: widget.userId),
      child:
          BlocBuilder<CollectionViewingPostCubit, CollectionViewingPostState>(
        builder: (context, state) {
          if (state is CollectionViewingPostLoading ||
              state is CollectionViewingPostInitial) {
            return SizedBox(
              height: deviceHeight * 0.3,
              child: const Center(
                  child: CircularProgressIndicator(
                color: AppColors.iris,
              )),
            );
          } else if (state is CollectionViewingPostLoaded) {
            if (state.collections.isEmpty) {
              return const Center(child: Text('No collections found.'));
            }

            List<CollectionModel> collections = state.collections;

            return Padding(
              padding: EdgeInsets.only(
                top: 30,
                left: deviceWidth * 0.07,
                right: deviceWidth * 0.07,
              ),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            child: GestureDetector(
                              onTap: () {
                                bool isSignedIn =
                                    serviceLocator<AuthRepository>()
                                        .isSignedIn();

                                if (isSignedIn) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CollectionViewingScreen(
                                                userId: widget.userId,
                                                collection: collection,
                                                isInSavedCollections: false,
                                              )));
                                }else {
                                  showAttentionMessage(
                                      context: context,
                                      title:
                                      'Please sign in to view this collection.');
                                }
                              } ,
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
                              style:
                                  AppTheme.gridItemStyle.copyWith(fontSize: 18),
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
          }
          return NoPublicDataAvailablePlaceholder(
            width: deviceWidth * 0.9,
          );
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
                      color: dominantColor
                          .withOpacity(0.9), // Keep dominant color with opacity
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
