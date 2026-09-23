import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/news_service.dart';
import 'package:news_app/utils/constants.dart';

class NewsController extends GetxController {
  NewsController(this._newsService);

  final NewsService _newsService;

  // Observable variables
  final _isLoading = false.obs;
  final _isLoadingMore = false.obs;
  final _articles = <NewsArticle>[].obs;
  final _selectedCategory = 'general'.obs;
  final _error = ''.obs;
  final _loadMoreError = ''.obs;
  final _hasMore = true.obs;
  int _requestId = 0;
  int _currentPage = 1;

  static const int _pageSize = 20;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoadingMore => _isLoadingMore.value;
  List<NewsArticle> get articles => _articles;
  String get selectedCategory => _selectedCategory.value;
  String get error => _error.value;
  String get loadMoreError => _loadMoreError.value;
  bool get hasMore => _hasMore.value;
  List<String> get categories => Constants.categories;

  @override
  void onInit() {
    super.onInit();
    fetchTopHeadlines();
  }

  Future<void> fetchTopHeadlines({
    String? category,
    bool loadMore = false,
  }) async {
    if (loadMore &&
        (_isLoading.value || _isLoadingMore.value || !_hasMore.value)) {
      return;
    }

    final requestId = ++_requestId;
    final requestedPage = loadMore ? _currentPage + 1 : 1;

    try {
      if (loadMore) {
        _isLoadingMore.value = true;
        _loadMoreError.value = '';
      } else {
        _isLoading.value = true;
        _isLoadingMore.value = false;
        _error.value = '';
        _loadMoreError.value = '';
      }

      final response = await _newsService.getTopHeadlines(
        category: category ?? _selectedCategory.value,
        page: requestedPage,
        pageSize: _pageSize,
      );

      if (requestId != _requestId) return;

      if (loadMore) {
        final existingKeys = _articles.map(_articleKey).toSet();
        final newArticles = response.articles
            .where((article) => existingKeys.add(_articleKey(article)))
            .toList();
        _articles.addAll(newArticles);
      } else {
        _articles.assignAll(response.articles);
      }

      _currentPage = requestedPage;
      _hasMore.value =
          response.articles.isNotEmpty &&
          _articles.length < response.totalResults;
    } catch (e) {
      if (requestId != _requestId) return;
      if (loadMore) {
        _loadMoreError.value = 'Unable to load more stories.';
      } else {
        _error.value = e.toString();
      }
    } finally {
      if (requestId == _requestId) {
        if (loadMore) {
          _isLoadingMore.value = false;
        } else {
          _isLoading.value = false;
        }
      }
    }
  }

  Future<void> refreshNews() async {
    await fetchTopHeadlines();
  }

  Future<void> loadMoreNews() async {
    await fetchTopHeadlines(loadMore: true);
  }

  void selectCategory(String category) {
    if (_selectedCategory.value != category) {
      _selectedCategory.value = category;
      fetchTopHeadlines(category: category);
    }
  }

  String _articleKey(NewsArticle article) {
    return article.url ?? '${article.title}-${article.publishedAt}';
  }
}
