import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:news_app/controllers/navigation_controller.dart';
import 'package:news_app/views/explore_view.dart';
import 'package:news_app/views/home_view.dart';
import 'package:news_app/views/saved_view.dart';
import 'package:news_app/widgets/floating_navbar.dart';

class MainShellView extends GetView<NavigationController> {
  const MainShellView({super.key});

  static const _pages = [HomeView(), ExploreView(), SavedView()];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: _pages,
        ),
        bottomNavigationBar: FloatingNavbar(
          currentIndex: controller.currentIndex.value,
          onChanged: controller.changePage,
        ),
      ),
    );
  }
}
