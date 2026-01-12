import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:project_hellping/routes/app_routes.dart';
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
  var isEmergencyActive = false.obs;

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
        Uri.parse("http://192.168.1.67:5000/emergency"),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": "123456",
        },
        body: jsonEncode(payload),
      );

      print("Backend response: ${res.body}");

      if (res.statusCode == 200) {
        // Tampilkan dialog SOS Success menggunakan Get.dialog
        Get.dialog(
          SOSSuccessDialog(
            onClose: () {
              Get.back(); // Tutup dialog
              // Opsional: Kembali ke halaman sebelumnya
              // Get.back(); // Uncomment jika ingin auto back
            },
          ),
          barrierDismissible: false, // Dialog hanya bisa ditutup dengan tombol
        );
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
      Uri.parse("http://192.168.1.67:5000/emergency/$emergencyId/accept"),
      headers: {
        "Content-Type": "application/json",
        "x-api-key": "123456",
      },
    );

    print("Backend accept response: ${res.body}");
  }

  Future<void> rejectEmergency(
    String emergencyId, {
    String? senderUid, // pemilik priority list
  }) async {
    try {
      final res = await http.post(
        Uri.parse("http://192.168.1.67:5000/emergency/$emergencyId/reject"),
        headers: {
          "Content-Type": "application/json",
          "x-api-key": "123456",
        },
      );

      print("Backend reject response: ${res.body}");

      if (senderUid != null) {
        final know = await Get.defaultDialog<bool>(
          title: "Konfirmasi",
          middleText: "Apakah kamu mengenal orang ini?",
          textCancel: "Tidak",
          textConfirm: "Ya",
          onConfirm: () => Get.back(result: true),
          onCancel: () => Get.back(result: false),
        );

        if (know == false) {
          final auth = FirebaseAuth.instance;
          final currentUserUid = auth.currentUser!.uid;

          // Hapus helper dari priority list pemilik emergency
          priorityController.removeHelperFromOtherUser(
              senderUid, currentUserUid);
          Get.snackbar("Info", "User telah dihapus dari priority list");
        }
      }
    } catch (e) {
      print("Reject emergency error: $e");
    }
  }
}

class SOSSuccessDialog extends StatelessWidget {
  final VoidCallback? onClose;

  const SOSSuccessDialog({
    Key? key,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'SOS terkirim',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3E6F),
              ),
            ),
            const SizedBox(height: 24),

            // Illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2D3E6F),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Phone illustration
                  Container(
                    width: 60,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E7FE8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.favorite,
                        color: Color(0xFFE91E63),
                        size: 24,
                      ),
                    ),
                  ),
                  // Megaphone icon positioned at top-left
                  Positioned(
                    top: 20,
                    left: 15,
                    child: Transform.rotate(
                      angle: -0.5,
                      child: const Icon(
                        Icons.campaign,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Message
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D3E6F),
                  height: 1.5,
                ),
                children: [
                  TextSpan(text: 'Kami sudah mengirim SOS pada\n'),
                  TextSpan(
                    text: 'Kontak Prioritas',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Get.offAllNamed(AppRoutes.HOME);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B6FB5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Keluar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
