import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hellping/modules/group/group_detail/group_detail_controller.dart';

class GroupDetailView extends GetView<GroupDetailController> {
  const GroupDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Detail"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = controller.group.value;
        if (data == null) {
          return const Center(child: Text("Group tidak ditemukan"));
        }

        final members = data["members"] ?? {};

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nama Group:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(data["name"] ?? "", style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              Text("Kode Group:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(data["code"] ?? "", style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              Text("Owner ID:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(data["ownerId"] ?? "", style: TextStyle(fontSize: 18)),
              SizedBox(height: 24),
              Text("Members:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: members.keys.map<Widget>((uid) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade100,
                      ),
                      child: Text(uid),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.leaveGroup(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text("Leave Group"),
              )
            ],
          ),
        );
      }),
    );
  }
}
