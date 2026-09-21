import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/bookmark_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';

class BookmarkButton extends GetView<BookmarkController> {
  const BookmarkButton({
    super.key,
    required this.article,
    this.backgroundColor,
  });

  final NewsArticle article;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSaved = controller.isBookmarked(article);
      return IconButton(
        tooltip: isSaved ? 'Remove bookmark' : 'Save article',
        onPressed: () => controller.toggle(article),
        style: IconButton.styleFrom(backgroundColor: backgroundColor),
        icon: Icon(
          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          color: isSaved ? AppColors.primary : AppColors.textSecondary,
        ),
      );
    });
  }
}
