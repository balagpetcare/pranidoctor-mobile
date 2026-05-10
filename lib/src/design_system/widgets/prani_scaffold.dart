import 'package:flutter/material.dart';

import 'prani_app_header.dart';

/// Opinionated [Scaffold] with consistent app header and optional safe padding.
class PraniScaffold extends StatelessWidget {
  const PraniScaffold({
    super.key,
    this.title,
    this.subtitle,
    this.showBackButton = true,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.safeArea = true,
    this.padding,
    this.backgroundColor,
    this.appBarActions,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset,
  });

  final String? title;
  final String? subtitle;
  final bool showBackButton;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final List<Widget>? appBarActions;
  final bool extendBodyBehindAppBar;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    PreferredSizeWidget? appBar;
    if (title != null) {
      appBar = AppBar(
        automaticallyImplyLeading: showBackButton,
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: appBarActions,
        title: PraniAppHeader(title: title!, subtitle: subtitle),
      );
    }

    Widget content = body;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    if (safeArea) {
      content = appBar != null
          ? SafeArea(
              top: false,
              bottom: true,
              left: true,
              right: true,
              child: content,
            )
          : SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      appBar: appBar,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: content,
    );
  }
}
