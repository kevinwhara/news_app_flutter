import 'package:get/get.dart';
import 'package:news_app/controllers/bookmark_controller.dart';
import 'package:news_app/controllers/navigation_controller.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/controllers/news_search_controller.dart';
import 'package:news_app/services/news_service.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewsController>(() => NewsController(Get.find<NewsService>()));
    Get.lazyPut<NewsSearchController>(
      () => NewsSearchController(Get.find<NewsService>()),
    );
    Get.lazyPut<BookmarkController>(() => BookmarkController(), fenix: true);
    Get.lazyPut<NavigationController>(() => NavigationController());
  }
}
