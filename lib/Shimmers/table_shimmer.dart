import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
class TableShimmer extends StatelessWidget {
  final int itemCount;
  final double verticalSpacing;
  final double horizontalPadding;

  const TableShimmer({
    super.key,
    this.itemCount = 5,
    this.verticalSpacing = 8.0,
    this.horizontalPadding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with search and add button
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Column headers
                _buildShimmerBox(160, 20),
                const SizedBox(width: 100),
                _buildShimmerBox(160, 20),
                const SizedBox(width: 100),
                _buildShimmerBox(160, 20),
                const SizedBox(width: 100),
                _buildShimmerBox(160, 20),
                const SizedBox(width: 100),
                _buildShimmerBox(160, 20),
                const SizedBox(width: 100),
                _buildShimmerBox(160, 20),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Data rows
          Expanded(
            child: ListView.separated(
              itemCount: itemCount,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: Row(
                          children: [
                            _buildShimmerBox(40, 40, isCircle: true),
                            const SizedBox(width: 220),
                            _buildShimmerBox(160, 20),
                            const SizedBox(width: 100),
                            _buildShimmerBox(160, 20),
                            const SizedBox(width: 100),
                            _buildShimmerBox(160, 20),
                            const SizedBox(width: 100),
                            _buildShimmerBox(160, 20),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _buildShimmerBox(32, 32),
                            const SizedBox(width: 8),
                            _buildShimmerBox(32, 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerBox(double width, double height, {
    bool isCircle = false,
    bool isSearchBar = false,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            isCircle ? 50 : isSearchBar ? 30 : 4,
          ),
        ),
      ),
    );
  }
}
