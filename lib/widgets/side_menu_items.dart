import 'package:flutter/material.dart';
import 'package:admindashboard/constants/controllers.dart';
import 'package:admindashboard/constants/style.dart';

class SideMenuItem extends StatelessWidget {
  final String itemName;
  final Widget icon;
  final bool isExpanded;
  final VoidCallback onTap;

  const SideMenuItem({
    required this.itemName,
    required this.icon,
    required this.isExpanded,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = menuController.isActive(itemName);
    final bool isHovering = menuController.isHovering(itemName);

    Color backgroundColor;
    if (isActive) {
      backgroundColor = active.withOpacity(0.18);
    } else if (isHovering) {
      backgroundColor = lightGrey.withOpacity(0.18);
    } else {
      backgroundColor = Colors.transparent;
    }

    return MouseRegion(
      onEnter: (_) => menuController.onHover(itemName),
      onExit: (_) => menuController.onHover(''),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: icon,
          title: isExpanded ? Text(itemName) : null,
          onTap: onTap,
          minLeadingWidth: 0,
          dense: true,
        ),
      ),
    );
  }
}