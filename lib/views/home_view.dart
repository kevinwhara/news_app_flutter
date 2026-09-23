import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/navigation_controller.dart';
import 'package:news_app/controllers/news_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/utils/app_spacing.dart';
import 'package:news_app/widgets/category_chip.dart';
import 'package:news_app/widgets/featured_news_card.dart';
import 'package:news_app/widgets/news_list_tile.dart';
import 'package:news_app/widgets/news_state_view.dart';

class HomeView extends GetView<NewsController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.refreshNews,
        child: Obx(
          () => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              124,
            ),
            children: [
              _HomeHeader(
                onSearch: () => Get.find<NavigationController>().changePage(1),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (controller.isLoading && controller.articles.isEmpty)
                const NewsLoadingState()
              else if (controller.error.isNotEmpty &&
                  controller.articles.isEmpty)
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.58,
                  child: NewsStateView(
                    icon: Icons.cloud_off_rounded,
                    title: 'Something went wrong',
                    message: 'Unable to load the latest news.',
                    actionLabel: 'Try Again',
                    onAction: controller.refreshNews,
                  ),
                )
              else if (controller.articles.isEmpty)
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.58,
                  child: const NewsStateView(
                    icon: Icons.article_outlined,
                    title: 'No news available',
                    message: 'Try another category or refresh the feed.',
                  ),
                )
              else ...[
                const _SectionHeader(
                  title: 'Top stories',
                  caption: 'Swipe to explore',
                ),
                const SizedBox(height: AppSpacing.md),
                _TopStoriesCarousel(
                  articles: controller.articles.take(5).toList(),
                  onArticleTap: _openArticle,
                ),
                const SizedBox(height: AppSpacing.xl),
                _SectionHeader(
                  title: 'Discover topics',
                  caption: controller.selectedCategory.capitalizeFirst ?? '',
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.categories.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final category = controller.categories[index];
                      return CategoryChip(
                        label: category == 'general'
                            ? 'For You'
                            : category.capitalizeFirst ?? category,
                        isSelected: controller.selectedCategory == category,
                        onTap: () => controller.selectCategory(category),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _SectionHeader(
                  title: 'Latest news',
                  caption: '${controller.articles.length} stories',
                ),
                const SizedBox(height: AppSpacing.md),
                ...controller.articles
                    .skip(
                      controller.articles.length < 5
                          ? controller.articles.length
                          : 5,
                    )
                    .map(
                      (article) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: NewsListTile(
                          article: article,
                          onTap: () => _openArticle(article),
                        ),
                      ),
                    ),
                _LoadMoreSection(controller: controller),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openArticle(NewsArticle article) {
    Get.toNamed(Routes.NEWS_DETAIL, arguments: article);
  }
}

class _TopStoriesCarousel extends StatelessWidget {
  const _TopStoriesCarousel({
    required this.articles,
    required this.onArticleTap,
  });

  final List<NewsArticle> articles;
  final ValueChanged<NewsArticle> onArticleTap;

  @override
  Widget build(BuildContext context) {
    final availableWidth =
        MediaQuery.sizeOf(context).width - (AppSpacing.lg * 2);
    final cardWidth = (availableWidth * 0.9).clamp(250, 380).toDouble();

    return SizedBox(
      height: FeaturedNewsCard.preferredHeight(context),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: articles.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final article = articles[index];
          return SizedBox(
            width: cardWidth,
            child: FeaturedNewsCard(
              article: article,
              onTap: () => onArticleTap(article),
            ),
          );
        },
      ),
    );
  }
}

class _LoadMoreSection extends StatelessWidget {
  const _LoadMoreSection({required this.controller});

  final NewsController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Center(
          child: SizedBox.square(
            dimension: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    if (controller.hasMore) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: OutlinedButton.icon(
          onPressed: controller.loadMoreNews,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            foregroundColor: AppColors.textPrimary,
            backgroundColor: AppColors.surface,
            side: const BorderSide(color: AppColors.divider),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
            ),
          ),
          icon: Icon(
            controller.loadMoreError.isEmpty
                ? Icons.add_rounded
                : Icons.refresh_rounded,
          ),
          label: Text(
            controller.loadMoreError.isEmpty
                ? 'Load more stories'
                : 'Try loading again',
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            "You're all caught up",
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your daily briefing',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                "Discover today's\ntop stories",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          tooltip: 'Search news',
          onPressed: onSearch,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceMuted,
            foregroundColor: AppColors.textPrimary,
          ),
          icon: const Icon(Icons.search_rounded),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.caption});

  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Flexible(
          child: Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ),
      ],
    );
  }
}
