

import 'package:socialapp/data/sources/dynamic_link/dynamic_link_service.dart';
import 'package:socialapp/domain/repository/auth/deep_link_repository.dart';
import 'package:socialapp/service_locator.dart';

class DynamicLinkRepositoryImpl extends DynamicLinkRepository{
  @override
  Future<void> generateVerifyLink(String otp) async {
    // serviceLocator<DynamicLinkService>() = abstract class DynamicLinkService
    return await serviceLocator<DynamicLinkService>().generateVerifyLink(otp);
  }
}