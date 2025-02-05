import 'package:socialapp/utils/import.dart';
import '../cubit/collection_picker_cubit.dart';
import '../cubit/collection_picker_state.dart';

const double customIconSize = 35.0;

class CollectionPickerDialog extends StatefulWidget {
  final String userId;
  final int? selectedAssetOrder;
  final String postId;
  final Map<String, OnlineMediaItem> medias;

  const CollectionPickerDialog({
    super.key,
    required this.userId,
    this.selectedAssetOrder,
    required this.postId,
    required this.medias,
  });

  @override
  State<CollectionPickerDialog> createState() => _CollectionPickerDialogState();
}

class _CollectionPickerDialogState extends State<CollectionPickerDialog> {
  late double deviceHeight;
  final Set<CollectionModel> _selectedCollections = {};

  void _toggleSelection(CollectionModel collection) {
    setState(() {
      if (_selectedCollections.contains(collection)) {
        _selectedCollections.remove(collection);
      } else {
        _selectedCollections.add(collection);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final flutterView = PlatformDispatcher.instance.views.first;
    deviceHeight = flutterView.physicalSize.height;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      insetPadding: EdgeInsets.symmetric(
        vertical: deviceHeight * 0.08,
        horizontal: deviceHeight * 0.02,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: BlocProvider(
        create: (context) => CollectionPickerCubit(userId: widget.userId),
        child: BlocBuilder<CollectionPickerCubit, CollectionPickerState>(
          builder: (context, state) {
            if (state is CollectionPickerPostLoaded) {
              return SizedBox(
                height: deviceHeight * 0.6, // 60% of screen height
                child: Column(
                  children: [
                    // Header row with title and cancel (cross) icon.
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Select Collections To Save",
                            style: AppTheme.blackHeaderStyle.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: AppColors.blackOak,
                                size: customIconSize),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    if (state.collections.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.collections.length,
                          itemBuilder: (context, index) {
                            CollectionModel collection =
                                state.collections[index];
                            bool isSelected =
                                _selectedCollections.contains(collection);

                            return ListTile(
                              onTap: () => _toggleSelection(collection),
                              leading: Checkbox(
                                value: isSelected,
                                onChanged: (bool? newVal) {
                                  _toggleSelection(collection);
                                },
                              ),
                              title: Text(
                                collection.title,
                                style: AppTheme.blackHeaderStyle
                                    .copyWith(fontSize: 18),
                              ),
                            );
                          },
                        ),
                      )
                    else
                       Expanded(
                        child: Center(
                          child: Text('No Collection To Add', style: AppTheme.blackHeaderStyle
                              .copyWith(fontSize: 18),),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) => CreateCollectionDialog(
                                  userId: widget.userId,
                                  postId: widget.postId,
                                  assets: widget.medias,
                                  selectedAssetOrder: widget.selectedAssetOrder,
                                ),
                              );
                            },
                            child: const Text(
                              "Create New Collection",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              for (CollectionModel collection
                                  in _selectedCollections) {
                                context
                                    .read<CollectionPickerCubit>()
                                    .addToCollection(
                                        collection,
                                        widget.postId,
                                        widget.selectedAssetOrder,
                                        widget.medias);
                              }
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Confirm",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

class CreateCollectionDialog extends StatefulWidget {
  final String userId;
  final int? selectedAssetOrder;
  final String postId;
  final Map<String, OnlineMediaItem> assets;

  const CreateCollectionDialog({
    super.key,
    required this.userId,
    this.selectedAssetOrder,
    required this.postId,
    required this.assets,
  });

  @override
  State<CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<CreateCollectionDialog> {
  final TextEditingController _collectionNameController =
      TextEditingController();
  bool _isPublic = true;
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _collectionNameController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _collectionNameController.removeListener(_onTextChanged);
    _collectionNameController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _collectionNameController.text.trim().isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: BlocProvider(
        create: (context) => CollectionPickerCubit(userId: widget.userId),
        child: BlocBuilder<CollectionPickerCubit, CollectionPickerState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Create New Collection",
                        style: AppTheme.blackHeaderStyle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Collection name input field with onChanged callback
                  TextField(
                    controller: _collectionNameController,
                    onChanged: (text) => _onTextChanged(),
                    decoration: InputDecoration(
                      labelText: "Collection Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Public Collection Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Public Collection",
                          style: TextStyle(fontSize: 20)),
                      Switch(
                        value: _isPublic,
                        onChanged: (value) {
                          setState(() {
                            _isPublic = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Create Collection button with opacity control
                  SizedBox(
                    width: double.infinity,
                    child: Opacity(
                      opacity: _isButtonEnabled ? 1.0 : 0.5,
                      child: ElevatedButton(
                        onPressed: _isButtonEnabled
                            ? () async {
                                await context
                                    .read<CollectionPickerCubit>()
                                    .createCollection(
                                      _collectionNameController,
                                      _isPublic,
                                    );

                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) => CollectionPickerDialog(
                                    userId: widget.userId,
                                    postId: widget.postId,
                                    medias: widget.assets,
                                    selectedAssetOrder:
                                        widget.selectedAssetOrder,
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.iris,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          "Create Collection",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
