import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hellping/modules/group/create_group/group_controller.dart';
import 'package:project_hellping/widgets/floating_navbar.dart';
import '../../../../routes/app_routes.dart';
import '../../../services/firebase_auth_service.dart';

class UserGroupsView extends StatelessWidget {
  final GroupController controller = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APP BAR =================
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
              onPressed: () => Get.offAllNamed(AppRoutes.HOME),
            ),

            const SizedBox(width: 6),

            // TITLE
            const Text(
              "Group",
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

      // ================= BODY =================
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: controller.getUserGroups(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = snapshot.data!;
          final currentUid = FirebaseAuthService.currentUser?.uid;

          return Column(
            children: [
              // ===== CREATE CIRCLE BUTTON (PALING ATAS) =====
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.CREATE_GROUP);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.group,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Color(0xFF7480C9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          "Buat circle baru",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ===== LIST / EMPTY STATE =====
              Expanded(
                child: groups.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum bergabung dengan grup",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: groups.length,
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          final bool isOwner = group['ownerId'] == currentUid;

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),

                              /// ICON GROUP
                              leading: CircleAvatar(
                                radius: 24,
                                backgroundColor:
                                    const Color.fromARGB(255, 213, 213, 213),
                                child: const Icon(
                                  Icons.group,
                                  color: Colors.deepPurpleAccent,
                                  size: 26,
                                ),
                              ),

                              /// NAMA GROUP
                              title: Text(
                                group['name'] ?? "-",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              /// SUBTITLE
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    "Code: ${group['code']}",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  if (isOwner)
                                    const Text(
                                      "Owner",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),

                              onTap: () {
                                Get.toNamed(
                                  AppRoutes.GROUP_DETAIL,
                                  arguments: {"groupId": group['id']},
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
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
