// import 'package:admindashboard/pages/overview/widgets/info_card.dart';
// import 'package:flutter/material.dart';

// class OverviewCardMediumScreen extends StatelessWidget {
//   const OverviewCardMediumScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Row(
//           children: [
//             InfoCard(
//               title: "Rides in progress",
//               value: "7",
//               onTap: () {},
//               topColor: Colors.orange,
//             ),
//             SizedBox(
//               width: width / 64,
//             ),
//             InfoCard(
//               title: "Packages delivered",
//               value: "17",
//               topColor: Colors.lightGreen,
//               onTap: () {},
//             ),
//           ],
//         ),
//         SizedBox(
//           height: width / 64,
//         ),
//         Row(
//           children: [
//             InfoCard(
//               title: "Cancelled delivery",
//               value: "3",
//               topColor: Colors.redAccent,
//               onTap: () {},
//             ),
//             SizedBox(
//               width: width / 64,
//             ),
//             InfoCard(
//               title: "Scheduled deliveries",
//               value: "32",
//               onTap: () {},
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }


// // import 'package:admindashboard/pages/overview/widgets/info_card.dart';
// // import 'package:admindashboard/pages/roles/Widgets/role_color_util.dart';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:flutter/material.dart';


// // class OverviewCardMediumScreen extends StatelessWidget {
// //   OverviewCardMediumScreen({super.key});

// //   final List<String> roles = ['Admin', 'Supervisor', 'Vendedor', 'None'];

// //   Future<Map<String, int?>> _fetchRoleCounts() async {
// //     final usersCollection = FirebaseFirestore.instance.collection('Users');
// //     Map<String, int?> roleCounts = {};

// //     for (String role in roles) {
// //       final countSnapshot =
// //           await usersCollection.where('Role', isEqualTo: role).count().get();
// //       roleCounts[role] = countSnapshot.count;
// //     }

// //     return roleCounts;
// //   }


// //   @override
// //   Widget build(BuildContext context) {
// //     double width = MediaQuery.of(context).size.width;



// //     return FutureBuilder<Map<String, int?>>(
// //       future: _fetchRoleCounts(),
// //       builder: (context, snapshot) {
// //         if(snapshot.connectionState == ConnectionState.waiting){
// //           return Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Row(
// //                 children: roles.map((role) {
// //                   return InfoCard(
// //                     title: role,
// //                     value: "",
// //                     topColor: RoleColorUtil.getRoleColor(role),
// //                     onTap: () {},
// //                     isLoading: true,
// //                   );
// //                 }).toList(),
// //               ),
// //             ],
// //           );
// //         }
// //       }
// //     );

// //     // return Column(
// //     //   mainAxisSize: MainAxisSize.min,
// //     //   children: [
// //     //     Row(
// //     //       children: [
// //     //         InfoCard(
// //     //           title: "Rides in progress",
// //     //           value: "7",
// //     //           onTap: () {},
// //     //           topColor: RoleColorUtil.getRoleColor("rides in progress"),
// //     //         ),
// //     //         SizedBox(
// //     //           width: width / 64,
// //     //         ),
// //     //         InfoCard(
// //     //           title: "Packages delivered",
// //     //           value: "17",
// //     //           topColor: RoleColorUtil.getRoleColor("packages delivered"),
// //     //           onTap: () {},
// //     //         ),
// //     //       ],
// //     //     ),
// //     //     SizedBox(
// //     //       height: width / 64,
// //     //     ),
// //     //     Row(
// //     //       children: [
// //     //         InfoCard(
// //     //           title: "Cancelled delivery",
// //     //           value: "3",
// //     //           topColor: RoleColorUtil.getRoleColor("cancelled delivery"),
// //     //           onTap: () {},
// //     //         ),
// //     //         SizedBox(
// //     //           width: width / 64,
// //     //         ),
// //     //         InfoCard(
// //     //           title: "Scheduled deliveries",
// //     //           value: "32",
// //     //           topColor: RoleColorUtil.getRoleColor("scheduled deliveries"),
// //     //           onTap: () {},
// //     //         ),
// //     //       ],
// //     //     ),
// //     //   ],
// //     // );
// //   }
// // }


// import 'package:admindashboard/pages/overview/widgets/info_card.dart';
// import 'package:admindashboard/pages/roles/Widgets/role_color_util.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';


// class OverviewCardMediumScreen extends StatelessWidget {
//   OverviewCardMediumScreen({super.key});

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
//           return Column(
//             children: [
//               for (int i = 0; i < roles.length; i += 2)
//                 Row(
//                   children: [
//                     for (int j = i; j < i + 2 && j < roles.length; j++)
//                       Expanded(
//                         child: InfoCard(
//                           title: roles[j],
//                           value: "",
//                           topColor: RoleColorUtil.getRoleColor(roles[j]),
//                           onTap: () {},
//                           isLoading: true,
//                         ),
//                       ),
//                   ],
//                 ),
//             ],
//           );
//         }

//         if (snapshot.hasError) {
//           return Center(
//             child: Text("Error al cargar datos: ${snapshot.error}"),
//           );
//         }

//         final roleCounts = snapshot.data ?? {};

//         return Column(
//           children: [
//             for (int i = 0; i < roles.length; i += 2)
//               Row(
//                 children: [
//                   for (int j = i; j < i + 2 && j < roles.length; j++)
//                     Expanded(
//                       child: InfoCard(
//                         title: roles[j],
//                         value: "${roleCounts[roles[j]] ?? 0}",
//                         topColor: RoleColorUtil.getRoleColor(roles[j]),
//                         onTap: () {},
//                       ),
//                     ),
//                 ],
//               ),
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

class OverviewCardMediumScreen extends StatelessWidget {
  OverviewCardMediumScreen({super.key});

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
              for (int i = 0; i < roles.length; i += 2)
                Row(
                  children: [
                    for (int j = i; j < i + 2 && j < roles.length; j++)
                      Expanded(
                        child: InfoCard(
                          title: roles[j],
                          value: "",
                          topColor: RoleColorUtil.getRoleColor(roles[j]),
                          onTap: () {},
                          isLoading: true,
                        ),
                      ),
                  ],
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
            for (int i = 0; i < roles.length; i += 2)
              Row(
                children: [
                  for (int j = i; j < i + 2 && j < roles.length; j++)
                    Expanded(
                      child: InfoCard(
                        title: roles[j],
                        value: "${roleCounts[roles[j]] ?? 0}",
                        topColor: RoleColorUtil.getRoleColor(roles[j]),
                        onTap: () {},
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }
}