import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class OverviewShimmer extends StatelessWidget {
  const OverviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        4,
        (index) => Expanded(
          child: Container(
            margin: const EdgeInsets.all(8.0),
            child: Shimmer.fromColors(
              period: const Duration(milliseconds: 2000), // Slower animation
              baseColor: Colors.grey[200]!, // Lighter base color
              highlightColor: Colors.grey[50]!, // Almost white highlight
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[200]!,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top colored bar
                    Container(
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Title shimmer
                            Container(
                              width: double.infinity,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Value shimmer
                            Container(
                              width: 50,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}