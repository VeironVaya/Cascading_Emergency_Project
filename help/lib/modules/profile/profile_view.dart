import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hellping/modules/profile/profile_controller.dart';
import 'package:project_hellping/routes/app_routes.dart';
import 'package:project_hellping/widgets/floating_navbar.dart';

class ProfileView extends StatelessWidget {
  final ProfileController controller = Get.put(ProfileController());
  final RxBool isEditMode = false.obs;
  final _formKey = GlobalKey<FormState>();

  ProfileView({super.key});
  void _showMedicalHistoryDialog(BuildContext context) {
    final RxList<TextEditingController> controllers =
        <TextEditingController>[].obs;

    final existing = controller.medicalHistory.value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (existing.isEmpty) {
      controllers.add(TextEditingController());
    } else {
      for (final item in existing) {
        controllers.add(TextEditingController(text: item));
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Obx(
                () => SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ===== HEADER =====
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Riwayat Penyakit",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFF4B5BB5),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.add,
                                  size: 18, color: Colors.white),
                              onPressed: () {
                                controllers.add(TextEditingController());
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Column(
                        children: List.generate(controllers.length, (index) {
                          final c = controllers[index];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.radio_button_unchecked,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 10),

                                // ===== TEXT FIELD =====
                                Expanded(
                                  child: TextField(
                                    controller: c,
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      hintText: "",
                                      border: UnderlineInputBorder(),
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 6),

                                // ===== DELETE BUTTON =====
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    if (controllers.length > 1) {
                                      controllers.removeAt(index);
                                    } else {
                                      // kalau tinggal satu, cukup kosongkan text
                                      controllers[index].clear();
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 28),

                      // ===== ACTION BUTTON =====
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Get.back(),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text("Batal"),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4B5BB5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () async {
                                final result = controllers
                                    .map((c) => c.text.trim())
                                    .where((e) => e.isNotEmpty)
                                    .toList();

                                await controller.updateProfile(
                                  newName: controller.name.value,
                                  newAge: controller.age.value,
                                  newAddress: controller.address.value,
                                  newMedicalHistory: result.join(', '),
                                );

                                Get.back();
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text("Simpan"),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
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
              onPressed: () => Get.offAllNamed(AppRoutes.HOME),
            ),
            const SizedBox(width: 6),
            const Text(
              "Profil",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await controller.logout();
              },
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Header Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  color: Colors.white,
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Icon
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF7480C9),
                                width: 3,
                              ),
                              color: const Color(0xFF7480C9),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 45,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.name.value,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "@${controller.username.value.toLowerCase()}",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Edit Button at top right
                        Align(
                          alignment: Alignment.topRight,
                          child: Obx(() => ElevatedButton.icon(
                                icon: Icon(
                                  isEditMode.value ? Icons.close : Icons.edit,
                                  size: 18,
                                ),
                                label: Text(
                                    isEditMode.value ? "Batalkan" : "Edit"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF7480C9),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  isEditMode.toggle();
                                  if (!isEditMode.value) {
                                    _formKey.currentState?.reset();
                                  }
                                },
                              )),
                        ),
                        const SizedBox(height: 16),
                        // Username (Read-only)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Username",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: controller.username.value,
                              readOnly: true,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Nama
                        Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Nama",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: controller.name.value,
                                  readOnly: !isEditMode.value,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: isEditMode.value
                                        ? Colors.white
                                        : Colors.grey.shade100,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  onChanged: (val) =>
                                      controller.name.value = val,
                                  validator: isEditMode.value
                                      ? (val) => val == null || val.isEmpty
                                          ? "Nama wajib diisi"
                                          : null
                                      : null,
                                ),
                              ],
                            )),
                        const SizedBox(height: 20),

                        // Umur
                        Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Umur",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: controller.age.value.toString(),
                                  readOnly: !isEditMode.value,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: isEditMode.value
                                        ? Colors.white
                                        : Colors.grey.shade100,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  onChanged: (val) => controller.age.value =
                                      int.tryParse(val) ?? 0,
                                  validator: isEditMode.value
                                      ? (val) {
                                          if (val == null || val.isEmpty) {
                                            return "Umur wajib diisi";
                                          }
                                          if (int.tryParse(val) == null) {
                                            return "Umur harus angka";
                                          }
                                          return null;
                                        }
                                      : null,
                                ),
                              ],
                            )),
                        const SizedBox(height: 20),

                        // Alamat
                        Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Alamat",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  initialValue: controller.address.value,
                                  readOnly: !isEditMode.value,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    filled: true,
                                    fillColor: isEditMode.value
                                        ? Colors.white
                                        : Colors.grey.shade100,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  onChanged: (val) =>
                                      controller.address.value = val,
                                  validator: isEditMode.value
                                      ? (val) => val == null || val.isEmpty
                                          ? "Alamat wajib diisi"
                                          : null
                                      : null,
                                ),
                              ],
                            )),
                        const SizedBox(height: 20),

                        // Riwayat Penyakit
                        Obx(() => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Riwayat Penyakit",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    if (isEditMode.value) {
                                      _showMedicalHistoryDialog(context);
                                    }
                                  },
                                  child: AbsorbPointer(
                                    child: TextFormField(
                                      initialValue:
                                          controller.medicalHistory.value,
                                      readOnly: true,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        filled: true,
                                        fillColor: isEditMode.value
                                            ? Colors.white
                                            : Colors.grey.shade100,
                                        hintText: "Contoh : GERD",
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )),

                        // Save Button (only visible in edit mode)
                        Obx(() => isEditMode.value
                            ? Padding(
                                padding: const EdgeInsets.only(top: 28),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF7480C9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        controller.updateProfile(
                                          newName: controller.name.value,
                                          newAge: controller.age.value,
                                          newAddress: controller.address.value,
                                          newMedicalHistory:
                                              controller.medicalHistory.value,
                                        );
                                        isEditMode.value = false;
                                      }
                                    },
                                    child: const Text(
                                      "Simpan",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink()),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: FloatingNavbar(activeRoute: AppRoutes.PROFILE),
      ),
    );
  }
}
