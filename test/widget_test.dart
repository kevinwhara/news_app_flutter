// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:news_app/controllers/bookmark_controller.dart';
import 'package:news_app/models/news_article.dart';
import 'package:news_app/utils/app_theme.dart';
import 'package:news_app/widgets/category_chip.dart';
import 'package:news_app/widgets/featured_news_card.dart';
import 'package:news_app/widgets/floating_navbar.dart';
import 'package:news_app/widgets/news_list_tile.dart';
import 'package:news_app/widgets/saved_article_card.dart';

void main() {
  testWidgets('category chip renders and reports taps', (tester) async {
    var wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryChip(
            label: 'Technology',
            isSelected: false,
            onTap: () => wasTapped = true,
          ),
        ),
      ),
    );

    expect(find.text('Technology'), findsOneWidget);

    await tester.tap(find.text('Technology'));
    await tester.pump();

    expect(wasTapped, isTrue);
  });

  test('bookmark controller toggles an article', () {
    final controller = BookmarkController();
    final article = NewsArticle(
      title: 'A test story',
      url: 'https://example.com/story',
    );

    controller.toggle(article);
    expect(controller.isBookmarked(article), isTrue);
    expect(controller.savedArticles, hasLength(1));

    controller.toggle(article);
    expect(controller.isBookmarked(article), isFalse);
    expect(controller.savedArticles, isEmpty);
  });

  testWidgets('news cards fit a compact screen with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Get.put<BookmarkController>(BookmarkController());
    addTearDown(Get.reset);

    final article = NewsArticle(
      title:
          'A very long breaking news headline remains readable on small phones',
      source: Source(name: 'A Very Long International News Source Name'),
      publishedAt: '2026-09-21T08:00:00Z',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: Scaffold(
            body: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FeaturedNewsCard(article: article, onTap: () {}),
                const SizedBox(height: 16),
                NewsListTile(article: article, onTap: () {}),
                const SizedBox(height: 16),
                SavedArticleCard(article: article, onTap: () {}),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('floating navigation fits narrow screens', (tester) async {
    tester.view.physicalSize = const Size(280, 560);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
          child: Scaffold(
            bottomNavigationBar: FloatingNavbar(
              currentIndex: 0,
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
