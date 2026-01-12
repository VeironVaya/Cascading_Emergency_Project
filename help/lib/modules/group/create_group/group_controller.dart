import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_hellping/routes/app_routes.dart';
import 'package:uuid/uuid.dart';
import '../../../services/firebase_auth_service.dart';

class GroupController extends GetxController {
  final name = ''.obs;
  final _db = FirebaseDatabase.instance.ref();
  RxString code = ''.obs;

  RxBool isLoading = false.obs;

  String _generateCode() {
    final id = const Uuid().v4().replaceAll('-', '').toUpperCase();
    return id.substring(0, 6);
  }

  Future<void> create() async {
    final user = FirebaseAuthService.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User belum login');
      return;
    }
    if (name.value.trim().isEmpty) {
      Get.snackbar('Error', 'Nama group tidak boleh kosong');
      return;
    }
    try {
      isLoading.value = true;
      final code = _generateCode();
      final newGroupRef = _db.child("groups").push();
      final data = {
        "id": newGroupRef.key,
        "name": name.value.trim(),
        "code": code,
        "ownerId": user.uid,
        "members": {user.uid: true},
        "createdAt": ServerValue.timestamp,
      };
      await newGroupRef.set(data);
      Get.snackbar("Sukses", "Group dibuat. Kode: $code");
      Get.offAllNamed(
        AppRoutes.USER_GROUP,
        arguments: {"groupId": newGroupRef.key},
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserGroups() async {
    final user = FirebaseAuthService.currentUser;
    if (user == null) return [];

    final snapshot = await _db.child("groups").get();
    if (!snapshot.exists) return [];

    final Map<String, dynamic> allGroups =
        Map<String, dynamic>.from(snapshot.value as Map);

    List<Map<String, dynamic>> userGroups = [];

    for (final entry in allGroups.entries) {
      final groupId = entry.key;
      final group = Map<String, dynamic>.from(entry.value);

      final members = Map<String, dynamic>.from(group['members'] ?? {});

      if (members.containsKey(user.uid) || group['ownerId'] == user.uid) {
        // 🔥 AMBIL DETAIL GROUP (INI KUNCINYA)
        final detail = await getGroupDetails(groupId);
        if (detail != null) {
          userGroups.add(detail);
        }
      }
    }

    return userGroups;
  }

  Future<String?> joinGroup(String code) async {
    final user = FirebaseAuthService.currentUser;

    // Cek user login
    if (user == null) {
      Get.snackbar("Error", "User belum login");
      return null;
    }

    // Cek input kosong
    if (code.trim().isEmpty) {
      Get.snackbar("Error", "Kode tidak boleh kosong");
      return null;
    }

    final snapshot =
        await _db.child("groups").orderByChild("code").equalTo(code).get();

    if (!snapshot.exists || snapshot.value == null) {
      Get.snackbar("Error", "Kode grup tidak ditemukan");
      return null;
    }

    // Pastikan snapshot adalah Map
    final rawData = snapshot.value;

    if (rawData is! Map) {
      Get.snackbar("Error", "Data grup tidak valid");
      return null;
    }

    // Konversi ke Map<String, dynamic>
    final Map<String, dynamic> groups =
        Map<String, dynamic>.from(rawData as Map);

    // Ambil key grup pertama (karena equalTo pasti hanya 1)
    final String groupKey = groups.keys.first;

    // Ambil detail group
    final groupData = groups[groupKey];
    if (groupData is! Map) {
      Get.snackbar("Error", "Format data grup tidak valid");
      return null;
    }

    final Map<String, dynamic> group = Map<String, dynamic>.from(groupData);

    // ===========================
    // Cek status user di grup
    // ===========================

    // Cek owner
    if (group["ownerId"] == user.uid) {
      Get.snackbar("Info", "Kamu adalah owner grup ini");
      return groupKey;
    }

    // Cek member
    final membersRaw = group["members"];
    final members = membersRaw is Map
        ? Map<String, dynamic>.from(membersRaw)
        : <String, dynamic>{};

    if (members.containsKey(user.uid)) {
      Get.snackbar("Info", "Kamu sudah berada dalam grup ini");
      return groupKey;
    }

    // ===========================
    // Tambahkan user sebagai member baru
    // ===========================
    await _db.child("groups/$groupKey/members/${user.uid}").set(true);

    Get.snackbar("Sukses", "Berhasil join grup");

    return groupKey;
  }

  Future<void> deleteGroup(String groupId) async {
    final user = FirebaseAuthService.currentUser;
    if (user == null) return;

    final snapshot = await _db.child("groups/$groupId").get();
    if (!snapshot.exists) return;

    final group = Map<String, dynamic>.from(snapshot.value as Map);

    if (group['ownerId'] != user.uid) {
      Get.snackbar("Error", "Hanya owner yang bisa menghapus grup");
      return;
    }

    await _db.child("groups/$groupId").remove();
    Get.snackbar("Sukses", "Group berhasil dihapus");
  }

  Future<void> removeMember(String groupId, String memberId) async {
    final user = FirebaseAuthService.currentUser;
    if (user == null) return;

    final snapshot = await _db.child("groups/$groupId").get();
    if (!snapshot.exists) return;

    final group = Map<String, dynamic>.from(snapshot.value as Map);

    if (group['ownerId'] != user.uid) {
      Get.snackbar("Error", "Hanya owner yang bisa menghapus member");
      return;
    }

    if (memberId == user.uid) {
      Get.snackbar("Error", "Owner tidak bisa menghapus diri sendiri");
      return;
    }

    await _db.child("groups/$groupId/members/$memberId").remove();
    Get.snackbar("Sukses", "Member berhasil dihapus");
  }

  Future<void> editGroupName(String groupId, String newName) async {
    final user = FirebaseAuthService.currentUser;
    if (user == null) return;

    final snapshot = await _db.child("groups/$groupId").get();
    if (!snapshot.exists) return;

    final group = Map<String, dynamic>.from(snapshot.value as Map);

    if (group['ownerId'] != user.uid) {
      Get.snackbar("Error", "Hanya owner yang bisa mengedit nama grup");
      return;
    }

    await _db.child("groups/$groupId/name").set(newName.trim());
    Get.snackbar("Sukses", "Nama grup berhasil diubah");
  }

  Future<Map<String, dynamic>?> getGroupDetails(String groupId) async {
    final snapshot = await _db.child("groups/$groupId").get();
    if (!snapshot.exists) return null;

    final group = Map<String, dynamic>.from(snapshot.value as Map);

    // Ambil username + condition member
    Map<String, Map<String, dynamic>> membersMap = {};
    if (group['members'] != null) {
      final members = Map<String, dynamic>.from(group['members']);
      for (var memberId in members.keys) {
        final userSnap = await _db.child("users/$memberId").get();
        if (userSnap.exists) {
          final userData = Map<String, dynamic>.from(userSnap.value as Map);
          membersMap[memberId] = {
            "username": userData['username'] ?? "Unknown",
            "condition": userData['dailyStatus'] != null
                ? userData['dailyStatus']['condition']
                : "Unknown",
          };
        } else {
          membersMap[memberId] = {
            "username": "Unknown",
            "condition": "Unknown"
          };
        }
      }
    }

    // Ambil username owner + condition
    final ownerSnap = await _db.child("users/${group['ownerId']}").get();
    final ownerData = ownerSnap.exists
        ? Map<String, dynamic>.from(ownerSnap.value as Map)
        : null;

    final ownerUsername = ownerData != null ? ownerData['username'] : "Unknown";
    final ownerCondition = ownerData != null && ownerData['dailyStatus'] != null
        ? ownerData['dailyStatus']['condition']
        : "Unknown";

    return {
      "id": groupId,
      "name": group['name'],
      "code": group['code'],
      "ownerId": group['ownerId'],
      "ownerUsername": ownerUsername,
      "ownerCondition": ownerCondition,
      "members": membersMap,
      "createdAt": group['createdAt'],
    };
  }

  Future<void> joinGroupNow() async {
    if (code.value.length != 6) {
      Get.snackbar("Error", "Kode harus 6 karakter");
      return;
    }

    final groupId = await joinGroup(code.value);

    if (groupId != null) {
      // Arahkan ke halaman CREATE_GROUP
      Get.toNamed(AppRoutes.USER_GROUP);
    }
  }
}
