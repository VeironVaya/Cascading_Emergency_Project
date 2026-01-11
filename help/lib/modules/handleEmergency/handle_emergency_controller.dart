import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HandleEmergencyController extends GetxController {
  final DatabaseReference db = FirebaseDatabase.instance.ref();

  late final String emergencyId;

  // CORE DATA
  RxDouble lat = 0.0.obs;
  RxDouble lng = 0.0.obs;
  RxString street = "".obs; // <-- Nama jalan otomatis
  RxString mapsUrl = "".obs; // <-- URL Maps otomatis

  RxString type = "".obs;
  RxString status = "".obs;
  RxString need = "".obs;
  RxString condition = "".obs;
  RxString createdAt = "".obs;

  // SENDER
  RxString senderUid = "".obs;
  RxString senderUsername = "Loading...".obs;

  // PRIORITY SYSTEM
  RxInt currentPriorityIndex = 0.obs;
  RxList<Map<String, dynamic>> priorities = <Map<String, dynamic>>[].obs;

  // HOSPITALS
  RxList<Map<String, dynamic>> hospitals = <Map<String, dynamic>>[].obs;
  RxBool loadingHospitals = false.obs;

  // UI REPRESENTATION
  Rx<IconData?> conditionIcon = Rx<IconData?>(null);
  Rx<Color> conditionColor = Colors.transparent.obs;

  RxString needIconAsset = "".obs;

  @override
  void onInit() {
    super.onInit();
    emergencyId = Get.arguments as String;
    loadEmergency(emergencyId);

    // Trigger fetch rumah sakit jika koordinat & need tersedia
    everAll([lat, lng, need], (_) {
      if (lat.value != 0.0 && lng.value != 0.0 && need.value.isNotEmpty) {
        fetchNearbyPlaces();
        fetchStreetFromCoordinates(); // <-- reverse geocoding otomatis
      }
    });
  }

  /// Load emergency detail
  Future<void> loadEmergency(String id) async {
    final snapshot = await db.child("emergencies/$id").get();
    if (!snapshot.exists) return;

    final raw = snapshot.value;
    if (raw is! Map) return;

    final data = Map<String, dynamic>.from(raw);

    // LOCATION ----------------------------
    if (data["location"] != null) {
      lat.value = (data["location"]["lat"] ?? 0).toDouble();
      lng.value = (data["location"]["lng"] ?? 0).toDouble();
    }

    mapsUrl.value = data["location"]?["mapsUrl"] ?? "";

    // BASIC INFO --------------------------
    type.value = data["type"] ?? "";
    status.value = data["status"] ?? "";
    need.value = data["need"] ?? "";
    condition.value = data["condition"] ?? "";
    updateNeedUI(need.value);
    updateConditionUI(condition.value);
    createdAt.value = data["createdAt"]?.toString() ?? "";

    // SENDER ------------------------------
    senderUid.value = data["senderUid"] ?? "";
    _loadSenderUsername();

    // PRIORITY FIX ------------------------
    currentPriorityIndex.value = data["currentPriorityIndex"] ?? 0;
    if (data["priorities"] != null) {
      priorities.value = _parsePriorities(data["priorities"]);
    }
  }

  List<Map<String, dynamic>> _parsePriorities(dynamic raw) {
    try {
      if (raw is List)
        return raw.map((e) => Map<String, dynamic>.from(e)).toList();
      if (raw is Map)
        return raw.values.map((e) => Map<String, dynamic>.from(e)).toList();
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> _loadSenderUsername() async {
    if (senderUid.isEmpty) return;
    final snapshot = await db.child("users/${senderUid.value}").get();
    if (snapshot.exists) {
      final user = Map<String, dynamic>.from(snapshot.value as Map);
      senderUsername.value = user["username"] ?? "Unknown User";
    } else {
      senderUsername.value = "Unknown User";
    }
  }

  /// Reverse geocoding → nama jalan otomatis
  Future<void> fetchStreetFromCoordinates() async {
    if (lat.value == 0.0 || lng.value == 0.0) return;

    try {
      final placemarks = await placemarkFromCoordinates(lat.value, lng.value);
      if (placemarks.isNotEmpty) {
        street.value = placemarks.first.street ?? "";
      }
      mapsUrl.value =
          "https://www.google.com/maps/search/?api=1&query=${lat.value},${lng.value}";
    } catch (e) {
      street.value = "";
      print("Error reverse geocoding: $e");
    }
  }

  Future<void> fetchNearbyPlaces() async {
    loadingHospitals.value = true;

    // Mapping fleksibel: kebutuhan → OSM amenity
    final Map<String, String> needToAmenity = {
      "Rumah Sakit": "hospital",
      "RS": "hospital",
      "Puskesmas": "doctors",
      "Klinik": "clinic",
      "Apotek": "pharmacy",
      "Ambulan": "emergency",
      "Ambulance": "emergency",
      "Dokter": "doctors",
      "Pemadam": "fire_station",
      "Polisi": "police",
    };

    final amenity =
        needToAmenity[need.value] ?? "hospital"; // fallback ke hospital

    // Bisa sesuaikan radius: misal 5000 meter = 5 km
    final radius = 5000;

    final query = '''
    [out:json];
    node(around:$radius,${lat.value},${lng.value})["amenity"="$amenity"];
    out;
  ''';

    final url =
        "https://overpass-api.de/api/interpreter?data=${Uri.encodeComponent(query)}";

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final List elements = data["elements"] ?? [];

        hospitals.value = elements.map((e) {
          final tags = e["tags"] ?? {};
          final name = tags["name"] ?? need.value;
          final address = tags["addr:street"] ??
              tags["addr:full"] ??
              tags["address"] ??
              "-";
          final double hLat = e["lat"];
          final double hLng = e["lon"];
          return {
            "name": name,
            "address": address,
            "lat": hLat,
            "lng": hLng,
            "mapsUrl":
                "https://www.google.com/maps/search/?api=1&query=$hLat,$hLng",
          };
        }).toList();
      } else {
        print("❌ HTTP ERROR OSM: ${res.statusCode}");
        hospitals.clear();
      }
    } catch (e) {
      print("❌ ERROR FETCH OSM: $e");
      hospitals.clear();
    }

    loadingHospitals.value = false;
  }

  void updateConditionUI(String value) {
    switch (value) {
      case "Kritis":
        conditionIcon.value = Icons.warning;
        conditionColor.value = Colors.red;
        break;
      case "Sedang":
        conditionIcon.value = Icons.info;
        conditionColor.value = Colors.yellow;
        break;
      case "Ringan":
        conditionIcon.value = Icons.check_circle;
        conditionColor.value = Colors.green;
        break;
      default:
        conditionIcon.value = null;
        conditionColor.value = Colors.transparent;
    }
  }

  void updateNeedUI(String value) {
    switch (value) {
      case "Rumah Sakit":
        needIconAsset.value = "assets/icons/noto--ambulance.svg";
        break;
      case "Polisi":
        needIconAsset.value = "assets/icons/twemoji--police-officer.svg";
        break;
      case "Pemadam":
        needIconAsset.value = "assets/icons/openmoji--firefighter.svg";
        break;
      default:
        needIconAsset.value = "";
    }
  }
}
