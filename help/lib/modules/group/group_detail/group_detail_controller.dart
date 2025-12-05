import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../services/firebase_auth_service.dart';

class GroupDetailController extends GetxController {
  final groupId = ''.obs;
  final group = Rxn<Map>();
  final isLoading = false.obs;

  late DatabaseReference groupRef;

  @override
  void onInit() {
    super.onInit();

    groupId.value = Get.arguments["groupId"];
    groupRef = FirebaseDatabase.instance.ref("groups/${groupId.value}");

    loadGroup();
  }

  void loadGroup() {
    isLoading.value = true;

    groupRef.onValue.listen((event) {
      final data = event.snapshot.value;

      if (data == null) {
        group.value = null;
      } else if (data is Map) {
        group.value = data;
      }

      isLoading.value = false;
    });
  }

  Future<void> leaveGroup() async {
    final uid = FirebaseAuthService.currentUser?.uid;
    if (uid == null) return;

    try {
      await groupRef.child("members/$uid").remove();

      final groupId = groupRef.key;
      if (groupId != null) {
        await FirebaseDatabase.instance
            .ref("userGroups/$uid/$groupId")
            .remove();
      }

      Get.back();
      Get.snackbar("Success", "Berhasil keluar dari group");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
