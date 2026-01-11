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
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7480C9),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
            const SizedBox(width: 6),
            const Text(
              "Join Group",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double boxSize = constraints.maxWidth * 0.12;
          if (boxSize > 60) boxSize = 60;

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // ===== TITLE =====
                const Text(
                  "Masukkan kode",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                // ===== SUBTITLE =====
                const Text(
                  "Masukkan kode ajakan Anda\nTips: dapatkan kode dari pembuat Circle",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // ===== INPUT KODE (ANTI OVERFLOW) =====
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: boxSize,
                      height: boxSize,
                      child: TextField(
                        controller: inputs[index],
                        focusNode: focus[index],
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        textCapitalization: TextCapitalization.characters,
                        style: TextStyle(
                          fontSize: boxSize * 0.45,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          filled: true,
                          fillColor: Colors.grey[100],
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF7480C9),
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey[300]!,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          final upper = value.toUpperCase();

                          inputs[index].value = TextEditingValue(
                            text: upper,
                            selection: const TextSelection.collapsed(offset: 1),
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

                const SizedBox(height: 50),

                // ===== JOIN BUTTON =====
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.code.value.length == 6 &&
                              !controller.isLoading.value
                          ? controller.joinGroupNow
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B6BB1),
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              "Kirim",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ),
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
