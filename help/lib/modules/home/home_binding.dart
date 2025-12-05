import 'package:get/get.dart';
import 'package:project_hellping/modules/emergency/emergency_controller.dart';
import 'package:project_hellping/modules/priority/priority_controller.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<EmergencyController>(() => EmergencyController());
    Get.lazyPut<PriorityController>(() => PriorityController());
  }
}
