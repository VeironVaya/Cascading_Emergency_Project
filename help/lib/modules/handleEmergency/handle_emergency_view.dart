import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../routes/app_routes.dart';
import 'handle_emergency_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HandleEmergencyView extends GetView<HandleEmergencyController> {
  HandleEmergencyView({super.key});
  final Completer<GoogleMapController> _mapController = Completer();

  String limitWords(String text, int maxWords) {
    final words = text.split(' ');
    if (words.length <= maxWords) return text;
    return words.take(maxWords).join(' ') + '...';
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
            // PANAH KEMBALI
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),

            // JARAK
            const SizedBox(width: 4),

            // USERNAME + WAKTU
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // USERNAME (OBX)
                Obx(() => Text(
                      controller.senderUsername.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    )),

                // WAKTU DEFAULT
                StreamBuilder<DateTime>(
                  stream: Stream.periodic(
                    const Duration(minutes: 1),
                    (_) => DateTime.now(),
                  ),
                  builder: (context, snapshot) {
                    final now = snapshot.data ?? DateTime.now();
                    final hour = now.hour.toString().padLeft(2, '0');
                    final minute = now.minute.toString().padLeft(2, '0');

                    return Text(
                      "Sejak $hour.$minute",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    );
                  },
                )
              ],
            )
          ],
        ),
      ),
      body: Obx(() {
        if (controller.lat.value == 0.0 && controller.lng.value == 0.0) {
          return const Center(child: CircularProgressIndicator());
        }

        final LatLng pos = LatLng(controller.lat.value, controller.lng.value);

        // Animate camera jika sudah ada controller
        _mapController.future.then((mapController) {
          mapController.animateCamera(CameraUpdate.newLatLng(pos));
        });

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition:
                      CameraPosition(target: pos, zoom: 16.5),
                  markers: {
                    Marker(
                      markerId: const MarkerId("emergency_marker"),
                      position: pos,
                      infoWindow: const InfoWindow(title: "Lokasi Darurat"),
                    )
                  },
                  onMapCreated: (mapController) {
                    if (!_mapController.isCompleted) {
                      _mapController.complete(mapController);
                    }
                  },
                ),
              ),

              // =========================
              // CARD INFO EMERGENCY
              // =========================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -45),
                      child: IntrinsicHeight(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                            color: Colors.white,
                          ),
                          margin: const EdgeInsets.only(top: 20, bottom: 1),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Garis kecil atas
                              Container(
                                margin:
                                    const EdgeInsets.only(top: 16, bottom: 17),
                                width: double.infinity,
                                child: Center(
                                  child: Container(
                                    width: 25,
                                    height: 3,
                                    color: const Color(0xFFACACAC),
                                  ),
                                ),
                              ),

                              // Lokasi terakhir
                              Container(
                                margin:
                                    const EdgeInsets.only(bottom: 13, left: 29),
                                child: Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 11),
                                      width: 53,
                                      height: 53,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey.shade300,
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.person,
                                          size: 28,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Lokasi Terakhir",
                                          style: TextStyle(
                                            color: Color(0xFF4A57AB),
                                            fontSize: 12,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  right: 5),
                                              child: const Icon(
                                                Icons.location_on,
                                                size: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Obx(() => InkWell(
                                                  onTap: () => launchUrl(
                                                    Uri.parse(controller
                                                        .mapsUrl.value),
                                                  ),
                                                  child: Text(
                                                    limitWords(
                                                      controller.street.value
                                                              .isNotEmpty
                                                          ? controller
                                                              .street.value
                                                          : "${controller.lat.value}, ${controller.lng.value}",
                                                      3,
                                                    ),
                                                    style: const TextStyle(
                                                      color: Color(0xFF202020),
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                )),
                                          ],
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),

                              // Prioritas / kategori (dynamic: need & condition)
                              Obx(() => Container(
                                    margin: const EdgeInsets.only(bottom: 11),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // NEED
                                        Row(
                                          children: [
                                            Container(
                                              width: 27,
                                              height: 27,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: controller.needIconAsset
                                                      .value.isNotEmpty
                                                  ? SvgPicture.asset(controller
                                                      .needIconAsset.value)
                                                  : const SizedBox(),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(controller.need.value),
                                          ],
                                        ),

                                        const SizedBox(width: 16),

                                        // CONDITION
                                        Row(
                                          children: [
                                            Container(
                                              width: 27,
                                              height: 27,
                                              decoration: BoxDecoration(
                                                color: controller
                                                    .conditionColor.value,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: controller.conditionIcon
                                                          .value !=
                                                      null
                                                  ? Icon(
                                                      controller
                                                          .conditionIcon.value,
                                                      size: 18,
                                                      color: Colors.white,
                                                    )
                                                  : const SizedBox(),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              controller.condition.value,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // LIST HOSPITALS DYNAMIC
                    // =========================
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Garis pemisah
                        Container(
                          color: const Color(0x70C7C7C7),
                          margin: const EdgeInsets.only(
                              bottom: 9, left: 24, right: 24),
                          height: 1,
                          width: double.infinity,
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 18, left: 15),
                          width: double.infinity,
                          child: Text(
                            "Nomor jasa ${controller.need.value}",
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // List dinamis
                        ...controller.hospitals.map((hospital) {
                          return IntrinsicHeight(
                            child: Container(
                              margin: const EdgeInsets.only(
                                  bottom: 15, left: 29, right: 29),
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IntrinsicHeight(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 18),
                                      width: double.infinity,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Gambar/ikon
                                          Container(
                                            margin: const EdgeInsets.only(
                                                right: 11),
                                            width: 70,
                                            height: 70,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: Image.network(
                                                hospital["imageUrl"] ??
                                                    "https://upload.wikimedia.org/wikipedia/commons/8/88/Hospital-de-Bellvitge.jpg",
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),

                                          Expanded(
                                            child: IntrinsicHeight(
                                              child: Container(
                                                margin: const EdgeInsets.only(
                                                    top: 8, right: 48),
                                                width: double.infinity,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      hospital["name"] ??
                                                          "Unknown",
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF202020),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      hospital["address"] ??
                                                          "-",
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF000000),
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Tombol / ikon di kanan
                                          Container(
                                            margin:
                                                const EdgeInsets.only(top: 25),
                                            width: 35,
                                            height: 35,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color:
                                                  Color(0xFF4A57AB), // bg color
                                            ),
                                            child: Material(
                                              color: Colors
                                                  .transparent, // wajib agar ripple terlihat
                                              shape: const CircleBorder(),
                                              child: InkWell(
                                                customBorder:
                                                    const CircleBorder(),
                                                onTap: () async {
                                                  final number = "62916451200";
                                                  final message =
                                                      Uri.encodeComponent(
                                                          "Halo");

                                                  final url = Uri.parse(
                                                    "https://api.whatsapp.com/send?phone=$number&text=$message",
                                                  );

                                                  if (await canLaunchUrl(url)) {
                                                    await launchUrl(
                                                      url,
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  } else {
                                                    debugPrint(
                                                        "Tidak bisa membuka WA");
                                                  }
                                                },
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.phone,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          final url = controller.mapsUrl.value.isNotEmpty
                              ? controller.mapsUrl.value
                              : "https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}";

                          final uri = Uri.parse(url);

                          if (await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            Get.snackbar("Error", "URL Maps tidak valid");
                          }
                        },
                        icon: const Icon(Icons.map),
                        label: const Text("Buka di Maps"),
                      ),
                    ),

                    const SizedBox(height: 30),

                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF7480C9),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 25,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () async {
                          await controller.db
                              .child("emergencies/${controller.emergencyId}")
                              .update({"status": "completed"});

                          Get.snackbar(
                              "Selesai", "Emergency telah diselesaikan");

                          await Future.delayed(
                              const Duration(milliseconds: 300));

                          Get.offAllNamed(AppRoutes.HOME);
                        },
                        child: const Text(
                          "Selesaikan Emergency & Kembali",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
