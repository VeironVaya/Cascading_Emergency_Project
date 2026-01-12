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

                          final Map<String, dynamic> members =
                              group['members'] != null
                                  ? Map<String, dynamic>.from(group['members'])
                                  : {};

                          final totalMembers = members.length;
                          final memberList = members.entries.take(2).toList();

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 3,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// HEADER GROUP
                                  Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 227, 227, 227),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.group,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          group['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                  ),
                                  const SizedBox(height: 12),

                                  /// MEMBER LIST (MAX 2)
                                  ...memberList.map((entry) {
                                    final member = entry.value;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      child: Row(
                                        children: [
                                          /// AVATAR

                                          const CircleAvatar(
                                            radius: 18,
                                            backgroundColor: Color.fromARGB(
                                                255, 227, 227, 227),
                                            child: Icon(Icons.person,
                                                size: 18, color: Colors.white),
                                          ),

                                          const SizedBox(width: 10),

                                          /// NAME + USERNAME
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  member['username'],
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                Text(
                                                  "@${member['username']}",
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          /// CONDITION EMOJI
                                          Text(
                                            _conditionEmoji(
                                                member['condition']),
                                            style:
                                                const TextStyle(fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),

                                  /// LIHAT SEMUA
                                  InkWell(
                                    onTap: () {
                                      Get.toNamed(
                                        AppRoutes.GROUP_DETAIL,
                                        arguments: {"groupId": group['id']},
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.chevron_right,
                                              color: Colors.grey),
                                          SizedBox(width: 4),
                                          Text(
                                            "Lihat semua",
                                            style:
                                                TextStyle(color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

String _conditionEmoji(String condition) {
  switch (condition.toLowerCase()) {
    case "sangat baik":
      return "😀";
    case "baik":
      return "🙂";
    case "biasa saja":
      return "😐";
    case "kurang baik":
      return "🙁";
    case "sedih":
      return "😢";
    default:
      return "❓";
  }
}
