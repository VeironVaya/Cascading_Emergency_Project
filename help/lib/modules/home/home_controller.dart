import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:project_hellping/modules/emergency/emergency_controller.dart';
import 'package:project_hellping/routes/app_routes.dart';
import '../../services/firebase_auth_service.dart';

class HomeController extends GetxController {
  final groups = <Map>[].obs;
  final isLoading = true.obs;
  var currentLocation = Rx<Map<String, dynamic>?>(null);
  final dailyCondition = RxnString(); // kondisi hari ini
  final needsToAskCondition = true.obs; // apakah perlu tanya mood

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

    // --- FETCH emergency data ---
    final emergencyRef =
        FirebaseDatabase.instance.ref("emergencies/$emergencyId");

    final emergencySnap = await emergencyRef.get();
    if (!emergencySnap.exists) return;

    // Extract data
    final senderUid = emergencySnap.child("senderUid").value.toString();
    final need = emergencySnap.child("need").value.toString();
    final condition = emergencySnap.child("condition").value.toString();

    // --- FETCH sender username ---
    final userSnap =
        await FirebaseDatabase.instance.ref("users/$senderUid/username").get();

    final senderName = userSnap.exists ? userSnap.value.toString() : "Pengguna";

    final title = "SOS! ($condition)";
    final body = "$senderName membutuhkan $need";

    // =====================================================
    //     SHOW CUSTOM DIALOG (TANPA UBAH LOGIC)
    // =====================================================
    Get.dialog(
      Material(
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: Stack(
            children: [
              // CARD PUTIH
              Positioned(
                left: 55,
                top: 266,
                child: Container(
                  width: 280,
                  height: 313,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),

              // SOS!
              Positioned(
                left: 153,
                top: 309,
                child: Text(
                  'SOS!',
                  style: TextStyle(
                    color: Color(0xFFA82022),
                    fontSize: 36,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // AVATAR KANAN
              Positioned(
                left: 231,
                top: 364,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage("https://placehold.co/52x52"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // GARIS TENGAH
              Positioned(
                left: 160,
                top: 391,
                child: Container(
                  width: 66,
                  height: 0,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFF444444),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),

              // ICON KIRI
              Positioned(
                left: 101,
                top: 364,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Color(0xFFAFB6E0),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // TEKS: "Karina membutuhkan Ambulan"
              Positioned(
                left: 100,
                top: 422,
                child: Text(
                  '$senderName membutuhkan $need',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              // TEKS: Terima pertolongan?
              Positioned(
                left: 132,
                top: 474,
                child: Text(
                  'Terima pertolongan?',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),

              // BUTTON TIDAK & IYA
              Positioned(
                left: 83,
                top: 499,
                child: Row(
                  spacing: 9,
                  children: [
                    // ------ BUTTON TIDAK ------
                    GestureDetector(
                      onTap: () {
                        emergencyC.rejectEmergency(emergencyId);
                        Get.back();
                      },
                      child: Container(
                        width: 107,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Color(0xFFF69EA0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
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

                    // ------ BUTTON IYA ------
                    GestureDetector(
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
                        width: 107,
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
                  ],
                ),
              ),
            ],
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
