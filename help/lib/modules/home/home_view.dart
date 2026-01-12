import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hellping/modules/auth/login/login_controller.dart';
import 'package:project_hellping/modules/home/sos_controller.dart';
import 'package:project_hellping/widgets/emergency_button.dart';
import 'package:project_hellping/widgets/floating_navbar.dart';
import 'home_controller.dart';
import '../../routes/app_routes.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loginController = Get.find<LoginController>();
    final homeController = Get.put(HomeController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7480C9),
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 16),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.PROFILE),
              child: Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(Icons.person, color: Colors.grey, size: 28),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(() {
                final location = homeController.currentLocation.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Lokasi Terkini",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location?['street'] ?? "Sedang mengambil lokasi...",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
      body: Stack(children: [
        Container(
          color: const Color(0xFFF5F6F7),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Obx(() {
                  final c = controller;
                  final sos = Get.find<SosController>();

                  if (sos.isSosActive.value) {
                    return const SizedBox.shrink();
                  }

                  String greetingByTime() {
                    final hour = DateTime.now().hour;

                    if (hour >= 4 && hour < 11) return "pagi hari";
                    if (hour >= 11 && hour < 15) return "siang hari";
                    if (hour >= 15 && hour < 18) return "sore hari";
                    return "malam hari";
                  }

                  if (c.needsToAskCondition.value) {
                    return Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bagaimana kondisi kamu ${greetingByTime()} ini?",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _emojiItem("😀", "sangat baik"),
                                _emojiItem("🙂", "baik"),
                                _emojiItem("😐", "biasa saja"),
                                _emojiItem("🙁", "kurang baik"),
                                _emojiItem("😢", "sedih"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // CASE 2 → Sudah menjawab
                  return Card(
                    color: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Text(
                            _emojiFromCondition(c.dailyCondition.value),
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Kondisi kamu hari ini:",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                c.dailyCondition.value ?? "-",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                EmergencyButtonWidget(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        const FloatingNavbar(activeRoute: AppRoutes.HOME),
      ]),
    );
  }

  Widget _emojiItem(String emoji, String moodValue) {
    return InkWell(
      onTap: () => controller.saveDailyCondition(moodValue),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }

  String _emojiFromCondition(String? condition) {
    switch (condition) {
      case "sangat baik":
        return "😀";
      case "baik":
        return "🙂";
      case "biasa saja":
        return "😐";
      case "kurang baik":
        return "🙁";
      case "sedih":
        return "😢";
      default:
        return "❓";
    }
  }
}
