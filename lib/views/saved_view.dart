import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/bookmark_controller.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/app_spacing.dart';
import 'package:news_app/widgets/news_list_tile.dart';
import 'package:news_app/widgets/news_state_view.dart';

class SavedView extends GetView<BookmarkController> {
  const SavedView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Obx(() {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            124,
          ),
          children: [
            Text(
              'Saved articles',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${controller.savedArticles.length} saved ${controller.savedArticles.length == 1 ? 'article' : 'articles'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            if (controller.savedArticles.isEmpty)
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.58,
                child: const NewsStateView(
                  icon: Icons.bookmark_border_rounded,
                  title: 'No saved articles',
                  message:
                      'Save interesting stories and come back to read them later.',
                ),
              )
            else
              ...controller.savedArticles.map(
                (article) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: NewsListTile(
                    article: article,
                    onTap: () =>
                        Get.toNamed(Routes.NEWS_DETAIL, arguments: article),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
