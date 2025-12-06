import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project_hellping/main.dart';
import '../priority/priority_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmergencyController extends GetxController {
  // ====== Firebase & Controllers ======
  final auth = FirebaseAuth.instance;
  final db = FirebaseDatabase.instance.ref();
  final priorityController = Get.find<PriorityController>();

  // ====== FCM & Local Notifications ======
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ====== State ======
  RxBool isSending = false.obs;

  @override
  void onInit() {
    super.onInit();
    setupFCM();
  }

  Future<void> setupFCM() async {
    // Request permission
    await _messaging.requestPermission();

    // Ambil token user dan simpan ke database
    final uid = auth.currentUser!.uid;
    final token = await _messaging.getToken();
    await db.child("users/$uid").update({"fcmToken": token});

    // Buat channel notifikasi Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'emergency_channel',
      'Emergency Alerts',
      description: 'This channel is used for emergency notifications.',
      importance: Importance.max,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Listener notifikasi foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
          ),
        );
      }
    });

    // Listener saat user buka notifikasi
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final mapsUrl = message.data['mapsUrl'];
      if (mapsUrl != null) launchUrlString(mapsUrl);
    });
  }

  // ====== Lokasi ======
  Future<Map<String, dynamic>> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception("Location services are disabled.");

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return {
      'lat': position.latitude,
      'lng': position.longitude,
      'mapsUrl':
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}"
    };
  }

// ====== Kirim Emergency ======
  Future<void> sendEmergency({
    required String type,
    String? condition,
    required String need,
  }) async {
    try {
      isSending.value = true;

      final uid = auth.currentUser!.uid;
      final locationData = await getCurrentLocation();
      final priorities = priorityController.priorityList;

      if (priorities.isEmpty) {
        Get.snackbar("Error", "Belum ada user prioritas");
        return;
      }

      // === Build payload for backend ===
      final payload = {
        "senderUid": uid,
        "type": type,
        "condition": condition ?? "",
        "need": need,
        "location": locationData,
        "priorities": priorities,
      };

      // === Send to backend ===
      final res = await http.post(
        Uri.parse("http://192.168.1.77:5000/emergency"), // Android emulator
        headers: {
          "Content-Type": "application/json",
          "x-api-key": "123456",
        },
        body: jsonEncode(payload),
      );

      print("Backend response: ${res.body}");

      if (res.statusCode == 200) {
        Get.snackbar("Success", "Emergency sent!");
      } else {
        Get.snackbar("Error", "Backend error: ${res.body}");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isSending.value = false;
    }
  }

  // ========== ACCEPT EMERGENCY ==========
  Future<void> acceptEmergency(String emergencyId) async {
    final res = await http.post(
      Uri.parse("http://192.168.1.77:5000/emergency/$emergencyId/accept"),
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "123456",
      },
    );

    print("Backend accept response: ${res.body}");
  }

// ========== REJECT EMERGENCY ==========
  Future<void> rejectEmergency(String emergencyId) async {
    final res = await http.post(
      Uri.parse("http://192.168.1.77:5000/emergency/$emergencyId/reject"),
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "123456",
      },
    );

    print("Backend reject response: ${res.body}");
  }
}
