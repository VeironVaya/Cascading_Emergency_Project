import 'package:get/get.dart';
import 'priority_controller.dart';

class PriorityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PriorityController>(() => PriorityController());
  }
}
