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
              onPressed: () => Get.back(),
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Group",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: controller.getUserGroups(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final groups = snapshot.data!;
          final currentUid = FirebaseAuthService.currentUser?.uid;

          if (groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Belum bergabung dengan grup",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),

                  // JOIN GROUP
                  ElevatedButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.JOIN_GROUP);
                    },
                    child: const Text("JOIN GROUP"),
                  ),

                  const SizedBox(height: 10),

                  // CREATE GROUP
                  OutlinedButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.CREATE_GROUP);
                    },
                    child: const Text("CREATE GROUP"),
                  ),
                ],
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    final bool isOwner = group['ownerId'] == currentUid;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.GROUP_DETAIL,
                            arguments: {"groupId": group['id']},
                          );
                        },
                        title: Text(group['name'] ?? "-"),
                        subtitle: Text("Code: ${group['code']}"),
                        trailing: isOwner
                            ? const Icon(Icons.star, color: Colors.orange)
                            : null,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.JOIN_GROUP);
                        },
                        child: const Text("JOIN GROUP"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.CREATE_GROUP);
                        },
                        child: const Text("CREATE GROUP"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(16),
        child: FloatingNavbar(
          activeRoute: AppRoutes.USER_GROUP,
        ),
      ),
    );
  }
}
