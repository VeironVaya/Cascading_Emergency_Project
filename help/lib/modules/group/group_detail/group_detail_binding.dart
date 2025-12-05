import 'package:get/get.dart';
import 'package:project_hellping/modules/group/group_detail/group_detail_controller.dart';

class GroupDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GroupDetailController>(() => GroupDetailController());
  }
}
