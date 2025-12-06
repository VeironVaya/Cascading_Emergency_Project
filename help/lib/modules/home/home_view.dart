import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:project_hellping/modules/auth/login/login_controller.dart';
import 'package:project_hellping/widgets/emergency_button.dart';
import 'home_controller.dart';
import '../../widgets/menu_container.dart';
import '../../routes/app_routes.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loginController = Get.find<LoginController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await loginController.logout();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            EmergencyButtonWidget(
              type: 'red',
              color: Colors.red,
              label: 'Red Emergency',
            ),
            const SizedBox(height: 20),
            MenuContainer(
              title: "Main Menu",
              items: [
                MenuItem(
                  title: "Create Group",
                  route: AppRoutes.CREATE_GROUP,
                  icon: Icons.group_add,
                ),
                MenuItem(
                  title: "Join Group",
                  route: AppRoutes.JOIN_GROUP,
                  icon: Icons.group,
                ),
                MenuItem(
                  title: "Priority Settings",
                  route: AppRoutes.PRIORITY,
                  icon: Icons.star,
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                _showTestNotification();
              },
              child: const Text("Test Push Notification"),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "My Groups",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.groups.isEmpty) {
                  return const Center(
                      child: Text("Belum bergabung di group manapun"));
                }

                return ListView.builder(
                  itemCount: controller.groups.length,
                  itemBuilder: (context, index) {
                    final group = controller.groups[index];

                    return Card(
                      child: ListTile(
                        title: Text(group["name"] ?? "Unknown"),
                        subtitle: Text("Kode: ${group["code"]}"),
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.GROUP_DETAIL,
                            arguments: {
                              "groupId": group["id"],
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showTestNotification() {
    // Menggunakan flutter_local_notifications untuk simulasi
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'test_channel',
      'Test Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    flutterLocalNotificationsPlugin.show(
      0,
      "Test Notification",
      "Ini adalah push test!",
      notificationDetails,
    );
  }
}
