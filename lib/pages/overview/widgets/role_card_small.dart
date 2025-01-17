import 'package:admindashboard/pages/overview/widgets/info_card_small.dart';
import 'package:admindashboard/Shimmers/role_card_shimmer_small.dart';
import 'package:admindashboard/pages/roles/Widgets/role_color_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OverViewCardSmallScreen extends StatefulWidget {
  const OverViewCardSmallScreen({super.key});

  @override
  State<OverViewCardSmallScreen> createState() => _OverViewCardSmallScreenState();
}

class _OverViewCardSmallScreenState extends State<OverViewCardSmallScreen> {
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
          .get(const GetOptions(source: Source.server)); // Force server request

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
          return const SmallShimmer();
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

        return Column(
          children: [
            for (int i = 0; i < roles.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
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