import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/services/news_service.dart';

enum SearchStatus { idle, loading, success, empty, error }

class NewsSearchController extends GetxController {
  NewsSearchController(this._newsService);

  final NewsService _newsService;
  final query = ''.obs;
  final articles = <NewsArticle>[].obs;
  final status = SearchStatus.idle.obs;
  final errorMessage = ''.obs;

  late final Worker _searchWorker;
  int _requestId = 0;

  @override
  void onInit() {
    super.onInit();
    _searchWorker = debounce<String>(
      query,
      _runSearch,
      time: const Duration(milliseconds: 550),
    );
  }

  void updateQuery(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      _requestId++;
      query.value = '';
      articles.clear();
      errorMessage.value = '';
      status.value = SearchStatus.idle;
      return;
    }

    query.value = normalized;
  }

  Future<void> searchNow(String value) async {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      updateQuery('');
      return;
    }

    query.value = normalized;
    await _runSearch(normalized);
  }

  Future<void> retry() => _runSearch(query.value);

  Future<void> _runSearch(String searchQuery) async {
    if (searchQuery.isEmpty) return;

    final requestId = ++_requestId;
    status.value = SearchStatus.loading;
    errorMessage.value = '';

    try {
      final response = await _newsService.searchNews(query: searchQuery);
      if (requestId != _requestId) return;

      articles.assignAll(response.articles);
      status.value = response.articles.isEmpty
          ? SearchStatus.empty
          : SearchStatus.success;
    } catch (_) {
      if (requestId != _requestId) return;
      articles.clear();
      errorMessage.value = 'Unable to search the latest stories.';
      status.value = SearchStatus.error;
    }
  }

  @override
  void onClose() {
    _searchWorker.dispose();
    super.onClose();
  }
}
