import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/utils/constants.dart';

class NewsController extends GetxController {
  NewsController(this._newsService);

  final NewsService _newsService;

  // Observable variables
  final _isLoading = false.obs;
  final _articles = <NewsArticle>[].obs;
  final _selectedCategory = 'general'.obs;
  final _error = ''.obs;
  int _requestId = 0;

  // Getters
  bool get isLoading => _isLoading.value;
  List<NewsArticle> get articles => _articles;
  String get selectedCategory => _selectedCategory.value;
  String get error => _error.value;
  List<String> get categories => Constants.categories;

  @override
  void onInit() {
    super.onInit();
    fetchTopHeadlines();
  }

  Future<void> fetchTopHeadlines({String? category}) async {
    final requestId = ++_requestId;

    try {
      _isLoading.value = true;
      _error.value = '';

      final response = await _newsService.getTopHeadlines(
        category: category ?? _selectedCategory.value,
      );

      if (requestId != _requestId) return;
      _articles.assignAll(response.articles);
    } catch (e) {
      if (requestId != _requestId) return;
      _error.value = e.toString();
    } finally {
      if (requestId == _requestId) {
        _isLoading.value = false;
      }
    }
  }

  Future<void> refreshNews() async {
    await fetchTopHeadlines();
  }

  void selectCategory(String category) {
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;
      fetchTopHeadlines(category: category);
    }
  }
}
