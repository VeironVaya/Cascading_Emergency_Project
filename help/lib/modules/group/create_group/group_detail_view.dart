import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hellping/modules/group/create_group/group_controller.dart';
import 'package:project_hellping/routes/app_routes.dart';
import 'package:project_hellping/widgets/floating_navbar.dart';
import '../../../services/firebase_auth_service.dart';

class GroupDetailsView extends StatelessWidget {
  GroupDetailsView({super.key});

  final GroupController controller = Get.put(GroupController());

  @override
  Widget build(BuildContext context) {
    final String groupId = Get.arguments["groupId"];
    final String? currentUid = FirebaseAuthService.currentUser?.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: controller.getGroupDetails(groupId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Group tidak ditemukan"));
          }

          final group = snapshot.data!;
          final bool isOwner = currentUid == group['ownerId'];
          final members = Map<String, dynamic>.from(group['members']);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// =====================
                /// HEADER GROUP
                /// =====================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: _cardDecoration(),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFE0E0E0),
                        child: Icon(Icons.groups, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${members.length} anggota",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isOwner)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditDialog(context, groupId, group['name']);
                            } else if (value == 'members') {
                              _showEditMembersDialog(context, groupId, group);
                            } else if (value == 'code') {
                              Get.toNamed(
                                AppRoutes.INVITE_CODE,
                                arguments: {
                                  "code": group['code'],
                                },
                              );
                            } else if (value == 'delete') {
                              Get.toNamed(
                                AppRoutes.DELETE_CIRCLE,
                                arguments: {
                                  "groupId": groupId,
                                  "groupName": group['name'],
                                },
                              );
                            }
                          },
                          itemBuilder: (BuildContext context) => const [
                            PopupMenuItem<String>(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit Circle'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'members',
                              child: Row(
                                children: [
                                  Icon(Icons.person_add, size: 18),
                                  SizedBox(width: 8),
                                  Text('Edit Anggota'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'code',
                              child: Row(
                                children: [
                                  Icon(Icons.code, size: 18),
                                  SizedBox(width: 8),
                                  Text('Bagikan Kode'),
                                ],
                              ),
                            ),
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      size: 18, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Hapus Circle',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// =====================
                /// OWNER
                /// =====================
                Container(
                  decoration: _cardDecoration(),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFE0E0E0),
                      child: Icon(Icons.person),
                    ),
                    title: Text(group['ownerUsername']),
                    subtitle: Text("Kondisi: ${group['ownerCondition']}"),
                    trailing: Text(
                      _conditionToEmoji(group['ownerCondition']),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                /// =====================
                /// MEMBERS
                /// =====================
                Text(
                  "Anggota",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),

                Container(
                  decoration: _cardDecoration(),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: members.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: Colors.grey[300]),
                    itemBuilder: (context, index) {
                      final entry = members.entries.toList()[index];
                      final memberId = entry.key;
                      final data = Map<String, dynamic>.from(entry.value);

                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFE0E0E0),
                          child: Icon(Icons.person),
                        ),
                        title: Row(
                          children: [
                            Text(data['username']),
                            if (memberId == group['ownerId'])
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: Colors.blue,
                                ),
                              ),
                          ],
                        ),
                        subtitle: Text("Kondisi: ${data['condition']}"),
                        trailing: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getConditionColor(data['condition']),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              _conditionToEmoji(data['condition']),
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: FloatingNavbar(activeRoute: AppRoutes.USER_GROUP),
      ),
    );
  }

  // =========================
  // DECORATION
  // =========================
  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      );

  // =========================
  // DIALOG EDIT NAMA
  // =========================
  void _showEditDialog(BuildContext context, String groupId, String oldName) {
    final textController = TextEditingController(text: oldName);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Nama Circle"),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            labelText: "Nama Baru",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                controller.editGroupName(
                  groupId,
                  textController.text,
                );
                Get.back();
              }
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // =========================
  // DIALOG EDIT ANGGOTA
  // =========================
  void _showEditMembersDialog(
    BuildContext context,
    String groupId,
    Map<String, dynamic> group,
  ) {
    final members = Map<String, dynamic>.from(group['members']);
    final ownerId = group['ownerId'];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Anggota Circle"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: members.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = members.entries.toList()[index];
              final memberId = entry.key;
              final data = Map<String, dynamic>.from(entry.value);

              if (memberId == ownerId) {
                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.orange),
                  title: Text(data['username']),
                  subtitle: const Text("Owner"),
                );
              }

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(data['username']),
                subtitle: Text("Kondisi: ${data['condition']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _confirmRemoveMember(
                      context,
                      groupId,
                      memberId,
                      data['username'],
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  // =========================
  // KONFIRMASI HAPUS MEMBER
  // =========================
  void _confirmRemoveMember(
    BuildContext context,
    String groupId,
    String userId,
    String username,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Anggota"),
        content: Text(
          "Yakin ingin menghapus $username dari circle?",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              controller.removeMember(groupId, userId);
              Get.back(); // konfirmasi
              Get.back(); // dialog edit anggota
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // HAPUS GROUP
  // =========================
  void _showDeleteConfirmation(BuildContext context, String groupId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Circle"),
        content: const Text(
          "Circle akan dihapus permanen. Lanjutkan?",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              controller.deleteGroup(groupId);
              Get.offAllNamed(AppRoutes.USER_GROUP);
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// =========================
/// UTIL
/// =========================

String _conditionToEmoji(String condition) {
  switch (condition.toLowerCase()) {
    case "sangat baik":
      return "😄";
    case "baik":
      return "🙂";
    case "biasa saja":
      return "😐";
    case "kurang baik":
      return "😟";
    case "sedih":
      return "😢";
    default:
      return "❓";
  }
}

Color _getConditionColor(String condition) {
  switch (condition.toLowerCase()) {
    case "sangat baik":
      return const Color(0xFFD4EDDA);
    case "baik":
      return const Color(0xFFE2F0CB);
    case "biasa saja":
      return const Color(0xFFFFF3CD);
    case "kurang baik":
      return const Color(0xFFF8D7DA);
    case "sedih":
      return const Color(0xFFF5C6CB);
    default:
      return const Color(0xFFE0E0E0);
  }
}
