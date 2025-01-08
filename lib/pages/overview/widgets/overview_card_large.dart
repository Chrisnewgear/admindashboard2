// import 'package:admindashboard/pages/overview/widgets/info_card.dart';
// import 'package:admindashboard/pages/roles/Widgets/role_color_util.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// //import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';


// class OverviewCardsLargeScreen extends StatelessWidget {
//   OverviewCardsLargeScreen({super.key, });

//   final List<String> roles = ['Admin', 'Supervisor', 'Vendedor', 'None'];

//   Future<Map<String, int?>> _fetchRoleCounts() async {
//     final usersCollection = FirebaseFirestore.instance.collection('Users');
//     Map<String, int?> roleCounts = {};

//     for (String role in roles) {
//       final countSnapshot =
//           await usersCollection.where('Role', isEqualTo: role).count().get();
//       roleCounts[role] = countSnapshot.count;
//     }

//     return roleCounts;
//   }


//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;

//     return FutureBuilder<Map<String, int?>>(
//       future: _fetchRoleCounts(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // Mostrar CircularProgressIndicator mientras se cargan los datos
//           return Row(
//             children: roles.map((role) {
//               return InfoCard(
//                 title: role,
//                 value: "",
//                 topColor: RoleColorUtil.getRoleColor(role),
//                 onTap: () {},
//                 isLoading: true, // Aquí indicamos que queremos mostrar el loading
//               );
//             }).toList(),
//           );
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Text("Error al cargar datos: ${snapshot.error}"),
//           );
//         }

//         final roleCounts = snapshot.data ?? {};

//         return Row(
//           children: roles.map((role) {
//             return InfoCard(
//               title: role,
//               value: "${roleCounts[role] ?? 0}",
//               topColor: RoleColorUtil.getRoleColor(role),
//               onTap: () {},
//             );
//           }).toList(),
//         );
//       },
//     );
//   }
// }

import 'package:admindashboard/pages/overview/widgets/info_card.dart';
import 'package:admindashboard/pages/roles/Widgets/role_color_util.dart';
import 'package:admindashboard/pages/overview/widgets/overview_shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OverviewCardsLargeScreen extends StatelessWidget {
  OverviewCardsLargeScreen({super.key});

  final List<String> roles = ['Admin', 'Supervisor', 'Vendedor', 'None'];

  Future<Map<String, int?>> _fetchRoleCounts() async {
    final usersCollection = FirebaseFirestore.instance.collection('Users');
    Map<String, int?> roleCounts = {};

    try {
      for (String role in roles) {
        final countSnapshot =
            await usersCollection.where('Role', isEqualTo: role).count().get();
        roleCounts[role] = countSnapshot.count;
      }
    } catch (e) {
      throw Exception('Error al obtener conteos de roles');
    }

    return roleCounts;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int?>>(
      future: _fetchRoleCounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const OverviewShimmer();
        }

        if (snapshot.hasError) {
          return Center(
            child: Text("Error al cargar datos: ${snapshot.error}"),
          );
        }

        final roleCounts = snapshot.data ?? {};

        return Row(
          children: roles.map((role) {
            return InfoCard(
              title: role,
              value: "${roleCounts[role] ?? 0}",
              topColor: RoleColorUtil.getRoleColor(role),
              onTap: () {},
            );
          }).toList(),
        );
      },
    );
  }
}