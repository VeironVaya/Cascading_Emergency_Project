import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hellping/modules/group/create_group/group_controller.dart';
import 'package:project_hellping/widgets/floating_navbar.dart';
import 'package:project_hellping/routes/app_routes.dart';

class CreateGroupView extends StatelessWidget {
  CreateGroupView({super.key});

  final GroupController controller = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF7480C9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Buat circle",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 28),

              // ===== IMAGE DEFAULT =====
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade300,
                      ),
                      child: const Icon(
                        Icons.image,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),

                    // ICON PLUS (VISUAL ONLY)
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFF7480C9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ===== LABEL =====
              const Text(
                "Nama Circle",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 8),

              // ===== TEXTFIELD =====
              TextField(
                onChanged: (value) => controller.name.value = value,
                decoration: InputDecoration(
                  hintText: "Kimchi Fam💗",
                  filled: true,
                  fillColor: const Color(0xFFF3F3F3),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const Spacer(),

              // ===== BUTTON SIMPAN =====
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.create,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4C57A7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Simpan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ================= BOTTOM NAV =================
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(16),
        child: FloatingNavbar(
          activeRoute: AppRoutes.USER_GROUP,
        ),
      ),
    );
  }
}
