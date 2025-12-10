import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'login_controller.dart';
import '../../../../routes/app_routes.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.02),

                // Tombol Back Bulat
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
                SizedBox(height: height * 0.03),

                // Ucapan Selamat Datang
                Text(
                  'Selamat Datang! 👋🏻',
                  style: TextStyle(
                    fontSize: width * 0.07,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: height * 0.01),
                Text(
                  'Silahkan masukkan akun anda',
                  style: TextStyle(
                    fontSize: width * 0.03,
                    fontWeight: FontWeight.w400,
                    color: const Color.fromARGB(255, 95, 95, 95),
                  ),
                ),
                SizedBox(height: height * 0.05),

                // Email
                Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (v) => c.emailC.value = v,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Masukkan email',
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Password
                Text('Password', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    obscureText: true,
                    onChanged: (v) => c.passC.value = v,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Masukkan password',
                    ),
                  ),
                ),

                // Lupa Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigasi ke halaman reset password
                      // Get.toNamed(AppRoutes.RESET_PASSWORD);
                    },
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(
                        color: Color(0xFF5160BC),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Tombol Sign In
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A57AB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: c.isLoading.value ? null : c.login,
                      child: c.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Link Daftar
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Belum punya akun? ',
                      style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: 'Daftar',
                          style: const TextStyle(
                            color: Color(0xFF5160BC),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.toNamed(AppRoutes.SIGNUP);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
