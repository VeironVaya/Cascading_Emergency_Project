import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_hellping/modules/emergency/emergency_controller.dart';
import 'package:project_hellping/routes/app_routes.dart';
import '../../services/firebase_auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeController extends GetxController {
  final groups = <Map>[].obs;
  final isLoading = true.obs;
  var currentLocation = Rx<Map<String, dynamic>?>(null);
  final dailyCondition = RxnString(); // kondisi hari ini
  final needsToAskCondition = true.obs; // apakah perlu tanya mood
  final auth = FirebaseAuth.instance;

  final EmergencyController emergencyC = Get.find<EmergencyController>();

  @override
  void onInit() {
    super.onInit();
    loadUserGroups();
    setupEmergencyListener();
    checkInitialMessage();
    checkDailyCondition();
    fetchLocation(); // cek mood hari ini
  }

  // -----------------------------------------------------------
  // EMERGENCY HANDLER
  // -----------------------------------------------------------
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

  void _handleEmergency(RemoteMessage message) async {
    if (!message.data.containsKey("emergencyId")) return;

    final emergencyId = message.data["emergencyId"];

    // Fetch emergency data
    final emergencyRef =
        FirebaseDatabase.instance.ref("emergencies/$emergencyId");
    final emergencySnap = await emergencyRef.get();
    if (!emergencySnap.exists) return;

    final senderUid = emergencySnap.child("senderUid").value.toString();
    final need = emergencySnap.child("need").value.toString();
    final condition = emergencySnap.child("condition").value.toString();

    // Fetch sender info
    final userSnap =
        await FirebaseDatabase.instance.ref("users/$senderUid/username").get();
    final senderName = userSnap.exists ? userSnap.value.toString() : "Pengguna";

    // Get sender avatar if available
    final avatarSnap =
        await FirebaseDatabase.instance.ref("users/$senderUid/avatar").get();
    final senderAvatar = avatarSnap.exists
        ? avatarSnap.value.toString()
        : "https://placehold.co/52x52";

    Get.dialog(
      Material(
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: Container(
            width: 280,
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // SOS Title
                Text(
                  'SOS!',
                  style: TextStyle(
                    color: Color(0xFFA82022),
                    fontSize: 36,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 24),

                // Icons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Need Icon (Left)
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Color(0xFFAFB6E0),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getNeedIcon(need),
                        color: Colors.white,
                        size: 28,
                      ),
                    ),

                    // Dotted Line
                    Container(
                      width: 66,
                      height: 2,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      child: CustomPaint(
                        painter: DashedLinePainter(color: Color(0xFF444444)),
                      ),
                    ),

                    // Sender Avatar (Right)
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade300,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 28,
                        ),
                      ),
                    )
                  ],
                ),

                SizedBox(height: 16),

                // Message Text
                Text(
                  '$senderName membutuhkan $need',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),

                SizedBox(height: 24),

                // Question Text
                Text(
                  'Terima pertolongan?',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),

                SizedBox(height: 16),

                // Buttons Row
                Row(
                  children: [
                    // Tidak Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final know = await Get.defaultDialog<bool>(
                            title: "Konfirmasi",
                            middleText: "Apakah kamu mengenal $senderName?",
                            textCancel: "Tidak",
                            textConfirm: "Ya",
                            confirmTextColor: Colors.white,
                            onConfirm: () => Get.back(result: true),
                            onCancel: () => Get.back(result: false),
                          );

                          // Tutup dialog utama SETELAH dialog konfirmasi selesai
                          Get.back();

                          if (know == false) {
                            emergencyC.priorityController
                                .removeHelperFromOtherUser(
                              senderUid,
                              auth.currentUser!.uid,
                            );

                            Get.snackbar(
                              "Info",
                              "Kamu dihapus dari priority list $senderName",
                            );
                          }

                          emergencyC.rejectEmergency(emergencyId);
                        },
                        child: Container(
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Color(0xFFF69EA0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Tidak',
                              style: TextStyle(
                                color: Color(0xFFF05759),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 9),

                    // Iya Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          emergencyC.acceptEmergency(emergencyId);
                          Get.back();

                          Future.delayed(Duration(milliseconds: 250), () {
                            Get.toNamed(
                              AppRoutes.HANDLE_EMERGENCY,
                              arguments: emergencyId,
                            );
                          });
                        },
                        child: Container(
                          height: 34,
                          decoration: BoxDecoration(
                            color: Color(0xFF5160BC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Iya',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
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
      barrierDismissible: false,
    );
  }

  // -----------------------------------------------------------
  // GROUP LOADER
  // -----------------------------------------------------------
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

        if (group["members"] != null && group["members"][uid] == true) {
          groups.add(group);
        }
      });

      isLoading.value = false;
    });
  }

  // -----------------------------------------------------------
  // DAILY CONDITION / MOOD CHECKER
  // -----------------------------------------------------------
  void checkDailyCondition() async {
    final uid = FirebaseAuthService.currentUser?.uid;
    if (uid == null) return;

    final ref = FirebaseDatabase.instance.ref("users/$uid/dailyStatus");
    final snapshot = await ref.get();

    if (!snapshot.exists) {
      needsToAskCondition.value = true;
      return;
    }

    final data = snapshot.value as Map;
    final lastUpdate = data["lastUpdate"] as int?;
    final condition = data["condition"];

    if (lastUpdate == null) {
      needsToAskCondition.value = true;
      return;
    }

    final lastTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
    final now = DateTime.now();

    // hitung selisih jam
    final diffHours = now.difference(lastTime).inHours;

    if (diffHours >= 6) {
      // sudah lewat 6 jam, tanya lagi
      needsToAskCondition.value = true;
      return;
    }

    // belum lewat 6 jam
    dailyCondition.value = condition;
    needsToAskCondition.value = false;
  }

  // -----------------------------------------------------------
  // SAVE DAILY CONDITION
  // -----------------------------------------------------------
  void saveDailyCondition(String condition) async {
    final uid = FirebaseAuthService.currentUser?.uid;
    if (uid == null) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    await FirebaseDatabase.instance.ref("users/$uid/dailyStatus").set({
      "lastUpdate": now,
      "condition": condition,
    });

    dailyCondition.value = condition;
    needsToAskCondition.value = false;
  }

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

  void fetchLocation() async {
    final location = await getCurrentLocation();
    if (location != null) {
      // Bisa tambahkan reverse geocoding untuk nama jalan
      // misal pake Geocoding package
      final placemarks = await placemarkFromCoordinates(
        location['lat'],
        location['lng'],
      );
      final street = placemarks.first.street ?? '';
      currentLocation.value = {
        'lat': location['lat'],
        'lng': location['lng'],
        'mapsUrl': location['mapsUrl'],
        'street': street,
      };
    }
  }
}

// Helper function to get icon based on need
IconData _getNeedIcon(String need) {
  switch (need.toLowerCase()) {
    case 'ambulan':
    case 'ambulance':
      return Icons.local_hospital;
    case 'pemadam kebakaran':
    case 'fire':
      return Icons.local_fire_department;
    case 'polisi':
    case 'police':
      return Icons.local_police;
    default:
      return Icons.help_outline;
  }
}

// Custom painter for dotted line
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    const dashWidth = 4;
    const dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
