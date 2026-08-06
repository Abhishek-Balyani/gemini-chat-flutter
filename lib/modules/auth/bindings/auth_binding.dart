import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../controllers/auth_controller.dart';
import '../repositories/auth_repository.dart';
import '../services/firebase_auth_service.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    final storageService = Get.find<StorageService>();
    final firebaseAuthService = Get.put<BaseAuthService>(FirebaseAuthService(), permanent: true);
    Get.put<AuthRepository>(AuthRepository(firebaseAuthService, storageService), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
