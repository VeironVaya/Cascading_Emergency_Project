import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hellping/modules/group/create_group/group_controller.dart';
import 'package:project_hellping/routes/app_routes.dart';
import 'package:project_hellping/widgets/floating_navbar.dart';

class DeleteCircleView extends StatelessWidget {
  DeleteCircleView({super.key});

  final GroupController controller = Get.find<GroupController>();

  @override
  Widget build(BuildContext context) {
    final String groupId = Get.arguments['groupId'];
    final String groupName = Get.arguments['groupName'] ?? 'Circle';
    final String? imageUrl = Get.arguments['imageUrl'];

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
            // BACK BUTTON
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.offAllNamed(AppRoutes.USER_GROUP),
            ),

            const SizedBox(width: 6),

            // TITLE
            const Text(
              "Circle",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            // GABUNG CIRCLE BUTTON
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.JOIN_GROUP);
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.group_add,
                      color: Color(0xFF7480C9),
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "Gabung Circle",
                      style: TextStyle(
                        color: Color(0xFF7480C9),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const Spacer(),

            /// =====================
            /// AVATAR
            /// =====================
            CircleAvatar(
              radius: 44,
              backgroundColor: Colors.grey[200],
              backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
              child: imageUrl == null
                  ? const Icon(Icons.groups, size: 40, color: Colors.grey)
                  : null,
            ),

            const SizedBox(height: 16),

            /// =====================
            /// NAMA CIRCLE
            /// =====================
            Text(
              groupName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            /// =====================
            /// TEKS KONFIRMASI
            /// =====================
            const Text(
              "Apakah Anda yakin\ningin menghapus circle ini?",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            /// =====================
            /// BUTTON HAPUS
            /// =====================
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  controller.deleteGroup(groupId);
                  Get.offAllNamed(AppRoutes.HOME);
                },
                child: const Text(
                  "Hapus",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: FloatingNavbar(activeRoute: AppRoutes.USER_GROUP),
      ),
    );
  }
}
