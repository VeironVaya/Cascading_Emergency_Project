import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import '../../../widgets/primary_button.dart';
import '../../../../routes/app_routes.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});
  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            onChanged: (v) => c.emailC.value = v,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
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
              : PrimaryButton(label: 'Sign In', onPressed: c.login)),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.SIGNUP),
            child: const Text('Belum punya akun? Daftar'),
          ),
        ]),
      ),
    );
  }
}
