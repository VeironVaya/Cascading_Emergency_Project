import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../routes/app_routes.dart';
import 'handle_emergency_controller.dart';

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
                const Text(
                  "Sejak 20.00",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
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
                                      child: Image.network(
                                        "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/8iRuddPB0k/mi5ux51t_expires_30_days.png",
                                        fit: BoxFit.fill,
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
                                              width: 11,
                                              height: 16,
                                              child: Image.network(
                                                "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/8iRuddPB0k/1ih1h6yv_expires_30_days.png",
                                                fit: BoxFit.fill,
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
                              Container(
                                margin: const EdgeInsets.only(bottom: 11),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .center, // <-- ini buat center
                                  children: [
                                    // Need
                                    Row(
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          width: 27,
                                          height: 27,
                                          child: Image.network(
                                            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/8iRuddPB0k/8y29hnyy_expires_30_days.png",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        Text(
                                          controller.need
                                              .value, // Ambulan diganti need
                                          style: const TextStyle(
                                            color: Color(0xFF000000),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    // Condition
                                    Row(
                                      children: [
                                        Container(
                                          margin:
                                              const EdgeInsets.only(right: 5),
                                          width: 27,
                                          height: 27,
                                          child: Image.network(
                                            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/8iRuddPB0k/kyuhjtgi_expires_30_days.png",
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        Text(
                                          controller.condition
                                              .value, // Kesehatan diganti condition
                                          style: const TextStyle(
                                            color: Color(0xFF000000),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
                                            child: Material(
                                              color: Colors
                                                  .transparent, // wajib ada Material supaya InkWell hidup
                                              child: InkWell(
                                                onTap: () async {
                                                  final number =
                                                      "6281234567890";
                                                  final message =
                                                      Uri.encodeComponent(
                                                          ""); // pesan kosong

                                                  final url = Uri.parse(
                                                    "https://wa.me/$number?text=$message",
                                                  );

                                                  if (await canLaunchUrl(url)) {
                                                    await launchUrl(
                                                      url,
                                                      mode: LaunchMode
                                                          .externalApplication,
                                                    );
                                                  } else {
                                                    print(
                                                        "Tidak bisa membuka WA");
                                                  }
                                                },
                                                child: Image.network(
                                                  "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/8iRuddPB0k/3vzeh85e_expires_30_days.png",
                                                  fit: BoxFit.fill,
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
                        onPressed: () async {
                          final url = controller.mapsUrl.value.isNotEmpty
                              ? controller.mapsUrl.value
                              : "https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}";

                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(
                              Uri.parse(url),
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
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 25),
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
                          style: TextStyle(fontSize: 16, color: Colors.white),
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
