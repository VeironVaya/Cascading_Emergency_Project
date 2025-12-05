import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hellping/modules/emergency/emergency_controller.dart';

class EmergencyButtonWidget extends StatelessWidget {
  final String type;
  final Color color;
  final String label;

  const EmergencyButtonWidget({
    super.key,
    required this.type,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmergencyController>();

    return Obx(() => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            minimumSize: const Size(double.infinity, 100),
          ),
          onPressed: controller.isSending.value
              ? null
              : () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      final needC = TextEditingController();
                      final conditionC = TextEditingController();

                      return AlertDialog(
                        title: Text("Emergency $label"),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (type == 'yellow')
                              TextField(
                                controller: conditionC,
                                decoration: const InputDecoration(
                                    labelText: "Kondisi Darurat"),
                              ),
                            TextField(
                              controller: needC,
                              decoration:
                                  const InputDecoration(labelText: "Kebutuhan"),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Batal"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              controller.sendEmergency(
                                type: type,
                                condition:
                                    type == 'yellow' ? conditionC.text : null,
                                need: needC.text,
                              );
                              Navigator.pop(context);
                            },
                            child: const Text("Kirim"),
                          ),
                        ],
                      );
                    },
                  );
                },
          child: controller.isSending.value
              ? const CircularProgressIndicator(
                  color: Colors.white,
                )
              : Text(
                  label,
                  style: const TextStyle(fontSize: 20),
                ),
        ));
  }
}
