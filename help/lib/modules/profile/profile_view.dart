import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        _usernameController.text = controller.username.value;
        _ageController.text = controller.age.value.toString();
        _addressController.text = controller.address.value;
        _medicalController.text = controller.medicalHistory.value;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: "Address"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _medicalController,
                decoration: const InputDecoration(labelText: "Medical History"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  controller.updateProfile(
                    newUsername: _usernameController.text,
                    newAge: int.tryParse(_ageController.text) ?? 0,
                    newAddress: _addressController.text,
                    newMedicalHistory: _medicalController.text,
                  );
                },
                child: const Text("Update Profile"),
              ),
            ],
          ),
        );
      }),
    );
  }
}
