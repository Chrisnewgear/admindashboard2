import 'package:admindashboard/helpers/responsiveness.dart';
import 'package:admindashboard/widgets/large_screen.dart';
import 'package:admindashboard/widgets/side_menu.dart';
import 'package:admindashboard/widgets/small_screen.dart';
import 'package:admindashboard/widgets/top_nav.dart';
import 'package:flutter/material.dart';

class SiteLayout extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  SiteLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: topNavigationBar(context, scaffoldKey),
      drawer: const Drawer(
        child: SideMenu(),
      ),
      body: const ResponsiveWidget(
          largeScreen: LargeScreen(),
          smallScreen: SmallScreen()),
    );
  }
}
