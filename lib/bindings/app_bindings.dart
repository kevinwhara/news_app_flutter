import 'package:get/get.dart';
import 'package:news_app/services/news_service.dart';

class AppBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsService>(() => NewsService(), fenix: true);
  }
}
