import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SmallVisitsPieChart extends StatefulWidget {
  const SmallVisitsPieChart({super.key});

  @override
  State<SmallVisitsPieChart> createState() => _SmallVisitsPieChartState();
}

class _SmallVisitsPieChartState extends State<SmallVisitsPieChart> {
  late Future<List<PieChartSectionData>> _visitsFuture;
  static const _queryTimeout = Duration(seconds: 10);
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _visitsFuture = _fetchVisitsData();
  }

  Future<List<PieChartSectionData>> _fetchVisitsData() async {
    final visitsCollection = FirebaseFirestore.instance.collection('Visits');
    final Map<String, int> visitsByPropVisita = {};
    final List<Color> sectionColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ];

    try {
      final querySnapshot = await visitsCollection
          .get(const GetOptions(source: Source.server))
          .timeout(_queryTimeout);

      if (!mounted) return [];

      for (var doc in querySnapshot.docs) {
        String propVisita = doc['PropositoVisita'] as String? ?? 'Otros';
        visitsByPropVisita[propVisita] = (visitsByPropVisita[propVisita] ?? 0) + 1;
      }

      List<PieChartSectionData> sections = [];
      int colorIndex = 0;
      double total = visitsByPropVisita.values.fold(0, (suma, counter) => suma + counter);

      visitsByPropVisita.forEach((type, counter) {
        final double percentage = (counter / total) * 100;
        sections.add(
          PieChartSectionData(
            color: sectionColors[colorIndex % sectionColors.length],
            value: percentage,
            title: '${percentage.toStringAsFixed(0)}%',
            radius: touchedIndex == colorIndex ? 65 : 60,
            titleStyle: TextStyle(
              fontSize: touchedIndex == colorIndex ? 12 : 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            // badgeWidget: type.length > 10
            //     ? null
            //     : _SmallBadge(
            //         type,
            //         size: 30,
            //         borderColor: sectionColors[colorIndex % sectionColors.length],
            //       ),
            // badgePositionPercentageOffset: .95,
          ),
        );
        colorIndex++;
      });

      return sections;
    } catch (e) {
      debugPrint('Error al obtener datos de las visitas: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              const Text(
                'Visitas por Propósito',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: FutureBuilder<List<PieChartSectionData>>(
                  future: _visitsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Sin datos'));
                    }

                    return PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback: (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              touchedIndex = pieTouchResponse?.touchedSection?.touchedSectionIndex ?? -1;
                            });
                          },
                        ),
                        sections: snapshot.data!,
                        sectionsSpace: 1,
                        centerSpaceRadius: 25,
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 150),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class _SmallBadge extends StatelessWidget {
//   final String text;
//   final double size;
//   final Color borderColor;

//   const _SmallBadge(this.text, {
//     required this.size,
//     required this.borderColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: PieChart.defaultDuration,
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         shape: BoxShape.circle,
//         border: Border.all(color: borderColor),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.2),
//             offset: const Offset(1, 1),
//             blurRadius: 2,
//           ),
//         ],
//       ),
//       padding: EdgeInsets.all(size * .15),
//       child: FittedBox(
//         child: Text(
//           text,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             color: borderColor,
//           ),
//         ),
//       ),
//     );
//   }
// }