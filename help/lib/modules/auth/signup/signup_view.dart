import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signup_controller.dart';
import '../../../widgets/primary_button.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});
  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
        appBar: AppBar(title: const Text('Sign Up')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => c.usernameC.value = v,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 8),
                TextField(
                  keyboardType: TextInputType.number,
                  onChanged: (v) => c.ageC.value = v,
                  decoration: const InputDecoration(labelText: 'Umur'),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (v) => c.addressC.value = v,
                  decoration: const InputDecoration(labelText: 'Alamat'),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (v) => c.medicalHistoryC.value = v,
                  decoration:
                      const InputDecoration(labelText: 'Riwayat Penyakit'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (v) => c.emailC.value = v,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 8),
                TextField(
                  onChanged: (v) => c.passC.value = v,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                Obx(() => c.isLoading.value
                    ? const CircularProgressIndicator()
                    : PrimaryButton(label: 'Sign Up', onPressed: c.signup)),
              ],
            ),
          ),
        ));
  }
}
