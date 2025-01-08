import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SmallShimmer extends StatelessWidget {
  const SmallShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (index) => Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          child: Shimmer.fromColors(
            period: const Duration(milliseconds: 2000),
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[50]!,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[200]!,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 5,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 120,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 24,
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
    );
  }
}