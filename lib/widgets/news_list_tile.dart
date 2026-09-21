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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 350;
        final imageSize = isCompact ? 96.0 : 112.0;

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
                    width: imageSize,
                    height: imageSize,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  SizedBox(width: isCompact ? AppSpacing.sm : AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
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
                                dimension: 40,
                                child: BookmarkButton(article: article),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          article.title ?? 'Untitled story',
                          maxLines: isCompact ? 2 : 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          NewsFormatters.publishedTime(article.publishedAt),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
