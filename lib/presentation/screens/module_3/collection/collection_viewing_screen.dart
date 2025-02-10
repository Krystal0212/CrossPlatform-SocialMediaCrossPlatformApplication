import 'dart:ui';

import 'package:socialapp/utils/import.dart';

import '../../../widgets/general/nsfw_and_close_icons.dart';
import 'cubit/collection_viewing_cubit.dart';
import 'cubit/collection_viewing_state.dart';

class CollectionViewingScreen extends StatelessWidget {
  final String userId;
  final CollectionModel collection;
  final bool isInSavedCollections;

  const CollectionViewingScreen(
      {super.key,
      required this.userId,
      required this.collection,
      required this.isInSavedCollections});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) =>
            CollectionViewingCubit(userId: userId, collection: collection),
        child: CollectionBase(
          collectionTitle: collection.title,
          isInSavedCollections: isInSavedCollections,
        ));
  }
}

class CollectionBase extends StatefulWidget {
  final String collectionTitle;
  final bool isInSavedCollections;

  const CollectionBase(
      {super.key,
      required this.collectionTitle,
      required this.isInSavedCollections});

  @override
  State<CollectionBase> createState() => _CollectionBaseState();
}

enum EditingMode { cancel, finish, editing, none }

class _CollectionBaseState extends State<CollectionBase> with FlashMessage {
  late double deviceWidth = 0;
  final ValueNotifier<String> collectionTitleNotifier =
      ValueNotifier<String>('');
  final ValueNotifier<EditingMode> editingModeNotifier =
      ValueNotifier<EditingMode>(EditingMode.none);

  final ValueNotifier<List<PreviewAssetPostModel>> imageDataPreviewsNotifier =
      ValueNotifier<List<PreviewAssetPostModel>>([]);

  @override
  void initState() {
    super.initState();

    final flutterView = PlatformDispatcher.instance.views.first;
    deviceWidth = flutterView.physicalSize.width / flutterView.devicePixelRatio;
    collectionTitleNotifier.value = widget.collectionTitle;
  }

  @override
  void dispose() {
    collectionTitleNotifier.dispose();
    imageDataPreviewsNotifier.dispose();
    super.dispose();
  }

  void showEditTitleDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        TextEditingController nameController =
            TextEditingController(text: widget.collectionTitle);
        String? errorMessage;

        return StatefulBuilder(
          builder: (_, setState) {
            return AlertDialog(
              backgroundColor: AppColors.white,
              title: const Text("Edit Collection Name"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Enter new collection name",
                      border: const OutlineInputBorder(),
                      errorText: errorMessage, // Shows error if null
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    String newName = nameController.text.trim();
                    if (newName.isEmpty) {
                      setState(() {
                        errorMessage = "Title cannot be empty";
                      });
                      return;
                    }

                    context
                        .read<CollectionViewingCubit>()
                        .updateCollectionName(newName);
                    collectionTitleNotifier.value = newName;
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text("Save",
                      style: TextStyle(color: AppColors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> showRemoveCurrentUserCollectionDialog() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text(
              "Are you sure that you want to remove this collection?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                context
                    .read<CollectionViewingCubit>()
                    .removeCurrentUserCollectionFromCurrentUser();
                Navigator.of(dialogContext).pop(true);
              },
              child:
                  const Text("Yes", style: TextStyle(color: AppColors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> showRemoveOtherUserCollectionDialog() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text(
              "Are you sure that you want to remove this collection?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                context
                    .read<CollectionViewingCubit>()
                    .removeOtherUserCollectionFormCurrentUser();
                Navigator.of(dialogContext).pop(true);
              },
              child:
                  const Text("Yes", style: TextStyle(color: AppColors.white)),
            ),
          ],
        );
      },
    );
  }

  void showCollectionOptionsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text("Collection Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text("Change Collection Name"),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                  showEditTitleDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
                title: const Text("Adjust Collection"),
                onTap: () {
                  editingModeNotifier.value = EditingMode.editing;
                  Navigator.of(dialogContext).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text("Cancel"),
                onTap: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool?> showCollectionOptionsDialogForNotOwner() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.white,
          title: const Text("Collection Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!widget.isInSavedCollections)
                ListTile(
                  leading: const Icon(
                    Icons.data_saver_on,
                  ),
                  title: const Text("Add to your collections storage"),
                  onTap: () {
                    context
                        .read<CollectionViewingCubit>()
                        .updateCollectionData(imageDataPreviewsNotifier.value);
                    showSuccessMessage(
                        context: context,
                        title: 'Added to your collections storage');
                    Navigator.of(dialogContext).pop(true);
                  },
                )
              else
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                  ),
                  title: const Text("Remove from collections storage"),
                  onTap: () async {
                    bool? result = await showRemoveOtherUserCollectionDialog();
                    if (result == true) {
                      if (!context.mounted) return;
                      Navigator.of(dialogContext).pop(true);
                    } else {
                      if (!context.mounted) return;
                      Navigator.of(dialogContext).pop(false);
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.cancel_outlined),
                title: const Text("Cancel"),
                onTap: () {
                  Navigator.of(dialogContext).pop(false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showImageDialog(
    BuildContext context,
    String imageUrl,
    Color dominantColor,
    String? videoUrl,
    bool isVideo,
    double height,
    double width,
    bool isNSFWAllowed,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        final flutterView = PlatformDispatcher.instance.views.first;
        final deviceWidth =
            flutterView.physicalSize.width / flutterView.devicePixelRatio;
        final deviceHeight =
            flutterView.physicalSize.height / flutterView.devicePixelRatio;

        double scaleRatio = 0.75;

        // Calculate the aspect ratio (width/height)
        double imageAspectRatio =
            width / height; // Replace with actual image's width/height

        // Padding based on aspect ratio, ensuring the image fits the dialog
        double horizontalPadding = (deviceWidth * scaleRatio) * 0.1;
        double verticalPadding = horizontalPadding;

        // If image is landscape (aspect ratio > 1), adjust the padding so it doesn't overflow
        if (imageAspectRatio > 1) {
          verticalPadding = deviceHeight * scaleRatio * 0.1;
        } else {
          horizontalPadding = deviceWidth * scaleRatio * 0.1;
        }

        return Center(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: (isVideo)
                  ? VideoPlayerWidget(
                      videoUrl: videoUrl,
                      height: height,
                      width: width,
                      dominantColor: dominantColor,
                      isNSFWAllowed: isNSFWAllowed,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => Container(
                          color: dominantColor,
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.only(
              top: 30, left: deviceWidth * 0.07, right: deviceWidth * 0.07),
          child: SingleChildScrollView(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: deviceWidth * 0.9,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              size: 35, color: AppColors.blackOak),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Expanded(
                          child: ValueListenableBuilder(
                            valueListenable: collectionTitleNotifier,
                            builder: (context, title, _) {
                              return Text(
                                title,
                                style: AppTheme.blackUsernameMobileStyle
                                    .copyWith(fontSize: 24),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              );
                            },
                          ),
                        ),
                        BlocBuilder<CollectionViewingCubit,
                            CollectionViewingState>(builder: (context, state) {
                          if (state is CollectionViewingLoaded) {
                            if (state.isOwner) {
                              return ValueListenableBuilder<EditingMode>(
                                  valueListenable: editingModeNotifier,
                                  builder: (context, isEditing, child) {
                                    if (isEditing == EditingMode.editing) {
                                      return Row(
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              bool? result =
                                                  await showRemoveCurrentUserCollectionDialog();
                                              if (result == true) {
                                                if (!context.mounted) return;
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            icon: const Icon(
                                                Icons.delete_outline_rounded,
                                                size: 35,
                                                color: AppColors.blackOak),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.save_outlined,
                                                size: 35,
                                                color: AppColors.blackOak),
                                            onPressed: () {
                                              context
                                                  .read<
                                                      CollectionViewingCubit>()
                                                  .updateCollectionData(
                                                      imageDataPreviewsNotifier
                                                          .value);
                                              editingModeNotifier.value =
                                                  EditingMode.finish;
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.cancel_outlined,
                                                size: 35,
                                                color: AppColors.blackOak),
                                            onPressed: () {
                                              editingModeNotifier.value =
                                                  EditingMode.cancel;
                                            },
                                          ),
                                        ],
                                      );
                                    } else {
                                      return IconButton(
                                        icon: const Icon(
                                            Icons.settings_outlined,
                                            size: 35,
                                            color: AppColors.blackOak),
                                        onPressed: () {
                                          showCollectionOptionsDialog();
                                        },
                                      );
                                    }
                                  });
                            } else {
                              return IconButton(
                                icon: const Icon(Icons.settings_outlined,
                                    size: 35, color: AppColors.blackOak),
                                onPressed: () async {
                                  bool? isTrue =
                                      await showCollectionOptionsDialogForNotOwner();

                                  if (isTrue == true) {
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop();
                                  }
                                },
                              );
                            }
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  // Spacing between title and content

                  BlocBuilder<CollectionViewingCubit, CollectionViewingState>(
                    builder: (context, state) {
                      if (state is CollectionViewingLoaded) {
                        if (state.imagePreviews.isEmpty) {
                          return Center(
                              child: SvgPicture.asset(AppImages.empty));
                        }

                        imageDataPreviewsNotifier.value =
                            List.from(state.imagePreviews);

                        editingModeNotifier.addListener(() {
                          if (editingModeNotifier.value == EditingMode.cancel) {
                            imageDataPreviewsNotifier.value =
                                List.from(state.imagePreviews);
                          }
                        });

                        return ValueListenableBuilder<
                                List<PreviewAssetPostModel>>(
                            valueListenable: imageDataPreviewsNotifier,
                            builder: (context, imageDataPreviews, child) {
                              return MasonryGridView.count(
                                shrinkWrap: true,
                                crossAxisCount: 2,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: imageDataPreviews.length,
                                mainAxisSpacing: 16.0,
                                crossAxisSpacing: 16.0,
                                itemBuilder: (context, index) {
                                  if (index < imageDataPreviews.length) {
                                    bool isVideo =
                                        imageDataPreviews[index].isVideo;
                                    bool isNSFW =
                                        imageDataPreviews[index].isNSFW;
                                    Color dominantColor = Color(int.parse(
                                        '0x${imageDataPreviews[index].dominantColor}'));
                                    String imageUrl = imageDataPreviews[index]
                                        .mediasOrThumbnailUrl;
                                    bool isNSFWAllowed =
                                        isNSFW && state.isNSFWTurnOn;

                                    double imageWidth = imageDataPreviews[index]
                                        .width
                                        .toDouble();
                                    double imageHeight =
                                        imageDataPreviews[index]
                                            .height
                                            .toDouble();
                                    double aspectRatio =
                                        imageWidth / imageHeight;

                                    final ValueNotifier<bool>
                                        isBlurredNotifier =
                                        ValueNotifier<bool>(true);

                                    return InkWell(
                                      onTap: () {
                                        showImageDialog(
                                          context,
                                          imageUrl,
                                          dominantColor,
                                          imageDataPreviews[index].videoUrl,
                                          isVideo,
                                          imageHeight,
                                          imageWidth,
                                          isNSFWAllowed,
                                        );
                                      },
                                      child: AspectRatio(
                                        aspectRatio: aspectRatio,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    imageDataPreviews[index]
                                                        .mediasOrThumbnailUrl,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    Container(
                                                  color: AppColors.blackOak,
                                                  child: const Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              ),
                                            ),

                                            // Show Play Icon if it's a video
                                            if (isVideo)
                                              const Icon(
                                                Icons.play_circle_fill,
                                                size: 50,
                                                color: Colors.white,
                                              ),

                                            // Apply NSFW Blur Overlay with Gesture Detection
                                            if (isNSFW)
                                              ValueListenableBuilder<bool>(
                                                valueListenable:
                                                    isBlurredNotifier,
                                                builder: (context, isBlurred,
                                                    child) {
                                                  return GestureDetector(
                                                    onTap: () =>
                                                        isBlurredNotifier
                                                            .value = false,
                                                    // Toggle blur
                                                    child: Stack(
                                                      children: [
                                                        TweenAnimationBuilder<
                                                            double>(
                                                          duration:
                                                              const Duration(
                                                                  milliseconds:
                                                                      500),
                                                          // Smooth transition
                                                          tween: Tween<double>(
                                                              begin: isBlurred
                                                                  ? 10.0
                                                                  : 10.0,
                                                              end: isBlurred
                                                                  ? 10.0
                                                                  : 0.0),
                                                          builder: (context,
                                                              blurValue,
                                                              child) {
                                                            return AnimatedOpacity(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          4300),
                                                              opacity: isBlurred
                                                                  ? 1.0
                                                                  : 0.0,
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                child:
                                                                    BackdropFilter(
                                                                  filter:
                                                                      ImageFilter
                                                                          .blur(
                                                                    sigmaX:
                                                                        blurValue,
                                                                    sigmaY:
                                                                        blurValue,
                                                                  ),
                                                                  child:
                                                                      Container(
                                                                    color: dominantColor.withOpacity(
                                                                        isBlurred
                                                                            ? 0.7
                                                                            : 0.0),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: isBlurred
                                                                        ? Text(
                                                                            'NSFW Content',
                                                                            style:
                                                                                AppTheme.nsfwWhiteText,
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                          )
                                                                        : null,
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),

                                            ValueListenableBuilder<EditingMode>(
                                              valueListenable:
                                                  editingModeNotifier,
                                              builder:
                                                  (context, isEditing, child) {
                                                return (isEditing ==
                                                        EditingMode.editing)
                                                    ? Positioned(
                                                        top: 10,
                                                        right: 10,
                                                        child: CloseIconButton(
                                                          onTap: () {
                                                            imageDataPreviewsNotifier
                                                                .value
                                                                .removeAt(
                                                                    index);

                                                            imageDataPreviewsNotifier
                                                                    .value =
                                                                List.from(
                                                                    imageDataPreviewsNotifier
                                                                        .value);
                                                          },
                                                        ),
                                                      )
                                                    : const SizedBox.shrink();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                              );
                            });
                      }
                      return Center(child: SvgPicture.asset(AppImages.empty));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
