import 'package:get/get.dart';

class SosController extends GetxController {
  var isSosActive = false.obs;

  void startSos() {
    isSosActive.value = true;
  }

  void stopSos() {
    isSosActive.value = false;
  }
}
