import 'package:get/get.dart';

class NavigationController extends GetxController {
  final currentIndex = 0.obs;

  void changePage(int index) {
    if (index >= 0 && index <= 2) {
      currentIndex.value = index;
    }
  }
}
