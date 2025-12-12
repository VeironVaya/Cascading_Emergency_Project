import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hellping/modules/profile/profile_controller.dart';
import 'package:project_hellping/routes/app_routes.dart';
import 'package:project_hellping/widgets/floating_navbar.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());

  ProfileView({super.key});

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7480C9),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.offAllNamed(AppRoutes.HOME),
            ),

            const SizedBox(width: 6),

            const Text(
              "Profile",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            // LOGOUT BUTTON
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await controller.logout();
              },
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Info Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.username.value,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.email.value,
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Editable Fields
                TextFormField(
                  initialValue: controller.name.value,
                  decoration: const InputDecoration(
                    labelText: "Nama",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (val) => controller.name.value = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? "Nama wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  initialValue: controller.age.value.toString(),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Umur",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake),
                  ),
                  onChanged: (val) =>
                      controller.age.value = int.tryParse(val) ?? 0,
                  validator: (val) {
                    if (val == null || val.isEmpty) return "Umur wajib diisi";
                    if (int.tryParse(val) == null) return "Umur harus angka";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  initialValue: controller.address.value,
                  decoration: const InputDecoration(
                    labelText: "Alamat",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  onChanged: (val) => controller.address.value = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? "Alamat wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  initialValue: controller.medicalHistory.value,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Riwayat Medis",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.medical_services),
                  ),
                  onChanged: (val) => controller.medicalHistory.value = val,
                  validator: (val) => val == null || val.isEmpty
                      ? "Riwayat medis wajib diisi"
                      : null,
                ),
                const SizedBox(height: 24),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7480C9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        controller.updateProfile(
                          newName: controller.name.value,
                          newAge: controller.age.value,
                          newAddress: controller.address.value,
                          newMedicalHistory: controller.medicalHistory.value,
                        );
                      }
                    },
                    child: const Text(
                      "Simpan",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: FloatingNavbar(activeRoute: AppRoutes.PROFILE),
      ),
    );
  }
}
