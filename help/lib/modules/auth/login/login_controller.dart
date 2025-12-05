import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/firebase_auth_service.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final emailC = ''.obs;
  final passC = ''.obs;
  final isLoading = false.obs;

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  Future<void> login() async {
    if (emailC.value.isEmpty || passC.value.isEmpty) {
      Get.snackbar('Error', 'Email dan password harus diisi');
      return;
    }

    try {
      isLoading.value = true;
      UserCredential credential = await FirebaseAuthService.signIn(
        email: emailC.value.trim(),
        password: passC.value.trim(),
      );

      String uid = credential.user!.uid;

      DataSnapshot snap = await _db.child("users").child(uid).get();

      if (snap.exists) {
        Map user = snap.value as Map;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("uid", user["uid"]);
        await prefs.setString("email", user["email"]);
        await prefs.setString("username", user["username"]);
        await prefs.setInt("age", user["age"]);
        await prefs.setString("address", user["address"]);
        await prefs.setString("medical_history", user["medical_history"]);
        await prefs.setBool("isLoggedIn", true);
      }

      Get.offAllNamed(AppRoutes.HOME);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Error', e.message ?? 'Terjadi kesalahan');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await FirebaseAuthService.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed(AppRoutes.LOGIN);
  }

  Future<void> checkAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;

    if (isLoggedIn) {
      Get.offAllNamed(AppRoutes.HOME);
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
