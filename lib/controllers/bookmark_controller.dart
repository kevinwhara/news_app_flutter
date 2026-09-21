import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';

class BookmarkController extends GetxController {
  final savedArticles = <NewsArticle>[].obs;

  bool isBookmarked(NewsArticle article) {
    final key = _articleKey(article);
    return savedArticles.any((saved) => _articleKey(saved) == key);
  }

  void toggle(NewsArticle article) {
    final key = _articleKey(article);
    final index = savedArticles.indexWhere(
      (saved) => _articleKey(saved) == key,
    );

    if (index >= 0) {
      savedArticles.removeAt(index);
    } else {
      savedArticles.insert(0, article);
    }
  }

  String _articleKey(NewsArticle article) {
    return article.url ?? '${article.title}-${article.publishedAt}';
  }
}
