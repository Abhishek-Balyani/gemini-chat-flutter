import 'dart:async';
import 'package:get/get.dart';
import '../../modules/auth/services/firebase_auth_service.dart';

class SplashController extends GetxController {
  StreamSubscription? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }

  void _checkAuthState() {
    final authService = Get.find<BaseAuthService>();
    _authSubscription = authService.authStateChanges.listen((user) {
      _authSubscription?.cancel();
      if (user != null) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/auth/login');
      }
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
