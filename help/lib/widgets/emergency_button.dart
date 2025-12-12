import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project_hellping/modules/emergency/emergency_controller.dart';
import 'package:project_hellping/modules/home/sos_controller.dart';

class EmergencyButtonWidget extends StatelessWidget {
  const EmergencyButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EmergencyController>();
    final sos = Get.find<SosController>();
    final needC = ''.obs;
    final conditionC = ''.obs;
    final showFields = false.obs;
    final countdown = 0.obs;
    final dragPosition = 0.0.obs; // posisi slider dari kanan
    Timer? timer;

    void sendEmergencyAuto() {
      controller.sendEmergency(
        type: 'Emergency',
        need: needC.value.isEmpty ? "Unknown" : needC.value,
        condition: conditionC.value.isEmpty ? "Unknown" : conditionC.value,
      );

      // Reset
      needC.value = '';
      conditionC.value = '';
      showFields.value = false;
      countdown.value = 0;
      dragPosition.value = 0.0;
      timer?.cancel();
    }

    void cancelEmergency() {
      timer?.cancel();
      showFields.value = false;
      countdown.value = 0;
      dragPosition.value = 0.0;
      Get.snackbar("Dibatalkan", "Emergency dibatalkan",
          snackPosition: SnackPosition.BOTTOM);
    }

    void onEmergencyPressed() {
      if (countdown.value > 0) {
        sendEmergencyAuto();
      } else {
        showFields.value = true;
        countdown.value = 15;
        dragPosition.value = 0.0;
        timer = Timer.periodic(const Duration(seconds: 1), (t) {
          if (countdown.value > 1) {
            countdown.value--;
          } else {
            sendEmergencyAuto();
          }
        });
      }
    }

    const double sliderWidth = 50;
    const double trackWidth = 300;

    return Center(
      child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showFields.value)
                Column(
                  children: [
                    const Text(
                      "Apa yang kamu alami sekarang?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _OptionIcon(
                            icon: Icons.warning,
                            label: "Kritis",
                            selected: conditionC,
                            isCondition: true,
                            iconBackgroundColor: Colors.red),
                        _OptionIcon(
                            icon: Icons.info,
                            label: "Sedang",
                            selected: conditionC,
                            isCondition: true,
                            iconBackgroundColor: Colors.yellow),
                        _OptionIcon(
                            icon: Icons.check_circle,
                            label: "Ringan",
                            selected: conditionC,
                            isCondition: true,
                            iconBackgroundColor: Colors.green),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "Layanan yang kamu perlukan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _OptionIcon(
                            icon: Icons.local_hospital,
                            label: "Rumah Sakit",
                            selected: needC,
                            iconBackgroundColor: Colors.red),
                        _OptionIcon(
                            icon: Icons.local_police,
                            label: "Polisi",
                            selected: needC,
                            iconBackgroundColor: Colors.blue),
                        _OptionIcon(
                            icon: Icons.fire_truck,
                            label: "Pemadam",
                            selected: needC,
                            iconBackgroundColor: Colors.orange),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        "*Kamu bisa menambahkan detail darurat dalam waktu 10 detik, bila situasi memungkinkan.",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.center,
                children: [
                  if (!sos.isSosActive.value && countdown.value == 0)
                    Align(
                      alignment: Alignment.topLeft, // <<< bikin ke kiri page
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .start, // <<< bikin teks rata kiri
                        children: const [
                          Text(
                            "Apakah kamu dalam keadaan darurat?",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "SOS untuk kirim lokasi ke kontak prioritas",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                          SizedBox(height: 300),
                        ],
                      ),
                    ),

                  // Tombol SOS
                  GestureDetector(
                    onTap: controller.isSending.value
                        ? null
                        : () {
                            controller.isEmergencyActive.value = true;
                            sos.startSos();
                            onEmergencyPressed();
                          },
                    child: Obx(() {
                      // Ukuran berubah saat active
                      final size =
                          controller.isEmergencyActive.value ? 180.0 : 231.0;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        width: size,
                        height: size,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // LAYER 1
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                width: size,
                                height: size,
                                decoration: const ShapeDecoration(
                                  color: Color(0xFFF69EA0),
                                  shape: OvalBorder(),
                                ),
                              ),
                            ),

                            // LAYER 2
                            Positioned(
                              left: size * 0.0378,
                              top: size * 0.0378,
                              child: Container(
                                width: size * 0.923,
                                height: size * 0.923,
                                decoration: const ShapeDecoration(
                                  color: Color(0xFFEC2D30),
                                  shape: OvalBorder(),
                                ),
                              ),
                            ),

                            // LAYER 3
                            Positioned(
                              left: size * 0.079,
                              top: size * 0.079,
                              child: Container(
                                width: size * 0.842,
                                height: size * 0.842,
                                decoration: const ShapeDecoration(
                                  color: Color(0xFFD7292C),
                                  shape: OvalBorder(),
                                ),
                              ),
                            ),

                            // LAYER 4
                            Positioned(
                              left: size * 0.12,
                              top: size * 0.12,
                              child: Container(
                                width: size * 0.76,
                                height: size * 0.76,
                                decoration: const ShapeDecoration(
                                  color: Color(0xFFD7292C),
                                  shape: OvalBorder(),
                                ),
                              ),
                            ),

                            // === CHILD CONTENT ===
                            Obx(() {
                              if (controller.isSending.value) {
                                return const CircularProgressIndicator(
                                    color: Colors.white);
                              } else if (countdown.value > 0) {
                                return const SizedBox.shrink();
                              } else {
                                return const Text(
                                  'SOS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                            }),
                          ],
                        ),
                      );
                    }),
                  ),

                  // Countdown
                  if (countdown.value > 0)
                    Positioned(
                      child: Text(
                        '${countdown.value}',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 20),
              // Slide to cancel dari kanan ke kiri
              if (countdown.value > 0)
                Stack(
                  children: [
                    // Track
                    Container(
                      width: trackWidth,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "Geser untuk batalkan",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    // Slider
                    Obx(() => Positioned(
                          left: trackWidth - sliderWidth - dragPosition.value,
                          child: GestureDetector(
                            onHorizontalDragUpdate: (details) {
                              dragPosition.value -= details.delta.dx;
                              if (dragPosition.value < 0)
                                dragPosition.value = 0;
                              if (dragPosition.value >
                                  trackWidth - sliderWidth) {
                                dragPosition.value = trackWidth - sliderWidth;
                              }
                            },
                            onHorizontalDragEnd: (details) {
                              if (dragPosition.value >=
                                  trackWidth - sliderWidth) {
                                cancelEmergency();
                                sos.stopSos();
                              } else {
                                dragPosition.value = 0.0;
                              }
                            },
                            child: Container(
                              width: sliderWidth,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Icon(Icons.arrow_left,
                                  color: Colors.white),
                            ),
                          ),
                        )),
                  ],
                ),
              SizedBox(height: 100),
            ],
          )),
    );
  }
}

class _OptionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final RxString selected;
  final bool isCondition; // true kalau horizontal
  final Color? iconBackgroundColor;

  const _OptionIcon({
    required this.icon,
    required this.label,
    required this.selected,
    this.isCondition = false,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSelected = selected.value == label;

      // Gesture untuk toggle select/unselect
      void handleTap() {
        if (isSelected) {
          selected.value = ''; // unselect kalau sudah dipilih
        } else {
          selected.value = label; // select kalau belum dipilih
        }
      }

      if (isCondition) {
        // STYLE HORIZONTAL
        return GestureDetector(
          onTap: handleTap,
          child: Container(
            width: 105,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.purple : const Color(0x72BBBBBB),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),
                Container(
                  width: 28,
                  height: 28,
                  decoration: ShapeDecoration(
                    color: iconBackgroundColor ?? const Color(0xFFF69EA0),
                    shape: const OvalBorder(),
                  ),
                  child: Icon(icon, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // STYLE KOTAK BESAR
      return GestureDetector(
        onTap: handleTap,
        child: Container(
          width: 89,
          height: 89,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.purple : const Color(0x72BBBBBB),
              width: 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Icon bulat
              Align(
                alignment: Alignment.center,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double iconSize = constraints.maxWidth * 0.50;
                    double iconRadius = iconSize / 2;
                    return Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor ??
                            (isSelected
                                ? Colors.purple
                                : const Color(0xFFF5F5F5)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: iconRadius, color: Colors.white),
                    );
                  },
                ),
              ),

              // Label
              Positioned(
                bottom: 0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    double fontSize = constraints.maxWidth * 0.030;
                    return SizedBox(
                      width: 67,
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: fontSize.clamp(8, 10),
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                          height: 1,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
