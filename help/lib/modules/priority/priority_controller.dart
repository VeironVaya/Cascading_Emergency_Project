import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PriorityController extends GetxController {
  final db = FirebaseDatabase.instance.ref();
  final auth = FirebaseAuth.instance;

  RxBool showDeleteMode = false.obs;
  RxBool showReorderMode = false.obs;

  RxList<Map<String, dynamic>> priorityList = <Map<String, dynamic>>[].obs;

  RxString searchUsername = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isAddMode = false.obs;

  RxSet<String> selectedIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPriorities();
  }

  void fetchPriorities() {
    final uid = auth.currentUser!.uid;

    db.child("users/$uid/priorities").onValue.listen((event) {
      priorityList.clear();
      if (event.snapshot.value == null) return;

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);

      data.forEach((key, value) {
        final v = Map<String, dynamic>.from(value);

        priorityList.add({
          'id': key,
          'targetUid': v['targetUid'],
          'targetUsername': v['targetUsername'],
          'email': v['email'] ?? "-", // ✔ FIX NULL EMAIL
          'priorityLevel': v['priorityLevel'],
          'fcmToken': v['fcmToken'] ?? "",
          'location': v['location'] ?? {},
          'avatarUrl': v['avatarUrl'] ?? "", // optional tambahan
        });
      });

      priorityList
          .sort((a, b) => a['priorityLevel'].compareTo(b['priorityLevel']));
    });
  }

  Future<void> addPriority() async {
    if (searchUsername.value.isEmpty) {
      Get.snackbar("Error", "Username tidak boleh kosong");
      return;
    }

    isLoading.value = true;

    try {
      final allUsers = await db.child("users").get();
      String? targetUid;

      for (var child in allUsers.children) {
        final user = Map<String, dynamic>.from(child.value as Map);
        if (user['username'] == searchUsername.value.trim()) {
          targetUid = child.key;
          break;
        }
      }

      if (targetUid == null) {
        Get.snackbar("Gagal", "Username tidak ditemukan");
        return;
      }

      final uid = auth.currentUser!.uid;

      if (targetUid == uid) {
        Get.snackbar("Gagal", "Tidak dapat menambahkan diri sendiri");
        return;
      }

      for (var p in priorityList) {
        if (p['targetUid'] == targetUid) {
          Get.snackbar("Gagal", "User sudah ada di priority list");
          return;
        }
      }

      int nextPriority = priorityList.length + 1;

      // 🔵 Ambil data user target (helper)
      final helperSnap = await db.child("users/$targetUid").get();
      final helper = Map<String, dynamic>.from(helperSnap.value as Map);

      final email = helper["email"] ?? ""; // ✔ Ambil email user target

      // 🔵 SIMPAN DATA PRIORITY DENGAN EMAIL
      await db.child("users/$uid/priorities").push().set({
        "targetUid": targetUid,
        "targetUsername": searchUsername.value.trim(),
        "email": email, // ✔ SIMPAN EMAIL
        "priorityLevel": nextPriority,
        "fcmToken": helper["fcmToken"] ?? "",
        "location": helper["location"] ?? {},
        "avatarUrl": helper["avatarUrl"] ?? "",
      });

      Get.snackbar("Berhasil", "User ditambahkan ke priority list");
      searchUsername.value = '';
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // =====================================================
  // ============== UPDATE PRIORITY ORDER ================
  // =====================================================

  Future<void> updatePriority(String id, int newLevel) async {
    final uid = auth.currentUser!.uid;

    final snap = await db.child("users/$uid/priorities").get();
    if (!snap.exists) return;

    await db.child("users/$uid/priorities/$id/priorityLevel").set(newLevel);

    final data = <Map<String, dynamic>>[];

    for (var child in snap.children) {
      final v = Map<String, dynamic>.from(child.value as Map);
      data.add({
        "id": child.key!,
        "priorityLevel": v["priorityLevel"],
      });
    }

    data.sort((a, b) =>
        (a["priorityLevel"] as int).compareTo(b["priorityLevel"] as int));

    int i = 1;
    for (var d in data) {
      await db.child("users/$uid/priorities/${d['id']}/priorityLevel").set(i);
      i++;
    }
  }

  // =====================================================
  // =================== DELETE ==========================
  // =====================================================

  Future<void> deletePriority(String id) async {
    final uid = auth.currentUser!.uid;
    await db.child("users/$uid/priorities/$id").remove();
  }

  // =====================================================
  // ===================== REORDER =======================
  // =====================================================

  Future<void> reorderPriority(int oldIndex, int newIndex) async {
    final uid = auth.currentUser!.uid;
    if (newIndex > oldIndex) newIndex--;

    // COPY list, JANGAN mutate priorityList langsung
    final newList = List<Map<String, dynamic>>.from(priorityList);

    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);

    final updates = <String, dynamic>{};
    int i = 1;
    for (var p in newList) {
      updates["users/$uid/priorities/${p['id']}/priorityLevel"] = i;
      i++;
    }

    await db.update(updates);
  }

  // =====================================================
  // =============== MULTI SELECT DELETE =================
  // =====================================================

  void toggleSelect(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void clearSelection() {
    selectedIds.clear();
  }

  Future<void> deleteSelected() async {
    final uid = auth.currentUser!.uid;

    for (var id in selectedIds) {
      await db.child("users/$uid/priorities/$id").remove();
    }

    selectedIds.clear();
  }

  Future<void> removeHelperFromOtherUser(
      String ownerUid, String helperUid) async {
    final snap = await db.child("users/$ownerUid/priorities").get();
    if (!snap.exists) return;

    for (var child in snap.children) {
      final data = Map<String, dynamic>.from(child.value as Map);
      if (data['targetUid'] == helperUid) {
        await db.child("users/$ownerUid/priorities/${child.key}").remove();
        break;
      }
    }
  }
}
