import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VisitsPieChart extends StatefulWidget {
  const VisitsPieChart({super.key});

  @override
  State<VisitsPieChart> createState() => _VisitsPieChartState();
}

class _VisitsPieChartState extends State<VisitsPieChart> {
  late Future<List<PieChartSectionData>> _visitsFuture;
  static const _queryTimeout = Duration(seconds: 10);
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    _visitsFuture = _fetchVisitsData();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
        visitsByPropVisita[propVisita] =
            (visitsByPropVisita[propVisita] ?? 0) + 1;
      }

      List<PieChartSectionData> sections = [];
      int colorIndex = 0;
      double total =
          visitsByPropVisita.values.fold(0, (suma, counter) => suma + counter);

      visitsByPropVisita.forEach((type, counter) {
        final double percentage = (counter / total) * 100;
        sections.add(
          PieChartSectionData(
            color: sectionColors[colorIndex % sectionColors.length],
            value: percentage,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: touchedIndex == colorIndex ? 110 : 100,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: _Badge(
              type,
              size: 40,
              borderColor: sectionColors[colorIndex % sectionColors.length],
            ),
            badgePositionPercentageOffset: .98,
          ),
        );
        colorIndex++;
      });

      return sections;
    } catch (e) {
      debugPrint('Error al obtener datos de las visitas: $e');
      _showErrorSnackBar('Error al cargar los datos de visitas: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Distribución de visitas por propósito',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<PieChartSectionData>>(
                  future: _visitsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      _showErrorSnackBar('Error: ${snapshot.error}');
                      return const Center(
                        child: Icon(Icons.error_outline,
                            color: Colors.red, size: 60),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No hay datos disponibles'),
                      );
                    }

                    return PieChart(
                      PieChartData(
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                touchedIndex = -1;
                                return;
                              }
                              touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                        sections: snapshot.data!.map((section) {
                          final isTouched =
                              touchedIndex == snapshot.data!.indexOf(section);
                          final fontSize = isTouched ? 20.0 : 16.0;
                          final radius = isTouched ? 110.0 : 100.0;
                          final List<Shadow> shadows = isTouched
                              ? [
                                  const Shadow(
                                      color: Colors.black, blurRadius: 3)
                                ]
                              : [];

                          return PieChartSectionData(
                            color:
                                section.color.withOpacity(isTouched ? 1 : 0.9),
                            value: section.value,
                            title: section.title,
                            radius: radius,
                            titleStyle: TextStyle(
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: shadows,
                            ),
                            badgeWidget: section.badgeWidget,
                            badgePositionPercentageOffset: .98,
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                      swapAnimationDuration: const Duration(milliseconds: 50),
                      swapAnimationCurve: Curves.easeInOutQuad,
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final double size;
  final Color borderColor;

  const _Badge(
    this.text, {
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: size * .2,
            fontWeight: FontWeight.bold,
            color: borderColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
