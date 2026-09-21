import 'package:flutter/material.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/utils/app_spacing.dart';
import 'package:news_app/utils/news_formatters.dart';
import 'package:news_app/widgets/bookmark_button.dart';
import 'package:news_app/widgets/news_image.dart';

class NewsListTile extends StatelessWidget {
  const NewsListTile({
    super.key,
    required this.article,
    required this.onTap,
    this.showBookmark = true,
  });

  final NewsArticle article;
  final VoidCallback onTap;
  final bool showBookmark;

  @override
  Widget build(BuildContext context) {
    final source = article.source?.name?.trim();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NewsImage(
                imageUrl: article.urlToImage,
                width: 116,
                height: 112,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SizedBox(
                  height: 112,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              source == null || source.isEmpty
                                  ? 'Top story'
                                  : source,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: AppColors.primary),
                            ),
                          ),
                          if (showBookmark)
                            SizedBox.square(
                              dimension: 32,
                              child: FittedBox(
                                child: BookmarkButton(article: article),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          article.title ?? 'Untitled story',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontSize: 15),
                        ),
                      ),
                      Text(
                        NewsFormatters.publishedTime(article.publishedAt),
                        maxLines: 1,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
