// Core Flutter and third-party dependencies
export 'dart:io';
export 'dart:math';
export 'dart:async';
export 'dart:convert';
export 'package:flutter/material.dart';
export 'package:flutter/physics.dart';
export 'package:workmanager/workmanager.dart';
export 'package:connectivity_plus/connectivity_plus.dart';
export 'package:image_picker/image_picker.dart';
export 'package:shared_preferences/shared_preferences.dart';
export 'package:firebase_core/firebase_core.dart';
export 'package:flutter/gestures.dart';
export 'package:flutter_native_splash/flutter_native_splash.dart';
export 'package:hydrated_bloc/hydrated_bloc.dart';
export 'package:path_provider/path_provider.dart';
export 'package:get_it/get_it.dart';
export 'package:flutter/foundation.dart';
export 'package:app_links/app_links.dart';
export 'package:flutter/services.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:flutter_svg/svg.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:firebase_storage/firebase_storage.dart';
export 'package:google_sign_in/google_sign_in.dart';
export 'package:go_router/go_router.dart';
export 'package:cached_network_image/cached_network_image.dart';
export 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
export 'package:cloud_firestore/cloud_firestore.dart'
    show
        FirebaseFirestore,
        CollectionReference,
        DocumentSnapshot,
        QuerySnapshot,
        DocumentReference,
        Timestamp,
        Query,
        WriteBatch,
        AggregateQuerySnapshot,
        FieldValue,
        QueryDocumentSnapshot;
export 'package:image/image.dart' show decodeImage, copyResize, encodeJpg;
export 'package:like_button/like_button.dart';
export 'package:pulp_flash/pulp_flash.dart';

// App Configurations
export 'package:socialapp/config/platforms.dart';
export 'package:socialapp/config/app_routes.dart';
export 'package:socialapp/service_locator.dart';

// Utilities
export 'package:socialapp/utils/styles/themes.dart';
export 'package:socialapp/utils/styles/colors.dart';
export 'package:socialapp/utils/styles/text_style.dart';
export 'package:socialapp/utils/constants/icon_path.dart';
export 'package:socialapp/utils/constants/strings.dart';
export 'package:socialapp/utils/constants/image_path.dart';
export 'package:socialapp/utils/mixin/validators/validators.dart';
export 'package:socialapp/utils/mixin/methods/alert_dialog.dart';
export 'package:socialapp/utils/mixin/methods/convert_timestamp.dart';

// Data and Repositories
export 'package:socialapp/data/models/auth/sign_in_user_req.dart';
export 'package:socialapp/data/models/auth/create_user_req.dart';

export 'package:socialapp/data/repository/collection/collection_repository_impl.dart';
export 'package:socialapp/data/repository/post/post_repository_impl.dart';
export 'package:socialapp/data/repository/topic/topic_repository_impl.dart';
export 'package:socialapp/data/repository/auth/auth_repository_impl.dart';
export 'package:socialapp/data/repository/user/user_repository_impl.dart';
export 'package:socialapp/data/repository/deep_link/deep_link_repository_impl.dart';
export 'package:socialapp/data/sources/auth/auth_firebase_service.dart';
export 'package:socialapp/data/sources/firestore/firestore_service.dart';
export 'package:socialapp/data/sources/firestore/user_service_impl.dart';
export 'package:socialapp/data/sources/storage/storage_service.dart';
export 'package:socialapp/data/sources/deep_link/deep_link_service.dart';
export 'package:socialapp/data/sources/firestore/collection_service_impl.dart';
export 'package:socialapp/data/sources/firestore/post_service_impl.dart';

// Domain
export 'package:socialapp/domain/repository/post/post_repository.dart';
export 'package:socialapp/domain/repository/topic/topic_repository.dart';
export 'package:socialapp/domain/repository/auth/auth_repository.dart';
export 'package:socialapp/domain/repository/collection/collection_repository.dart';
export 'package:socialapp/domain/repository/user/user_repository.dart';
export 'package:socialapp/domain/repository/deep_link/deep_link_repository.dart';
export 'package:socialapp/domain/entities/user.dart';
export 'package:socialapp/domain/entities/collection.dart';
export 'package:socialapp/domain/entities/topic.dart';
export 'package:socialapp/domain/entities/post.dart';
export 'package:socialapp/domain/entities/comment.dart';

// Presentation Screens and Self Widgets
export 'package:socialapp/presentation/screens/module_1/module_1_exports.dart';
export 'package:socialapp/presentation/screens/module_2/module_2_exports.dart';
export 'package:socialapp/presentation/screens/module_3/module_3_exports.dart';
export 'package:socialapp/presentation/screens/module_4/module_4_exports.dart';

// General Widgets
export 'package:socialapp/presentation/widgets/general/custom_scroll_view.dart';
export 'package:socialapp/presentation/widgets/general/custom_container.dart';
export 'package:socialapp/presentation/widgets/general/custom_sized_box.dart';
export 'package:socialapp/presentation/widgets/general/custom_placeholder.dart';
export 'package:socialapp/presentation/widgets/general/custom_alert_dialog.dart';
export 'package:socialapp/presentation/widgets/auth/auth_body.dart';
export 'package:socialapp/presentation/widgets/auth/auth_elevated_button.dart';
export 'package:socialapp/presentation/widgets/auth/auth_header_image.dart';
export 'package:socialapp/presentation/widgets/auth/auth_text_form_field.dart';
export 'package:socialapp/presentation/widgets/general/linear_gradient_title.dart';
export 'package:socialapp/presentation/widgets/forgot_password/message_content.dart';
export 'package:socialapp/presentation/widgets/forgot_password/stacks_bottom.dart';
export 'package:socialapp/presentation/widgets/edit_profile/app_text_form_field.dart';
export 'package:socialapp/presentation/widgets/chat/chat_bubble.dart';
