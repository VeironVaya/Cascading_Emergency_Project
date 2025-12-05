import 'package:get/get.dart';
import '../../../services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../routes/app_routes.dart';

class SignupController extends GetxController {
  var usernameC = ''.obs;
  var ageC = ''.obs;
  var addressC = ''.obs;
  var medicalHistoryC = ''.obs;
  var emailC = ''.obs;
  var passC = ''.obs;
  var isLoading = false.obs;

  Future<void> signup() async {
    if (usernameC.isEmpty ||
        ageC.isEmpty ||
        addressC.isEmpty ||
        medicalHistoryC.isEmpty ||
        emailC.isEmpty ||
        passC.isEmpty) {
      Get.snackbar('Error', 'Email dan password harus diisi');
      return;
    }
    try {
      isLoading.value = true;

      await FirebaseAuthService.signUp(
        email: emailC.value,
        password: passC.value,
        username: usernameC.value,
        age: int.parse(ageC.value),
        address: addressC.value,
        medicalHistory: medicalHistoryC.value,
      );

      Get.offAllNamed(AppRoutes.LOGIN);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Sign Up Error', e.message ?? 'Terjadi kesalahan');
    } finally {
      isLoading.value = false;
    }
  }
}
