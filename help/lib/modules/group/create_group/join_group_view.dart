import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hellping/modules/group/create_group/group_controller.dart';
import 'package:project_hellping/routes/app_routes.dart';
import 'package:project_hellping/widgets/floating_navbar.dart';

class JoinGroupView extends StatelessWidget {
  final controller = Get.put(GroupController());

  final List<TextEditingController> inputs =
      List.generate(6, (_) => TextEditingController());

  final List<FocusNode> focus = List.generate(6, (_) => FocusNode());

  JoinGroupView({super.key});

  void updateCode() {
    final code = inputs.map((c) => c.text).join().toUpperCase();
    controller.code.value = code;
  }

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
                  "Join Group",
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

      // ===========================
      // RESPONSIVE BODY
      // ===========================
      body: LayoutBuilder(
        builder: (context, constraints) {
          double boxSize = constraints.maxWidth * 0.12;
          if (boxSize > 60) boxSize = 60;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Masukkan kode group:",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),

                // =======================
                // RESPONSIVE 6 INPUT BOX
                // =======================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: boxSize,
                      height: boxSize,
                      child: TextField(
                        controller: inputs[index],
                        focusNode: focus[index],
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: TextStyle(
                          fontSize: boxSize * 0.5,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          final upper = value.toUpperCase();
                          inputs[index].value = TextEditingValue(
                            text: upper,
                            selection: TextSelection.collapsed(offset: 1),
                          );

                          if (upper.isNotEmpty && index < 5) {
                            FocusScope.of(context)
                                .requestFocus(focus[index + 1]);
                          }

                          if (upper.isEmpty && index > 0) {
                            FocusScope.of(context)
                                .requestFocus(focus[index - 1]);
                          }

                          updateCode();
                        },
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 40),

                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.code.value.length == 6 &&
                                !controller.isLoading.value
                            ? controller.joinGroupNow
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Join Group",
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    )),
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
}
