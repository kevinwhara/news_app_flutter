import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/utils/app_spacing.dart';
import 'package:news_app/utils/news_formatters.dart';
import 'package:news_app/widgets/bookmark_button.dart';
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(6),
              child: IconButton(
                tooltip: 'Back',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  foregroundColor: AppColors.textPrimary,
                ),
                onPressed: Get.back,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Share article',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                  foregroundColor: AppColors.textPrimary,
                ),
                onPressed: () => _shareArticle(currentArticle),
                icon: const Icon(Icons.ios_share_rounded),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: BookmarkButton(
                  article: currentArticle,
                  backgroundColor: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: NewsImage(
                  imageUrl: currentArticle.urlToImage,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28),
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
                    AppSpacing.xxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
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
                            ?.copyWith(fontSize: 27, height: 1.22),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 17,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.xs),
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
                            onPressed: () => _copyLink(currentArticle),
                            icon: const Icon(Icons.link_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
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
