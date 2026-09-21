import 'package:get/get.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/services/news_service.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsController>(() => NewsController(Get.find<NewsService>()));
  }
}
