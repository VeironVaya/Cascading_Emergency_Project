import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../services/firebase_auth_service.dart';

class HomeController extends GetxController {
  final groups = <Map>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserGroups();
  }

  void loadUserGroups() async {
    final uid = FirebaseAuthService.currentUser?.uid;
    if (uid == null) return;

    isLoading.value = true;
    groups.clear();

    final groupsRef = FirebaseDatabase.instance.ref("groups");

    groupsRef.onValue.listen((event) {
      groups.clear();

      final data = event.snapshot.value;
      if (data == null) {
        isLoading.value = false;
        return;
      }

      final map = data as Map;

      map.forEach((key, value) {
        final group = Map<String, dynamic>.from(value);

        // CEK apakah user adalah member
        if (group["members"] != null && group["members"][uid] == true) {
          groups.add(group);
        }
      });

      isLoading.value = false;
    });
  }
}
