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


import 'package:cloud_firestore/cloud_firestore.dart';


class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({super.key});

  Future<List<BarChartGroupData>> _fetchVisitsData() async {
    final visitsCollection = FirebaseFirestore.instance.collection('Visits');
    List<BarChartGroupData> barGroups = [];
    int x = 1;

    try {
      final querySnapshot = await visitsCollection.get();

      // Obtener la fecha actual y la fecha de hace 3 meses
      DateTime now = DateTime.now();
      DateTime threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);

      // Contar los documentos por mes
      Map<String, int> monthlyVisits = {};

      for (var doc in querySnapshot.docs) {
        DateTime visitDate = (doc['Fecha'] as Timestamp).toDate();
        if (visitDate.isAfter(threeMonthsAgo)) {
          String monthKey = "${visitDate.year}-${visitDate.month}";
          if (monthlyVisits.containsKey(monthKey)) {
            monthlyVisits[monthKey] = monthlyVisits[monthKey]! + 1;
          } else {
            monthlyVisits[monthKey] = 1;
          }
        }
      }

      monthlyVisits.forEach((key, value) {
        barGroups.add(
          BarChartGroupData(
            x: x,
            barRods: [BarChartRodData(toY: value.toDouble())],
          ),
        );
        x++;
      });
    } catch (e) {
      // Manejo de errores
      //print("Error al obtener datos de visitas: $e");
      throw Exception("Error al obtener datos de visitas");
    }

    return barGroups;
  }

  @override
  Widget build(BuildContext context) {
    final Future<List<BarChartGroupData>> _visitsFuture = _fetchVisitsData();

    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            margin: const EdgeInsets.all(24),
            child: FutureBuilder<List<BarChartGroupData>>(
              future: _visitsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No ha tenido visitas en los últimos 3 meses');
                }

                return BarChart(
                  BarChartData(
                    barGroups: snapshot.data!,
                    alignment: BarChartAlignment.spaceEvenly,
                    titlesData: const FlTitlesData(
                      leftTitles: AxisTitles(
                        axisNameWidget: Text('Visitas'),
                        sideTitles: SideTitles(
                          reservedSize: 44,
                          showTitles: true,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}