import 'package:admindashboard/pages/roles/Widgets/role_color_util.dart';
import 'package:flutter/material.dart';


class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color? topColor;
  final bool isActive;
  final Function() onTap;
  final bool isLoading; // New parameter for loading state

  const InfoCard({
    super.key,
    required this.title,
    required this.value,
    this.isActive = false,
    required this.onTap,
    this.topColor,
    this.isLoading = false, // Default value is false
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



    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 150,
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: roleColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: roleColor.withOpacity(0.4),
                blurRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: roleColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              isLoading
                  ? CircularProgressIndicator(
                      color: roleColor,
                    )
                  : RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "$displayTitle\n",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: roleColor,
                            ),
                          ),
                          TextSpan(
                            text: value,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}