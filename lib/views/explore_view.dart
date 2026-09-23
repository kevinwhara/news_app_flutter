import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/news_search_controller.dart';
import 'package:news_app/routes/app_pages.dart';
import 'package:news_app/utils/app_colors.dart';
import 'package:news_app/utils/app_spacing.dart';
import 'package:news_app/widgets/news_list_tile.dart';
import 'package:news_app/widgets/news_state_view.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  static const _topics = [
    'Technology',
    'Business',
    'Sports',
    'Entertainment',
    'Health',
    'Science',
  ];

  final _textController = TextEditingController();
  late final NewsSearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<NewsSearchController>();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            124,
          ),
          children: [
            Text('Explore', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Search stories and discover what matters to you.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _textController,
              textInputAction: TextInputAction.search,
              onChanged: _controller.updateQuery,
              onSubmitted: _controller.updateQuery,
              decoration: InputDecoration(
                hintText: 'Search news...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: Obx(
                  () => _controller.query.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: 'Clear search',
                          onPressed: () {
                            _textController.clear();
                            _controller.updateQuery('');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Discover topics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _topics.map((topic) {
                return ActionChip(
                  avatar: const Icon(
                    Icons.tag_rounded,
                    size: 17,
                    color: AppColors.textSecondary,
                  ),
                  label: Text(topic),
                  onPressed: () {
                    _textController.text = topic;
                    _textController.selection = TextSelection.collapsed(
                      offset: topic.length,
                    );
                    _controller.updateQuery(topic);
                    FocusScope.of(context).unfocus();
                  },
                  backgroundColor: AppColors.surface,
                  side: const BorderSide(color: AppColors.divider),
                  shape: const StadiumBorder(),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Obx(() => _buildResults(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    switch (_controller.status.value) {
      case SearchStatus.idle:
        return const NewsStateView(
          icon: Icons.travel_explore_rounded,
          title: 'Find your next story',
          message: 'Search by keyword or choose a topic above.',
        );
      case SearchStatus.loading:
        return const NewsLoadingState(itemCount: 4);
      case SearchStatus.empty:
        return const NewsStateView(
          icon: Icons.search_off_rounded,
          title: 'No news found',
          message: 'Try another keyword or a broader topic.',
        );
      case SearchStatus.error:
        return NewsStateView(
          icon: Icons.cloud_off_rounded,
          title: 'Search unavailable',
          message: _controller.errorMessage.value,
          actionLabel: 'Try Again',
          onAction: _controller.retry,
        );
      case SearchStatus.success:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Search results',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Text(
                  '${_controller.articles.length} stories',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ..._controller.articles.map(
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
    }
  }
}
