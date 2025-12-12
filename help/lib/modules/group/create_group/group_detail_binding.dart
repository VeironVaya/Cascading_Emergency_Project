import 'package:get/get.dart';
import 'package:project_hellping/modules/group/create_group/group_controller.dart';

class GroupDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupController>(() => GroupController());
  }
}
