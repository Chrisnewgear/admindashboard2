import 'package:admindashboard/helpers/local_navigator.dart';
import 'package:admindashboard/widgets/side_menu.dart';
import 'package:flutter/material.dart';

class LargeScreen extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback toggleExpanded;

  //Constructor
  const LargeScreen({ super.key, required this.isExpanded, required this.toggleExpanded});

  @override
  Widget build(BuildContext context) {
    // Set the width based on isExpanded
    double sideMenuWidth = isExpanded ? 150 : 70;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: sideMenuWidth,
          child: SideMenu(
            isExpanded: isExpanded,
            toggleExpanded: toggleExpanded,
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: localNavigator(),
          ),
        ),
      ],
    );
  }
}
