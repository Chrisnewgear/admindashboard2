import 'package:admindashboard/helpers/responsiveness.dart';
import 'package:admindashboard/widgets/large_screen.dart';
import 'package:admindashboard/widgets/side_menu.dart';
import 'package:admindashboard/widgets/small_screen.dart';
import 'package:admindashboard/widgets/top_nav.dart';
import 'package:flutter/material.dart';

// class SiteLayout extends StatelessWidget {
//   final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
//   SiteLayout({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       extendBodyBehindAppBar: false,
//       appBar: topNavigationBar(context, scaffoldKey),
//       drawer: const Drawer(
//         child: SideMenu(),
//       ),
//       body: const ResponsiveWidget(
//           largeScreen: LargeScreen(),
//           smallScreen: SmallScreen()),
//     );
//   }
// }


class SiteLayout extends StatefulWidget {
  const SiteLayout({super.key});

  @override
  State<SiteLayout> createState() => _SiteLayoutState();
}

class _SiteLayoutState extends State<SiteLayout> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  bool isExpanded = true;

  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: false,
      appBar: topNavigationBar(context, scaffoldKey),
      drawer: Drawer(
        child: SideMenu(
          isExpanded: isExpanded,
          toggleExpanded: toggleExpanded,
        ),
      ),
      body: ResponsiveWidge
        largeScreen: LargeScreen(
          isExpanded: isExpanded,
          toggleExpanded: toggleExpanded,
        ),
        smallScreen: const SmallScreen(),
      ),
    );
  }
}