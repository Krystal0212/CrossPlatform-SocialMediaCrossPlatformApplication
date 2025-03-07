import 'package:socialapp/presentation/widgets/general/debounce_search_bar.dart';
import 'package:socialapp/utils/import.dart';
import '../../module_3/collection/collection_viewing_screen.dart';
import '../../module_3/profile_and_setting/widgets/collection_tab.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with FlashMessage {
  late double deviceWidth = 0, deviceHeight = 0;
  final TextEditingController _searchController = TextEditingController();

  // Use ValueNotifier instead of String
  final ValueNotifier<String> searchQueryNotifier = ValueNotifier("");

  @override
  void initState() {
    super.initState();
    final flutterView = PlatformDispatcher.instance.views.first;
    deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    deviceHeight = flutterView.physicalSize.height;
  }

  @override
  void dispose() {
    _searchController.dispose();
    searchQueryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext discoverContext) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: FocusScope(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 30, right: 30, top: 25, bottom: 10),
          child: FutureBuilder(
            future: serviceLocator.get<UserService>().getCurrentUserData(),
            builder:
                (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
              UserModel? currentUser = snapshot.data;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (kIsWeb)
                        IconButton(
                          style: ButtonStyle(
                            elevation: WidgetStateProperty.all(0.0),
                            overlayColor:
                                WidgetStateProperty.all(Colors.transparent),
                          ),
                          onPressed: () {
                            Navigator.pop(discoverContext);
                          },
                          icon: SvgPicture.asset(
                            AppIcons.backButton,
                            width: 75,
                            height: 75,
                          ),
                        ),

                      // Search field
                      Expanded(
                        child: DebouncedTextField(
                          controller: _searchController,
                          hintText: "Search collections name",
                          onChangedDebounced: (value) {
                            searchQueryNotifier.value = value.trim();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Title updates dynamically using ValueListenableBuilder
                  ValueListenableBuilder<String>(
                    valueListenable: searchQueryNotifier,
                    builder: (context, searchQuery, _) {
                      return Text(
                        searchQuery.isEmpty
                            ? 'Some collections that you may like'
                            : 'Search result',
                        style: AppTheme.messageStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),

                  // FutureBuilder uses ValueListenableBuilder to listen for searchQuery changes
                  ValueListenableBuilder<String>(
                    valueListenable: searchQueryNotifier,
                    builder: (context, searchQuery, _) {
                      Future<List<CollectionModel>> futureCollections =
                          searchQuery.isEmpty
                              ? serviceLocator
                                  .get<CollectionService>()
                                  .getCollectionsOrderByAssets()
                              : serviceLocator
                                  .get<CollectionService>()
                                  .getCollectionsFromQuery(searchQuery);

                      return Expanded(
                        child: FutureBuilder<List<CollectionModel>>(
                          future: futureCollections,
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return NoPublicDataAvailablePlaceholder(
                                  width: deviceWidth * 0.9);
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return SizedBox(
                                height: deviceHeight * 0.3,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.iris,
                                  ),
                                ),
                              );
                            }

                            List<CollectionModel> collections =
                                snapshot.data ?? [];

                            return NotificationListener<
                                OverscrollIndicatorNotification>(
                              onNotification: (overscroll) {
                                overscroll.disallowIndicator();
                                return true;
                              },
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, // 2 columns in the grid
                                  crossAxisSpacing: 10.0,
                                  childAspectRatio: 0.8,
                                ),
                                itemCount: collections.length,
                                itemBuilder: (context, index) {
                                  CollectionModel collection =
                                      collections[index];

                                  bool isNSFW = collection.isNSFW ?? false;
                                  String? collectionPostImages =
                                      collection.presentationUrl;
                                  String? collectionDominantColor =
                                      collection.dominantColor;
                                  int shotsNumber = collection.shotsNumber;
                                  bool isNSFWFilterTurnOn =
                                      currentUser?.isNSFWFilterTurnOn ?? true;

                                  bool isNSFWAllowed =
                                      isNSFW && isNSFWFilterTurnOn;

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          GridTile(
                                            child: GestureDetector(
                                              onTap: () {
                                                if (currentUser!=null){
                                                if (!isNSFWAllowed) {
                                                  FocusScope.of(context)
                                                      .unfocus();
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          CollectionViewingScreen(
                                                        userId: collection
                                                            .userData.id!,
                                                        collection: collection,
                                                        isInSavedCollections:
                                                            false,
                                                      ),
                                                    ),
                                                  );
                                                }}else {
                                                  showAttentionMessage(
                                                      context: context,
                                                      title:
                                                      'Please sign in to view this collection.');
                                                }
                                              },
                                              child: RadiusTile(
                                                presentationUrl:
                                                    collectionPostImages,
                                                tileDominantColor:
                                                    collectionDominantColor,
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
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          '$shotsNumber shots',
                                          style: AppTheme.blackHeaderStyle
                                              .copyWith(
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
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
