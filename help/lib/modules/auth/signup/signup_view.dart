import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signup_controller.dart';

class SignupView extends GetView<SignupController> {
  const SignupView({super.key});

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
                SizedBox(height: height * 0.05),

                // Avatar / Logo
                Row(
                  children: [
                    // Tombol kembali bulat
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 40, // diameter lingkaran
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white, // warna background lingkaran
                          shape: BoxShape.circle,
                          boxShadow: [
                            // opsional, agar ada efek shadow
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child:
                            const Icon(Icons.arrow_back, color: Colors.black),
                      ),
                    ),

                    // Spacer agar logo tetap di tengah
                    Expanded(
                      child: Center(
                        child: Container(
                          width: width * 0.2,
                          height: width * 0.2,
                          decoration: BoxDecoration(
                            color: const Color(0xFFAFB6E0),
                            borderRadius: BorderRadius.circular(width * 0.1),
                          ),
                        ),
                      ),
                    ),

                    // Untuk menjaga jarak kanan sama dengan kiri
                    SizedBox(width: 40),
                  ],
                ),
                SizedBox(height: height * 0.03),

                // Title
                Center(
                  child: Text(
                    'Daftar Akun',
                    style: TextStyle(
                      color: const Color(0xFF4A57AB),
                      fontSize: width * 0.06,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: height * 0.04),

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
                SizedBox(height: 16),

                // Username
                Text('Username', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (v) => c.usernameC.value = v,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Contoh: alamak123',
                    ),
                  ),
                ),
                SizedBox(height: 16),

                Text('Nama Lengkap',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (v) => c.nameC.value = v,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Masukkan nama lengkap',
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Umur
                Text('Umur', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (v) => c.ageC.value = v,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Masukkan umur',
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Alamat
                Text('Alamat', style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (v) => c.addressC.value = v,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Masukkan alamat',
                    ),
                  ),
                ),
                SizedBox(height: 16),

                // Riwayat Penyakit
                Text('Riwayat Penyakit',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    onChanged: (v) => c.medicalHistoryC.value = v,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Masukkan riwayat penyakit',
                    ),
                    maxLines: 2,
                  ),
                ),
                SizedBox(height: 16),

                // // Confirm Password
                // Text('Konfirmasi Password', style: TextStyle(fontWeight: FontWeight.w600)),
                // SizedBox(height: 8),
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 12),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFFF2F2F2),
                //     borderRadius: BorderRadius.circular(10),
                //   ),
                //   child: TextField(
                //     obscureText: true,
                //     onChanged: (v) => c.confirmPassC.value = v,
                //     decoration: const InputDecoration(
                //       border: InputBorder.none,
                //       hintText: 'Konfirmasi password',
                //     ),
                //   ),
                // ),
                SizedBox(height: 32),

                // Tombol Daftar
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
                      onPressed: c.isLoading.value ? null : c.signup,
                      child: c.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Daftar',
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

                // Link Masuk
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Sudah memiliki akun? ',
                      style: const TextStyle(
                        color: Color(0xFF1E1E1E),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: 'Masuk',
                          style: const TextStyle(
                            color: Color(0xFF5160BC),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.back(); // navigasi ke login
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
