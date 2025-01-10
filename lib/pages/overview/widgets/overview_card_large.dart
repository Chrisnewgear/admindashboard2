import 'package:admindashboard/pages/overview/widgets/info_card.dart';
import 'package:admindashboard/pages/roles/Widgets/role_color_util.dart';
import 'package:admindashboard/pages/overview/widgets/overview_shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OverviewCardsLargeScreen extends StatefulWidget {
  const OverviewCardsLargeScreen({super.key});

  @override
  State<OverviewCardsLargeScreen> createState() => _OverviewCardsLargeScreenState();
}

class _OverviewCardsLargeScreenState extends State<OverviewCardsLargeScreen> {
  final List<String> roles = const ['Admin', 'Supervisor', 'Vendedor', 'None'];
  late final Future<Map<String, int?>> _roleCountsFuture;

  @override
  void initState() {
    super.initState();
    _roleCountsFuture = _fetchRoleCounts();
  }

  Future<Map<String, int?>> _fetchRoleCounts() async {
    final usersCollection = FirebaseFirestore.instance.collection('Users');
    Map<String, int?> roleCounts = {for (var role in roles) role: 0};

    try {
      final querySnapshot = await usersCollection
          .get(const GetOptions(source: Source.server));

      if (!mounted) return roleCounts;

      for (var doc in querySnapshot.docs) {
        String role = doc.data()['Role'] as String? ?? 'None';
        if (roleCounts.containsKey(role)) {
          roleCounts[role] = (roleCounts[role] ?? 0) + 1;
        }
      }
    } catch (e) {
      debugPrint('Error fetching role counts: $e');
      throw Exception("Error al obtener conteos de roles: ${e.toString()}");
    }

    return roleCounts;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int?>>(
      future: _roleCountsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const OverviewShimmer();
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  "Error al cargar datos: ${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final roleCounts = snapshot.data ?? {};

        return Row(
          children: roles.map((role) {
            return Expanded(
              child: InfoCard(
                title: role,
                value: "${roleCounts[role] ?? 0}",
                topColor: RoleColorUtil.getRoleColor(role),
                onTap: () {},
              ),
            );
          }).toList(),
        );
      },
    );
  }
}