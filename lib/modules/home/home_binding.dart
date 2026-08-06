import 'package:get/get.dart';
import '../chat/chat_controller.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController());
    Get.put<ChatController>(ChatController());
  }
}
