import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_group_controller.dart';
import '../../../widgets/primary_button.dart';

class CreateGroupView extends GetView<CreateGroupController> {
  const CreateGroupView({super.key});
  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Group'), actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Get.offAllNamed('/login');
          },
        )
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
              onChanged: (v) => c.name.value = v,
              decoration: const InputDecoration(labelText: 'Nama Group')),
          const SizedBox(height: 12),
          Obx(() => c.isLoading.value
              ? const CircularProgressIndicator()
              : PrimaryButton(label: 'Buat Group', onPressed: c.create)),
          const SizedBox(height: 12),
          TextButton(
              onPressed: () => Get.toNamed('/join-group'),
              child: const Text('Atau gabung ke group')),
        ]),
      ),
    );
  }
}
