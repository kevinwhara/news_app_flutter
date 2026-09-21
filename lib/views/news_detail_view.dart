import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/bookmark_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/utils/app_spacing.dart';
import 'package:news_app/utils/news_formatters.dart';
import 'package:news_app/widgets/news_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailView extends StatelessWidget {
  NewsDetailView({super.key});

  final NewsArticle? article = Get.arguments is NewsArticle
      ? Get.arguments as NewsArticle
      : null;

  @override
  Widget build(BuildContext context) {
    final currentArticle = article;
    if (currentArticle == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Article is no longer available.')),
      );
    }

    final source = currentArticle.source?.name?.trim();
    final content = _cleanContent(currentArticle.content);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            toolbarHeight: 68,
            backgroundColor: AppColors.surface,
            surfaceTintColor: AppColors.surface,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: IconButton(
                tooltip: 'Back',
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.redLight,
                  foregroundColor: AppColors.textPrimary,
                ),
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            title: Text(
              'Article',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: IconButton(
                  tooltip: 'Share article',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.redLight,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: () => _shareArticle(currentArticle),
                  icon: const Icon(Icons.ios_share_rounded),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.divider),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 24,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9.5,
                      child: NewsImage(
                        imageUrl: currentArticle.urlToImage,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxWidth: 280),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.redLight,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.pillRadius,
                          ),
                        ),
                        child: Text(
                          source == null || source.isEmpty
                              ? 'TOP STORY'
                              : source.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 0.6,
                              ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        currentArticle.title ?? 'Untitled story',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontSize: 27, height: 1.25),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: const BoxDecoration(
                              color: AppColors.redLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.schedule_rounded,
                              size: 17,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              NewsFormatters.publishedTime(
                                currentArticle.publishedAt,
                              ),
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Copy link',
                            style: IconButton.styleFrom(
                              backgroundColor: AppColors.redLight,
                              foregroundColor: AppColors.primary,
                            ),
                            onPressed: () => _copyLink(currentArticle),
                            icon: const Icon(Icons.link_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _ArticleActions(
                        article: currentArticle,
                        onShare: () => _shareArticle(currentArticle),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      const Divider(),
                      const SizedBox(height: AppSpacing.xl),
                      if (currentArticle.description?.trim().isNotEmpty ??
                          false) ...[
                        Text(
                          currentArticle.description!.trim(),
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                height: 1.55,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                      if (content.isNotEmpty)
                        Text(
                          content,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      if (currentArticle.url?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openInBrowser(currentArticle),
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: const Text('Read Full Article'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _cleanContent(String? value) {
    return value?.replaceFirst(RegExp(r'\s*\[\+\d+ chars\]\s*$'), '').trim() ??
        '';
  }

  Future<void> _shareArticle(NewsArticle currentArticle) async {
    final url = currentArticle.url?.trim();
    if (url == null || url.isEmpty) return;

    await SharePlus.instance.share(
      ShareParams(
        text: '${currentArticle.title ?? 'Check out this story'}\n\n$url',
        subject: currentArticle.title,
      ),
    );
  }

  Future<void> _copyLink(NewsArticle currentArticle) async {
    final url = currentArticle.url?.trim();
    if (url == null || url.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: url));
    Get.snackbar(
      'Link copied',
      'The article link is ready to share.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(AppSpacing.lg),
    );
  }

  Future<void> _openInBrowser(NewsArticle currentArticle) async {
    final value = currentArticle.url?.trim();
    final uri = value == null ? null : Uri.tryParse(value);

    try {
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    } catch (_) {
      // The user receives the same friendly error for platform launch failures.
    }

    Get.snackbar(
      'Unable to open article',
      'Please try again in a moment.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(AppSpacing.lg),
    );
  }
}

class _ArticleActions extends GetView<BookmarkController> {
  const _ArticleActions({required this.article, required this.onShare});

  final NewsArticle article;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSaved = controller.isBookmarked(article);
      final useVerticalLayout =
          MediaQuery.sizeOf(context).width < 380 ||
          MediaQuery.textScalerOf(context).scale(1) > 1.25;

      final saveButton = OutlinedButton.icon(
        onPressed: () => controller.toggle(article),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: AppColors.primary,
          backgroundColor: isSaved ? AppColors.redLight : AppColors.surface,
          side: const BorderSide(color: AppColors.redSoft),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
        icon: Icon(
          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        ),
        label: Text(isSaved ? 'Article Saved' : 'Save Article'),
      );

      final shareButton = OutlinedButton.icon(
        onPressed: onShare,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
        icon: const Icon(Icons.ios_share_rounded),
        label: const Text('Share'),
      );

      if (useVerticalLayout) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            saveButton,
            const SizedBox(height: AppSpacing.sm),
            shareButton,
          ],
        );
      }

      return Row(
        children: [
          Expanded(child: saveButton),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: shareButton),
        ],
      );
    });
  }
}
