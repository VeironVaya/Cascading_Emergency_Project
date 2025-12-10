import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hellping/modules/group/group_detail/group_detail_controller.dart';

class GroupDetailView extends GetView<GroupDetailController> {
  GroupDetailView({super.key});

  final Map<String, dynamic> dailyStatus = {
    "condition": "kurang baik",
    "emoji": "🙁",
    "timestamp": "2025-12-09T01:40:13.062433",
    "date": "2025-12-09",
    "email": "ibu1@gmail.com",
  };
  final String username = "Ibu1";
  final String uid = "abc123";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Group"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.group.value;
        if (data == null) {
          return const Center(child: Text("Group tidak ditemukan"));
        }

        final isOwner = data["ownerId"] == controller.group.value?["ownerId"];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================
            // DETAIL GROUP
            // ========================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Nama Group:",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(
                    data["name"] ?? "",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  Text("Owner:",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text(
                    controller.ownerName.value,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text("Anggota:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // ========================
            // LIST MEMBER
            // ========================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: controller.membersData.entries.map((e) {
                  final uid = e.key;
                  final username = e.value;

                  // Ambil kondisi/emoji terakhir
                  final condition = controller.membersCondition[uid] ?? "❓";

                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade100,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              dailyStatus['emoji'] ?? '😐', // tampilkan emoji
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              username,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Text(
                          uid,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // ========================
            // ACTION BUTTONS
            // ========================
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (isOwner)
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _showEditDialog(context),
                            child: const Text("Edit Nama Group"),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => controller.deleteGroup(),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text(
                              "Hapus Group",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => controller.leaveGroup(),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: const Text(
                          "Keluar dari Group",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            )
          ],
        );
      }),
    );
  }

  // ========================
  // POPUP EDIT NAMA GROUP
  // ========================
  void _showEditDialog(BuildContext context) {
    final textController =
        TextEditingController(text: controller.group.value?["name"]);

    Get.defaultDialog(
      title: "Edit Nama Group",
      content: Column(
        children: [
          TextField(
            controller: textController,
            decoration: const InputDecoration(labelText: "Nama baru"),
          ),
        ],
      ),
      textConfirm: "Simpan",
      textCancel: "Batal",
      onConfirm: () {
        final newName = textController.text.trim();
        controller.updateGroupName(newName);
        Get.back();
      },
    );
  }
}
