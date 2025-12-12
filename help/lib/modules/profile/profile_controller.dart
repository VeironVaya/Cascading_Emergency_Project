import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_hellping/routes/app_routes.dart';
import 'package:project_hellping/services/firebase_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  var uid = ''.obs;
  var username = ''.obs; 
  var email = ''.obs; 
  var name = ''.obs;
  var age = 0.obs;
  var address = ''.obs;
  var medicalHistory = ''.obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      uid.value = prefs.getString('uid') ?? '';
      username.value = prefs.getString('username') ?? '';
      email.value = prefs.getString('email') ?? '';
      name.value = prefs.getString('name') ?? '';
      age.value = prefs.getInt('age') ?? 0;
      address.value = prefs.getString('address') ?? '';
      medicalHistory.value = prefs.getString('medical_history') ?? '';

      if (uid.value.isNotEmpty) {
        DataSnapshot snap = await _db.child('users').child(uid.value).get();
        if (snap.exists && snap.value != null) {
          final data = Map<String, dynamic>.from(snap.value as Map);
          name.value = data['name'] ?? name.value;
          age.value = data['age'] ?? age.value;
          address.value = data['address'] ?? address.value;
          medicalHistory.value =
              data['medical_history'] ?? medicalHistory.value;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat profile');
    } finally {
      isLoading.value = false;
    }
  }

  
  Future<void> updateProfile({
    required String newName,
    required int newAge,
    required String newAddress,
    required String newMedicalHistory,
  }) async {
    if (uid.value.isEmpty) return;

    isLoading.value = true;
    try {
      await _db.child('users').child(uid.value).update({
        'name': newName,
        'age': newAge,
        'address': newAddress,
        'medical_history': newMedicalHistory,
      });
      name.value = newName;
      age.value = newAge;
      address.value = newAddress;
      medicalHistory.value = newMedicalHistory;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', newName);
      await prefs.setInt('age', newAge);
      await prefs.setString('address', newAddress);
      await prefs.setString('medical_history', newMedicalHistory);

      Get.snackbar('Sukses', 'Profil berhasil diperbarui');
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui profile');
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

}
