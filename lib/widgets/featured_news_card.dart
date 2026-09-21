import 'package:flutter/material.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/utils/app_spacing.dart';
import 'package:news_app/utils/news_formatters.dart';
import 'package:news_app/widgets/news_image.dart';

class FeaturedNewsCard extends StatelessWidget {
  const FeaturedNewsCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  final NewsArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final source = article.source?.name?.trim();
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardHeight = (280 + ((textScale - 1) * 72))
        .clamp(280, 360)
        .toDouble();

    return Semantics(
      button: true,
      label: article.title ?? 'Featured news article',
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: cardHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NewsImage(imageUrl: article.urlToImage),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0x29000000),
                        Color(0xE6000000),
                      ],
                      stops: [0.2, 0.5, 1],
                    ),
                  ),
                ),
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.pillRadius,
                          ),
                        ),
                        child: const Text(
                          'BREAKING',
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        article.title ?? 'Untitled story',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${source == null || source.isEmpty ? 'News' : source}  •  ${NewsFormatters.publishedTime(article.publishedAt)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
