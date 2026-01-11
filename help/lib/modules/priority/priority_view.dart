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

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF7480C9),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Kontak",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(() => c.isAddMode.value
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      c.isAddMode.value = true;
                      c.searchUsername.value = '';
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah Kontak"),
                  ),
                )),
        ],
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          return c.isAddMode.value ? _addContactMode(c) : _priorityListMode(c);
        }),
      ),

      // ================= BOTTOM =================
      bottomNavigationBar: Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== BUTTON HAPUS KONTAK (PALING BAWAH) =====
            if (c.showDeleteMode.value && c.selectedIds.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: GestureDetector(
                    onTap: () {
                      Get.defaultDialog(
                        title: "Konfirmasi",
                        middleText:
                            "Yakin ingin menghapus ${c.selectedIds.length} kontak?",
                        textConfirm: "Hapus",
                        textCancel: "Batal",
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          Get.back();
                          c.deleteSelected();
                        },
                      );
                    },
                    child: Container(
                      height: 72,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.red, width: 1.5),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Hapus Kontak (${c.selectedIds.length})",
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),

            // ===== NAVBAR =====
            Padding(
              padding: const EdgeInsets.only(
                bottom: 16,
                left: 16,
                right: 16,
              ),
              child: FloatingNavbar(activeRoute: AppRoutes.PRIORITY),
            ),
          ],
        );
      }),
    );
  }
}

/* ============================================================
======================= ADD MODE ===============================
============================================================ */

Widget _addContactMode(PriorityController c) {
  return SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SEARCH BAR
          TextField(
            decoration: InputDecoration(
              hintText: "Cari username",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) => c.searchUsername.value = v,
          ),

          const SizedBox(height: 20),

          // PREVIEW USER
          Obx(() {
            if (c.searchUsername.value.isEmpty) {
              return const SizedBox();
            }

            if (c.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 42),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    c.searchUsername.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "@${c.searchUsername.value}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: c.addPriority,
                    icon: const Icon(Icons.add),
                    label: const Text("Tambah"),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                c.isAddMode.value = false;
                c.searchUsername.value = '';
              },
              child: const Text("Batal"),
            ),
          ),
        ],
      ),
    ),
  );
}

/* ============================================================
======================= LIST MODE ==============================
============================================================ */

Widget _priorityListMode(PriorityController c) {
  final list = c.priorityList;

  return Column(
    children: [
      // SEARCH + MENU
      Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: "Cari",
                        border: InputBorder.none,
                      ),
                      onChanged: (v) => c.searchUsername.value = v,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'delete') {
                c.showDeleteMode.value = true;
                c.showReorderMode.value = false;
                c.selectedIds.clear();
              } else {
                c.showDeleteMode.value = false;
                c.showReorderMode.value = true;
                c.selectedIds.clear();
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text("Hapus Kontak")),
              PopupMenuItem(value: 'priority', child: Text("Ubah Priority")),
            ],
          ),
        ],
      ),

      const SizedBox(height: 12),

      // LIST
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: ReorderableListView(
            buildDefaultDragHandles: false,
            onReorder: c.reorderPriority,
            children: List.generate(list.length, (i) {
              final item = list[i];
              return _priorityItem(
                key: ValueKey(item['id']),
                index: i,
                item: item,
                c: c,
              );
            }),
          ),
        ),
      ),
    ],
  );
}

/* ============================================================
======================= ITEM ================================
============================================================ */

Widget _priorityItem({
  required Key key,
  required int index,
  required Map<String, dynamic> item,
  required PriorityController c,
}) {
  final id = item['id'];
  final username = item['targetUsername'];
  final email = item['email'];

  final selected = c.selectedIds.contains(id);

  return Container(
    key: key,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username, style: const TextStyle(fontSize: 16)),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              if (c.showReorderMode.value)
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_handle),
                ),
              if (c.showDeleteMode.value)
                GestureDetector(
                  onTap: () => c.toggleSelect(id),
                  child: Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selected ? Colors.blue : Colors.grey,
                  ),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    ),
  );
}
