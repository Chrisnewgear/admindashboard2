import 'package:admindashboard/pages/roles/Widgets/role_color_util.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:flutter/material.dart';

class InfoCardSmall extends StatelessWidget {
  final String title;
  final String value;
  final Color? topColor;
  final bool isActive;
  final Function() onTap;
  final bool isLoading;

  const InfoCardSmall({
    super.key,
    required this.title,
    required this.value,
    this.isActive = false,
    required this.onTap,
    this.topColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color roleColor = RoleColorUtil.getRoleColor(title.toLowerCase());

    String displayTitle;
    switch (title) {
      case 'Admin':
        displayTitle = 'Administradores';
        break;
      case 'Supervisor':
        displayTitle = 'Supervisores';
        break;
      case 'Vendedor':
        displayTitle = 'Vendedores';
        break;
      case 'None':
      default:
        displayTitle = 'Vendedores sin Asignar';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 1),
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: roleColor.withOpacity(0.4),
                spreadRadius: 1,
                blurRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: displayTitle,
                      size: 16,
                      weight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                    const SizedBox(height: 1),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                width: 40,
                alignment: Alignment.center,
                child: CustomText(
                  text: value,
                  size: 16,
                  weight: FontWeight.w600,
                  color: Colors.grey[700]!,
                ),
              ),
              const SizedBox(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}
