import 'package:get/get.dart';
import 'handle_emergency_controller.dart';

class HandleEmergencyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HandleEmergencyController>(() => HandleEmergencyController());
  }
}
