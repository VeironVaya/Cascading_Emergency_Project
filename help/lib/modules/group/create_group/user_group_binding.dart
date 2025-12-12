import 'package:get/get.dart';
import 'group_controller.dart';

class UserGroupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupController>(() => GroupController());
  }
}
