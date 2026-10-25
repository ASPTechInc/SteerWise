/// ------------------------------------------------------------------------
/// SteerWise - Smart Driving Practice App
/// https://github.com/ASPTechInc/SteerWise
///
/// Copyright © 2026 ASPTechnologies Incorporation. All Rights Reserved.
/// Licensed under the MIT License (see LICENSE).
/// ------------------------------------------------------------------------
library;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

// Project imports:
import 'package:steer_wise/src/config/colours.dart';
import 'package:steer_wise/src/screens/home_screen.dart';
import 'package:steer_wise/src/screens/settings_screen.dart';
import 'package:steer_wise/src/screens/show_me_tell_screen.dart';

/// Bottom navigation between the Home, Show Me/Tell Me and Settings tabs.
class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  // Kept in State so rebuilds (for example a theme change) keep the
  // selected tab.
  final PersistentTabController _controller = PersistentTabController();

  late final List<PersistentTabConfig> _tabs = [
    PersistentTabConfig(
      screen: _TabVisibility(
        controller: _controller,
        index: 0,
        child: const HomeScreen(),
      ),
      item: ItemConfig(icon: const Icon(Icons.car_rental), title: 'Home'),
    ),
    PersistentTabConfig(
      screen: _TabVisibility(
        controller: _controller,
        index: 1,
        child: const ShowMeTellMeScreen(),
      ),
      item: ItemConfig(
        icon: const Icon(Icons.question_answer),
        title: 'Show Me/Tell Me',
      ),
    ),
    PersistentTabConfig(
      screen: _TabVisibility(
        controller: _controller,
        index: 2,
        child: const SettingsScreen(),
      ),
      item: ItemConfig(icon: const Icon(Icons.settings), title: 'Settings'),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      controller: _controller,
      tabs: _tabs,
      navBarBuilder: (navBarConfig) => Style4BottomNavBar(
        navBarConfig: navBarConfig,
        // The package defaults to a white bar, even in dark mode.
        navBarDecoration: NavBarDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColours.tertiaryDark
              : Colors.white,
        ),
      ),
    );
  }
}

/// Pauses a tab while another tab is selected.
///
/// PersistentTabView keeps every tab alive, so without this the Home tab's
/// camera and driving simulation would keep running out of sight.
/// [TickerMode] mutes animations and tickers below it, and the camera
/// preview watches it to release the camera.
class _TabVisibility extends StatelessWidget {
  const _TabVisibility({
    required this.controller,
    required this.index,
    required this.child,
  });

  final PersistentTabController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, child) =>
          TickerMode(enabled: controller.index == index, child: child!),
      child: child,
    );
  }
}
