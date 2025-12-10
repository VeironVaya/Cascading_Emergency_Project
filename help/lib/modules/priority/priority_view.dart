import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hellping/routes/app_routes.dart';
import 'package:project_hellping/widgets/floating_navbar.dart';
import 'priority_controller.dart';

class PriorityView extends GetView<PriorityController> {
  const PriorityView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7480C9),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                "Kontak",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // BUTTON TAMBAH KONTAK
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  c.isAddMode.value = true; // ganti mode ke add kontak
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text("Tambah Kontak"),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          if (c.isAddMode.value) {
            // ============================
            // MODE ADD KONTAK
            // ============================
            return Column(
              children: [
                // Search bar untuk mencari username
                TextField(
                  decoration: const InputDecoration(
                    labelText: "Cari username",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => c.searchUsername.value = v,
                ),
                const SizedBox(height: 12),

                // Tombol Tambah Kontak
                Obx(() => c.isLoading.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: c.addPriority,
                        child: const Text("Tambahkan ke Priority"),
                      )),
                const SizedBox(height: 12),

                // Tombol Batal
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    c.isAddMode.value = false;
                    c.searchUsername.value = '';
                  },
                  child: const Text("Batal"),
                ),
              ],
            );
          } else {
            // ============================
            // MODE LIST PRIORITY
            // ============================
            final list = c.priorityList;
            return Column(
              children: [
                // Search bar + titik tiga (delete / reorder)
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFEFEFEF),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(103),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.search, size: 20),
                              const SizedBox(width: 6),
                              Expanded(
                                child: TextField(
                                  decoration: const InputDecoration(
                                    hintText: "Cari",
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    c.searchUsername.value = value;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'delete') {
                            c.showDeleteMode.value = true;
                            c.showReorderMode.value = false;
                          } else if (value == 'priority') {
                            c.showDeleteMode.value = false;
                            c.showReorderMode.value = true;
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                              value: 'delete', child: Text('Hapus Kontak')),
                          const PopupMenuItem(
                              value: 'priority', child: Text('Ubah Priority')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Tombol delete selected (hanya saat delete mode aktif)
                Obx(() {
                  if (!c.showDeleteMode.value || c.selectedIds.isEmpty) {
                    return const SizedBox();
                  }

                  return ElevatedButton.icon(
                    onPressed: c.deleteSelected,
                    icon: const Icon(Icons.delete),
                    label: Text("Delete Selected (${c.selectedIds.length})"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  );
                }),
                const SizedBox(height: 10),

                // List priority
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border:
                          Border.all(color: const Color(0x70BBBBBB), width: 1),
                      color: Colors.white,
                    ),
                    child: ReorderableListView(
                      shrinkWrap: true,
                      physics: const AlwaysScrollableScrollPhysics(),
                      onReorder: (oldIndex, newIndex) {
                        if (c.showReorderMode.value) {
                          c.reorderPriority(oldIndex, newIndex);
                        }
                      },
                      buildDefaultDragHandles: false,
                      children: List.generate(list.length, (index) {
                        final item = list[index];
                        final id = item['id'];
                        final username = item['targetUsername'];
                        final uid = item['targetUid'];
                        final email = item['email'] ?? "-";
                        final avatar = item['avatarUrl'] ??
                            "https://ui-avatars.com/api/?name=$username";

                        return Column(
                          key: ValueKey(id),
                          children: [
                            _buildPriorityItem(
                              index: index,
                              id: id,
                              username: username,
                              uid: uid,
                              email: email,
                              avatar: avatar,
                              controller: c,
                            ),
                            if (index != list.length - 1)
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                height: 1,
                                width: double.infinity,
                                color: const Color(0xFFACACAC),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            );
          }
        }),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: FloatingNavbar(activeRoute: AppRoutes.PRIORITY),
      ),
    );
  }
}

// ======================================================================
//                          PRIORITY ITEM WIDGET
// ======================================================================
Widget _buildPriorityItem({
  required int index,
  required String id,
  required String avatar,
  required String username,
  required String uid,
  required String email,
  required PriorityController controller,
}) {
  final isSelected = controller.selectedIds.contains(id);

  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      // Avatar
      Container(
        margin: const EdgeInsets.only(right: 14),
        width: 45,
        height: 44,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            avatar,
            fit: BoxFit.cover,
          ),
        ),
      ),

      // Username & Email
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(
                color: Color(0xFF202020),
                fontSize: 16,
              ),
            ),
            Text(
              email,
              style: const TextStyle(
                color: Color(0xFF6F6F6F),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),

      // Drag handle (kanan) hanya saat reorder mode aktif
      if (controller.showReorderMode.value)
        ReorderableDragStartListener(
          index: index,
          child: const Icon(Icons.drag_handle),
        ),

      // Lingkaran select di kanan hanya saat delete mode aktif
      if (controller.showDeleteMode.value)
        GestureDetector(
          onTap: () => controller.toggleSelect(id),
          child: Container(
            margin: const EdgeInsets.only(left: 10),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey,
                width: 2,
              ),
              color: isSelected ? Colors.blue : Colors.white,
            ),
            child: isSelected
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
    ],
  );
}
