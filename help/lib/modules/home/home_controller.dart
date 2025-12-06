import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_hellping/modules/emergency/emergency_controller.dart';
import '../../services/firebase_auth_service.dart';

class HomeController extends GetxController {
  final groups = <Map>[].obs;
  final isLoading = true.obs;

  final EmergencyController emergencyC = Get.find<EmergencyController>();

  @override
  void onInit() {
    super.onInit();
    loadUserGroups();
    setupEmergencyListener();
    checkInitialMessage();
  }

  void checkInitialMessage() async {
    final message = await FirebaseMessaging.instance.getInitialMessage();
    if (message != null) {
      _handleEmergency(message);
    }
  }

  void setupEmergencyListener() {
    FirebaseMessaging.onMessage.listen((message) {
      _handleEmergency(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleEmergency(message);
    });
  }

  void _handleEmergency(RemoteMessage message) {
    if (message.data.containsKey("emergencyId")) {
      final emergencyId = message.data["emergencyId"];
      final type = message.notification?.title ?? "Emergency Incoming";
      final body = message.notification?.body ?? "Someone needs help";

      // SHOW POPUP HERE (NOT IN CONTROLLER)
      Get.dialog(
        AlertDialog(
          title: Text(type),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () {
                emergencyC.rejectEmergency(emergencyId);
                Get.back();
              },
              child: const Text("Reject"),
            ),
            ElevatedButton(
              onPressed: () {
                emergencyC.acceptEmergency(emergencyId);
                Get.back();
              },
              child: const Text("Accept"),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  void loadUserGroups() async {
    final uid = FirebaseAuthService.currentUser?.uid;
    if (uid == null) return;

    isLoading.value = true;
    groups.clear();

    final groupsRef = FirebaseDatabase.instance.ref("groups");

    groupsRef.onValue.listen((event) {
      groups.clear();

      final data = event.snapshot.value;
      if (data == null) {
        isLoading.value = false;
        return;
      }

      final map = data as Map;

      map.forEach((key, value) {
        final group = Map<String, dynamic>.from(value);

        // CEK apakah user adalah member
        if (group["members"] != null && group["members"][uid] == true) {
          groups.add(group);
        }
      });

      isLoading.value = false;
    });
  }
}
