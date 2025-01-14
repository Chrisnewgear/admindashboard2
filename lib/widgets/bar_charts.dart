import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// class SimpleBarChart extends StatelessWidget {
//   const SimpleBarChart({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: Center(
//             child: AspectRatio(
//                 aspectRatio: 16 / 9,
//                 child: Container(
//                     margin: const EdgeInsets.all(24),
//                     child: BarChart(
//                       BarChartData(
//                         barGroups: [
//                           BarChartGroupData(
//                             x: 1,
//                             barRods: [BarChartRodData(toY: 15)],
//                           ),
//                           BarChartGroupData(
//                             x: 2,
//                             barRods: [BarChartRodData(toY: 10)],
//                           ),
//                           BarChartGroupData(
//                             x: 3,
//                             barRods: [BarChartRodData(toY: 7)],
//                           ),
//                           BarChartGroupData(
//                             x: 4,
//                             barRods: [BarChartRodData(toY: 2)],
//                           ),
//                         ],
//                         alignment: BarChartAlignment.spaceEvenly,
//                         titlesData: const FlTitlesData(
//                             leftTitles: AxisTitles(
//                                 axisNameWidget: Text('Revenues'),
//                                 sideTitles: SideTitles(
//                                   reservedSize: 44, showTitles: true
//                                 )
//                             )
//                         ),
//                       ),
//                     )
//                   )
//                 )
//               )
//             );
//   }
// }

// import 'package:cloud_firestore/cloud_firestore.dart';

// class SimpleBarChart extends StatelessWidget {
//   const SimpleBarChart({super.key});

//   Future<List<BarChartGroupData>> _fetchVisitsData() async {
//     final visitsCollection = FirebaseFirestore.instance.collection('Users').doc('Visits');
//     final snapshot = await visitsCollection.get();
//     final visitsData = snapshot.data() ?? {};

//     List<BarChartGroupData> barGroups = [];
//     int x = 1;
//     visitsData.forEach((key, value) {
//       barGroups.add(
//         BarChartGroupData(
//           x: x,
//           barRods: [BarChartRodData(toY: value.toDouble())],
//         ),
//       );
//       x++;
//     });

//     return barGroups;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: AspectRatio(
//           aspectRatio: 16 / 9,
//           child: Container(
//             margin: const EdgeInsets.all(24),
//             child: FutureBuilder<List<BarChartGroupData>>(
//               future: _fetchVisitsData(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Text('No data available');
//                 }

//                 return BarChart(
//                   BarChartData(
//                     barGroups: snapshot.data!,
//                     alignment: BarChartAlignment.spaceEvenly,
//                     titlesData: const FlTitlesData(
//                       leftTitles: AxisTitles(
//                         axisNameWidget: Text('Revenues'),
//                         sideTitles: SideTitles(
//                           reservedSize: 44,
//                           showTitles: true,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



// class SimpleBarChart extends StatelessWidget {
//   const SimpleBarChart({super.key});

//   Future<List<BarChartGroupData>> _fetchVisitsData() async {
//     final visitsCollection = FirebaseFirestore.instance.collection('Visits');
//     List<BarChartGroupData> barGroups = [];
//     int x = 1;

//     try {
//       final querySnapshot = await visitsCollection.get();

//       // Obtener la fecha actual y la fecha de hace 3 meses
//       DateTime now = DateTime.now();
//       DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);

//       // Contar los documentos por mes
//       Map<String, int> monthlyVisits = {};

//       for (var doc in querySnapshot.docs) {
//         DateTime visitDate = (doc['Fecha'] as Timestamp).toDate();
//         if (visitDate.isAfter(threeMonthsAgo)) {
//           String monthKey = "${visitDate.year}-${visitDate.month}";
//           if (monthlyVisits.containsKey(monthKey)) {
//             monthlyVisits[monthKey] = monthlyVisits[monthKey]! + 1;
//           } else {
//             monthlyVisits[monthKey] = 1;
//           }
//         }
//       }

//       monthlyVisits.forEach((key, value) {
//         barGroups.add(
//           BarChartGroupData(
//             x: x,
//             barRods: [BarChartRodData(toY: value.toDouble())],
//           ),
//         );
//         x++;
//       });
//     } catch (e) {
//       // Manejo de errores
//       //print("Error al obtener datos de visitas: $e");
//       throw Exception("Error al obtener datos de visitas");
//     }

//     return barGroups;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Future<List<BarChartGroupData>> _visitsFuture = _fetchVisitsData();

//     return Scaffold(
//       body: Center(
//         child: AspectRatio(
//           aspectRatio: 16 / 9,
//           child: Container(
//             margin: const EdgeInsets.all(24),
//             child: FutureBuilder<List<BarChartGroupData>>(
//               future: _visitsFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const CircularProgressIndicator();
//                 } else if (snapshot.hasError) {
//                   return Text('Error: ${snapshot.error}');
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Text('No ha tenido visitas en los últimos 3 meses');
//                 }

//                 return BarChart(
//                   BarChartData(
//                     barGroups: snapshot.data!,
//                     alignment: BarChartAlignment.spaceEvenly,
//                     titlesData: const FlTitlesData(
//                       leftTitles: AxisTitles(
//                         axisNameWidget: Text('Visitas'),
//                         sideTitles: SideTitles(
//                           reservedSize: 44,
//                           showTitles: true,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class SimpleBarChart extends StatelessWidget {
//   const SimpleBarChart({super.key});

//   Future<List<BarChartGroupData>> _fetchVisitsData() async {
//     final visitsCollection = FirebaseFirestore.instance.collection('Visits');
//     List<BarChartGroupData> barGroups = [];
//     int x = 1;

//     try {
//       final querySnapshot = await visitsCollection.get();

//       DateTime now = DateTime.now();
//       DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);

//       Map<String, int> monthlyVisits = {};

//       for (var doc in querySnapshot.docs) {
//         DateTime visitDate = (doc['Fecha'] as Timestamp).toDate();
//         if (visitDate.isAfter(threeMonthsAgo)) {
//           String monthKey = "${visitDate.year}-${visitDate.month}";
//           if (monthlyVisits.containsKey(monthKey)) {
//             monthlyVisits[monthKey] = monthlyVisits[monthKey]! + 1;
//           } else {
//             monthlyVisits[monthKey] = 1;
//           }
//         }
//       }

//       monthlyVisits.forEach((key, value) {
//         barGroups.add(
//           BarChartGroupData(
//             x: x,
//             barRods: [
//               BarChartRodData(
//                 toY: value.toDouble(),
//                 width: 25, // Ancho de las barras
//                 color: Colors.blue.shade300,
//                 borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
//               )
//             ],
//           ),
//         );
//         x++;
//       });
//     } catch (e) {
//       debugPrint("Error al obtener datos de visitas: $e");
//       throw Exception("Error al obtener datos de visitas");
//     }

//     return barGroups;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Future<List<BarChartGroupData>> _visitsFuture = _fetchVisitsData();
//     final size = MediaQuery.of(context).size;

//     return Scaffold(
//       body: Center(
//         child: Container(
//           height: size.height * 0.6, // 60% de la altura de la pantalla
//           width: size.width * 0.8, // 80% del ancho de la pantalla
//           padding: const EdgeInsets.all(16),
//           child: FutureBuilder<List<BarChartGroupData>>(
//             future: _visitsFuture,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (snapshot.hasError) {
//                 return Center(
//                   child: Text(
//                     'Error: ${snapshot.error}',
//                     style: const TextStyle(color: Colors.red),
//                   ),
//                 );
//               } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                 return const Center(
//                   child: Text(
//                     'No ha tenido visitas en los últimos 3 meses',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 );
//               }

//               return BarChart(
//                 BarChartData(
//                   barGroups: snapshot.data!,
//                   alignment: BarChartAlignment.spaceEvenly,
//                   maxY: 50,
//                   barTouchData: BarTouchData(enabled: true),
//                   gridData: const FlGridData(
//                     show: true,
//                     drawVerticalLine: false,
//                     horizontalInterval: 10,
//                   ),
//                   borderData: FlBorderData(
//                     show: true,
//                     border: Border.all(color: Colors.grey.shade300),
//                   ),
//                   titlesData: const FlTitlesData(
//                     show: true,
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 30,
//                       ),
//                       axisNameWidget: Padding(
//                         padding: EdgeInsets.only(top: 1.0),
//                         child: Text('Últimos 3 meses'),
//                       ),
//                     ),
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 44,
//                         interval: 10,
//                       ),
//                       axisNameWidget: Padding(
//                         padding: EdgeInsets.only(bottom: 1.0),
//                         child: Text('Visitas'),
//                       ),
//                     ),
//                     topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                     rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';


class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({super.key});

  Future<List<BarChartGroupData>> _fetchVisitsData() async {
    final visitsCollection = FirebaseFirestore.instance.collection('Visits');
    List<BarChartGroupData> barGroups = [];
    final List<String> monthNames = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];

    try {
      final querySnapshot = await visitsCollection.get();
      DateTime now = DateTime.now();
      DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
      Map<int, int> monthlyVisits = {};

      for (var doc in querySnapshot.docs) {
        DateTime visitDate = (doc['Fecha'] as Timestamp).toDate();
        if (visitDate.isAfter(threeMonthsAgo)) {
          int monthKey = visitDate.month;
          monthlyVisits[monthKey] = (monthlyVisits[monthKey] ?? 0) + 1;
        }
      }

      // Get last 3 months
      for (int i = 2; i >= 0; i--) {
        int monthIndex = (now.month - i - 1) % 12;
        if (monthIndex < 0) monthIndex += 12;

        barGroups.add(
          BarChartGroupData(
            x: 2 - i,
            barRods: [
              BarChartRodData(
                toY: (monthlyVisits[monthIndex + 1] ?? 0).toDouble(),
                width: 25,
                color: Colors.blue.shade300,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(6)),
              )
            ],
          ),
        );
      }
    } catch (e) {
      debugPrint("Error al obtener datos de visitas: $e");
      throw Exception("Error al obtener datos de visitas");
    }

    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<BarChartGroupData>> _visitsFuture = _fetchVisitsData();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Center(
        child: Container(
          height: size.height * 0.6,
          width: size.width * 0.8,
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<List<BarChartGroupData>>(
            future: _visitsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No ha tenido visitas en los últimos 3 meses',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              return BarChart(
                BarChartData(
                  barGroups: snapshot.data!,
                  alignment: BarChartAlignment.spaceEvenly,
                  maxY: 50,
                  barTouchData: BarTouchData(enabled: true),
                  gridData: const FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 10,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final List<String> months = [
                            'Ene',
                            'Feb',
                            'Mar',
                            'Abr',
                            'May',
                            'Jun',
                            'Jul',
                            'Ago',
                            'Sep',
                            'Oct',
                            'Nov',
                            'Dic'
                          ];
                          final currentMonth = DateTime.now().month;
                          final monthIndex =
                              (currentMonth - 3 + value.toInt()) % 12;
                          return Text(months[monthIndex]);
                        },
                      ),
                      axisNameWidget: const Padding(
                        padding: EdgeInsets.only(top: 1.0),
                        child: Text('Últimos 3 meses'),
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: 10,
                      ),
                      axisNameWidget: Padding(
                        padding: EdgeInsets.only(bottom: 1.0),
                        child: Text('Visitas'),
                      ),
                    ),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
