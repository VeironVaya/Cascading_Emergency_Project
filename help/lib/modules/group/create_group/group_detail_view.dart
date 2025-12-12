import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hellping/modules/group/create_group/group_controller.dart';
import 'package:project_hellping/routes/app_routes.dart';
import 'package:project_hellping/widgets/floating_navbar.dart';
import '../../../services/firebase_auth_service.dart';

class GroupDetailsView extends StatelessWidget {
  final GroupController controller = Get.find<GroupController>();

  @override
  Widget build(BuildContext context) {
    final String groupId = Get.arguments["groupId"];
    final String? currentUid = FirebaseAuthService.currentUser?.uid;

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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: controller.getGroupDetails(groupId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final group = snapshot.data!;
          final bool isOwner = currentUid == group['ownerId'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  group['name'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("Kode Grup: ${group['code']}"),
                const SizedBox(height: 20),
                const Text(
                  "Owner:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(group['ownerUsername']),
                  subtitle: Text(
                    "Kondisi: ${group['ownerCondition']}",
                    style: const TextStyle(fontSize: 13),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "OWNER",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Anggota:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView(
                    children: group['members'].entries.map<Widget>((entry) {
                      final userId = entry.key;
                      final data = entry.value;

                      final username = data["username"];
                      final condition = data["condition"];

                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(username),
                          subtitle: Text("Kondisi: $condition"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Emoji kondisi
                              Text(
                                _conditionToEmoji(condition),
                                style: const TextStyle(fontSize: 26),
                              ),

                              const SizedBox(width: 8),

                              // Hanya owner yg bisa hapus member
                              if (isOwner && userId != group['ownerId'])
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    controller.removeMember(groupId, userId);
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                if (isOwner)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        icon: const Icon(Icons.edit),
                        label: const Text("Edit Nama Grup"),
                        onPressed: () {
                          _showEditDialog(context, groupId, group['name']);
                        },
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        icon: const Icon(Icons.delete),
                        label: const Text("Hapus Grup"),
                        onPressed: () {
                          controller.deleteGroup(groupId);
                          Get.offAllNamed(AppRoutes.USER_GROUP);
                        },
                      ),
                    ],
                  )
              ],
            ),
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

  void _showEditDialog(BuildContext context, String groupId, String oldName) {
    final nameController = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Edit Nama Grup"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Nama Baru"),
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Get.back(),
            ),
            ElevatedButton(
              child: const Text("Simpan"),
              onPressed: () {
                controller.editGroupName(groupId, nameController.text);
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }
}

String _conditionToEmoji(String condition) {
  switch (condition.toLowerCase()) {
    case "sangat baik":
      return "😄";
    case "baik":
      return "🙂";
    case "cukup":
      return "😐";
    case "buruk":
      return "😟";
    case "sangat buruk":
      return "😢";
    default:
      return "❓";
  }
}
