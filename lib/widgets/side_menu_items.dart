
import 'package:flutter/material.dart';

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
    return ListTile(
      leading: icon,
      title: isExpanded ? Text(itemName) : null,
      onTap: onTap,
      minLeadingWidth: 0,
      dense: true,
    );
  }
}