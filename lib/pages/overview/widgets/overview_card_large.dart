// import 'package:admindashboard/pages/overview/widgets/info_card.dart';
// import 'package:flutter/material.dart';

// class OverviewCardsLargeScreen extends StatelessWidget {
//   const OverviewCardsLargeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;

//     return Row(
//       children: [
//         InfoCard(
//           title: "Rides in progress",
//           value: "7",
//           onTap: () {},
//           topColor: Colors.orange,
//         ),
//         SizedBox(
//           width: width / 64,
//         ),
//         InfoCard(
//           title: "Packages delivered",
//           value: "17",
//           topColor: Colors.lightGreen,
//           onTap: () {},
//         ),
//         SizedBox(
//           width: width / 64,
//         ),
//         InfoCard(
//           title: "Cancelled delivery",
//           value: "3",
//           topColor: Colors.redAccent,
//           onTap: () {},
//         ),
//         SizedBox(
//           width: width / 64,
//         ),
//         InfoCard(
//           title: "Scheduled deliveries",
//           value: "32",
//           onTap: () {},
//         ),
//       ],
//     );
//   }
// }

// import 'package:admindashboard/pages/overview/widgets/info_card.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class OverviewCardsLargeScreen extends StatelessWidget {
//   const OverviewCardsLargeScreen({super.key});

//   // Método optimizado usando Firestore count()
//   Future<Map<String, int?>> _fetchRoleCounts() async {
//     final usersCollection = FirebaseFirestore.instance.collection('Users');

//     // Consultas específicas para cada rol con count()
//     final adminCountFuture = usersCollection.where('Role', isEqualTo: 'Admin').count().get();
//     final supervisorCountFuture = usersCollection.where('Role', isEqualTo: 'Supervisor').count().get();
//     final sellerCountFuture = usersCollection.where('Role', isEqualTo: 'Vendedor').count().get();

//     // Ejecutamos las consultas en paralelo
//     final results = await Future.wait([adminCountFuture, supervisorCountFuture, sellerCountFuture]);

//     // Devolvemos un mapa con los resultados
//     return {
//       'Admin': results[0].count,
//       'Supervisor': results[1].count,
//       'Vendedor': results[2].count,
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;

//     return FutureBuilder<Map<String, int?>>(
//       future: _fetchRoleCounts(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Text("Error al cargar datos: ${snapshot.error}"),
//           );
//         }

//         final roleCounts = snapshot.data ?? {};

//         return Row(
//           children: [
//             InfoCard(
//               title: "Admins",
//               value: "${roleCounts['Admin'] ?? 0}",
//               topColor: Colors.blue,
//               onTap: () {},
//             ),
//             SizedBox(
//               width: width / 64,
//             ),
//             InfoCard(
//               title: "Supervisores",
//               value: "${roleCounts['Supervisor'] ?? 0}",
//               topColor: Colors.green,
//               onTap: () {},
//             ),
//             SizedBox(
//               width: width / 64,
//             ),
//             InfoCard(
//               title: "Vendedores",
//               value: "${roleCounts['Vendedor'] ?? 0}",
//               topColor: Colors.orange,
//               onTap: () {},
//             ),
//           ],
//         );
//       },
//     );
//   }
// }

import 'package:admindashboard/pages/overview/widgets/info_card.dart';
import 'package:admindashboard/pages/roles/Widgets/role_color_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class OverviewCardsLargeScreen extends StatelessWidget {
  OverviewCardsLargeScreen({super.key});

  final List<String> roles = ['Admin', 'Supervisor', 'Vendedor', 'None'];

  Future<Map<String, int?>> _fetchRoleCounts() async {
    final usersCollection = FirebaseFirestore.instance.collection('Users');
    Map<String, int?> roleCounts = {};

    for (String role in roles) {
      final countSnapshot =
          await usersCollection.where('Role', isEqualTo: role).count().get();
      roleCounts[role] = countSnapshot.count;
    }

    return roleCounts;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return FutureBuilder<Map<String, int?>>(
      future: _fetchRoleCounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mostrar CircularProgressIndicator mientras se cargan los datos
          return Row(
            children: roles.map((role) {
              return InfoCard(
                title: role,
                value: "",
                topColor: RoleColorUtil.getRoleColor(role),
                onTap: () {},
                isLoading: true, // Aquí indicamos que queremos mostrar el loading
              );
            }).toList(),
          );
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