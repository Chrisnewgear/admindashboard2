import 'package:admindashboard/pages/overview/widgets/info_card_small.dart';
import 'package:admindashboard/pages/roles/Widgets/role_color_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OverViewCardSmallScreen extends StatelessWidget {
  OverViewCardSmallScreen({super.key});

  final List<String> roles = ['Admin', 'Supervisor', 'Vendedor', 'None'];
  late final Future<Map<String, int?>> _roleCountsFuture = _fetchRoleCounts();

  Future<Map<String, int?>> _fetchRoleCounts() async {
    final usersCollection = FirebaseFirestore.instance.collection('Users');
    Map<String, int?> roleCounts = {for (var role in roles) role: 0};

    try {
      final querySnapshot = await usersCollection.get();
      for (var doc in querySnapshot.docs) {
        String role = doc['Role'] ?? 'None';
        if (roleCounts.containsKey(role)) {
          roleCounts[role] = (roleCounts[role] ?? 0) + 1;
        }
      }
    } catch (e) {
      // Manejo de errores
      throw Exception("Error al obtener conteos de roles");
    }

    return roleCounts;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return FutureBuilder<Map<String, int?>>(
      future: _roleCountsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostrar CircularProgressIndicator mientras se cargan los datos
          return Column(
            children: [
              for (int i = 0; i < roles.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: InfoCardSmall(
                    title: roles[i],
                    value: "",
                    topColor: RoleColorUtil.getRoleColor(roles[i]),
                    onTap: () {},
                    isLoading: true,
                  ),
                ),
            ],
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text("Error al cargar datos: ${snapshot.error}"),
          );
        }

        final roleCounts = snapshot.data ?? {};

        return Column(
          children: [
            for (int i = 0; i < roles.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: InfoCardSmall(
                  title: roles[i],
                  value: "${roleCounts[roles[i]] ?? 0}",
                  topColor: RoleColorUtil.getRoleColor(roles[i]),
                  onTap: () {},
                ),
              ),
          ],
        );
      },
    );
  }
}