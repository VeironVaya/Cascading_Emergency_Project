import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_auth_service.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;
  var username = ''.obs;
  var email = ''.obs;
  var age = 0.obs;
  var address = ''.obs;
  var medicalHistory = ''.obs;

  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  void fetchUserProfile() async {
    isLoading.value = true;
    try {
      final snapshot = await FirebaseAuthService.getUserData();
      if (snapshot != null && snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        username.value = data['username'] ?? '';
        email.value = data['email'] ?? '';
        age.value = data['age'] ?? 0;
        address.value = data['address'] ?? '';
        medicalHistory.value = data['medical_history'] ?? '';
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch profile data");
    } finally {
      isLoading.value = false;
    }
  }

  void updateProfile({
    required String newUsername,
    required int newAge,
    required String newAddress,
    required String newMedicalHistory,
  }) async {
    isLoading.value = true;
    try {
      await _db.child("users").child(FirebaseAuth.instance.currentUser!.uid).update({
        "username": newUsername,
        "age": newAge,
        "address": newAddress,
        "medical_history": newMedicalHistory,
      });
      // update local state
      username.value = newUsername;
      age.value = newAge;
      address.value = newAddress;
      medicalHistory.value = newMedicalHistory;
      Get.snackbar("Success", "Profile updated successfully");
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile");
    } finally {
      isLoading.value = false;
    }
  }
}
