import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PriorityController extends GetxController {
  final db = FirebaseDatabase.instance.ref();
  final auth = FirebaseAuth.instance;

  RxList<Map<String, dynamic>> priorityList = <Map<String, dynamic>>[].obs;

  RxString searchUsername = ''.obs;
  RxBool isLoading = false.obs;

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
          'priorityLevel': v['priorityLevel'],

          // NEW: fetch helper's public info
          'fcmToken': v['fcmToken'],
          'location': v['location'],
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
      final snap = await db.child("users").get();
      String? targetUid;

      for (var child in snap.children) {
        final user = Map<String, dynamic>.from(child.value as Map);
        if (user['username'] == searchUsername.value.trim()) {
          targetUid = child.key;
          break;
        }
      }

      if (targetUid == null) {
        Get.snackbar("Gagal", "Username tidak ditemukan");
        isLoading.value = false;
        return;
      }

      final uid = auth.currentUser!.uid;

      int nextPriority = priorityList.length + 1;

// Fetch helper info
      final helperSnap = await db.child("users/$targetUid").get();
      final helper = Map<String, dynamic>.from(helperSnap.value as Map);

      await db.child("users/$uid/priorities").push().set({
        "targetUid": targetUid,
        "targetUsername": searchUsername.value,
        "priorityLevel": nextPriority,

        // NEW FIELDS
        "fcmToken": helper["fcmToken"],
        "location":
            helper["location"], // you must store helper's last known location
      });

      Get.snackbar("Berhasil", "User berhasil ditambahkan sebagai priority");
      searchUsername.value = '';
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePriority(String id, int newLevel) async {
    final uid = auth.currentUser!.uid;

    await db.child("users/$uid/priorities/$id/priorityLevel").set(newLevel);
  }

  Future<void> deletePriority(String id) async {
    final uid = auth.currentUser!.uid;

    await db.child("users/$uid/priorities/$id").remove();
  }
}
