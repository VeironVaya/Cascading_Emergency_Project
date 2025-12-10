import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../../../services/firebase_auth_service.dart';
import '../../../../routes/app_routes.dart';

class CreateGroupController extends GetxController {
  final name = ''.obs;
  final isLoading = false.obs;

  final _db = FirebaseDatabase.instance.ref();

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
        AppRoutes.HOME,
        arguments: {"groupId": newGroupRef.key},
      );
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
