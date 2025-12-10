import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../services/firebase_auth_service.dart';

class GroupDetailController extends GetxController {
  final groupId = ''.obs;
  final group = Rxn<Map>();
  final isLoading = false.obs;
  final membersCondition = <String, String>{}.obs;
  late DatabaseReference groupRef;

  /// uid -> username
  final membersData = <String, String>{}.obs;

  /// owner username
  final ownerName = ''.obs;

  @override
  void onInit() {
    super.onInit();

    groupId.value = Get.arguments["groupId"];
    groupRef = FirebaseDatabase.instance.ref("groups/${groupId.value}");

    loadGroup();
  }

  /// ============================
  /// LOAD GROUP + MEMBERS + OWNER
  /// ============================
  void loadGroup() {
    isLoading.value = true;

    groupRef.onValue.listen((event) async {
      final data = event.snapshot.value;

      if (data == null || data is! Map) {
        group.value = null;
        isLoading.value = false;
        return;
      }

      group.value = data;

      final members = (data["members"] ?? {}) as Map;
      final ownerId = data["ownerId"];

      membersData.clear();
      membersCondition.clear();
      ownerName.value = "Unknown";

      // Ambil semua user
      final allUsersSnap = await FirebaseDatabase.instance.ref("users").get();

      Map allUsers = {};
      if (allUsersSnap.exists && allUsersSnap.value is Map) {
        allUsers = allUsersSnap.value as Map;
      }

      for (final uid in members.keys) {
        // ===== Ambil username =====
        membersData[uid] = allUsers[uid]?["username"] ?? uid;

        // ===== Ambil daily condition terakhir =====
        final dailyStatus = allUsers[uid]?["dailyStatus"];
        if (dailyStatus != null && dailyStatus is Map) {
          membersCondition[uid] = dailyStatus["condition"] ?? "❓";
        } else {
          membersCondition[uid] = "❓"; // default jika belum ada
        }
      }

      // Ambil owner username
      if (ownerId != null && allUsers.containsKey(ownerId)) {
        ownerName.value = allUsers[ownerId]["username"] ?? "Unknown";
      }

      isLoading.value = false;
    });
  }

  /// ============================
  /// UPDATE GROUP NAME
  /// ============================
  Future<void> updateGroupName(String newName) async {
    if (newName.isEmpty) return;

    try {
      await groupRef.update({"name": newName});
      Get.snackbar("Success", "Nama group berhasil diperbarui");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// ============================
  /// DELETE GROUP (HANYA OWNER)
  /// ============================
  Future<void> deleteGroup() async {
    final uid = FirebaseAuthService.currentUser?.uid;
    final data = group.value;

    if (uid == null || data == null) return;

    if (uid != data["ownerId"]) {
      Get.snackbar("Error", "Hanya owner yang boleh menghapus group");
      return;
    }

    try {
      final members = (data["members"] ?? {}) as Map;

      // Hapus dari userGroups semua anggota
      for (final mid in members.keys) {
        await FirebaseDatabase.instance
            .ref("userGroups/$mid/${groupId.value}")
            .remove();
      }

      // Hapus group
      await groupRef.remove();

      Get.back();
      Get.snackbar("Success", "Group berhasil dihapus");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  /// ============================
  /// LEAVE GROUP
  /// ============================
  Future<void> leaveGroup() async {
    final uid = FirebaseAuthService.currentUser?.uid;
    if (uid == null) return;

    final data = group.value;

    if (data == null) return;

    // Owner tidak boleh keluar
    if (uid == data["ownerId"]) {
      Get.snackbar("Error", "Owner tidak bisa keluar dari group");
      return;
    }

    try {
      // Hapus dari group.members
      await groupRef.child("members/$uid").remove();

      // Hapus dari userGroups
      await FirebaseDatabase.instance
          .ref("userGroups/$uid/${groupId.value}")
          .remove();

      Get.back();
      Get.snackbar("Success", "Berhasil keluar dari group");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}
