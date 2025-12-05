import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'priority_controller.dart';

class PriorityView extends GetView<PriorityController> {
  const PriorityView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;

    return Scaffold(
      appBar: AppBar(title: const Text("Priority Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Input Username
            TextField(
              decoration: const InputDecoration(
                labelText: "Search username",
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => c.searchUsername.value = v,
            ),
            const SizedBox(height: 12),

            // Button Add
            Obx(() => c.isLoading.value
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: c.addPriority,
                    child: const Text("Add Priority"),
                  )),
            const SizedBox(height: 20),

            // List Priority
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: c.priorityList.length,
                    itemBuilder: (context, index) {
                      final item = c.priorityList[index];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(item['priorityLevel'].toString()),
                          ),
                          title: Text(item['targetUsername']),
                          subtitle: Text("UID: ${item['targetUid']}"),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'up',
                                child: Text("Naikkan Priority"),
                              ),
                              const PopupMenuItem(
                                value: 'down',
                                child: Text("Turunkan Priority"),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text("Hapus"),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'up' && item['priorityLevel'] > 1) {
                                c.updatePriority(
                                    item['id'], item['priorityLevel'] - 1);
                              }
                              if (value == 'down') {
                                c.updatePriority(
                                    item['id'], item['priorityLevel'] + 1);
                              }
                              if (value == 'delete') {
                                c.deletePriority(item['id']);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
