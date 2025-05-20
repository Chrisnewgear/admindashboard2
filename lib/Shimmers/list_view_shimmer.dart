
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ListViewShimmer extends StatelessWidget {
  final int itemCount;
  final double verticalSpacing;
  final double horizontalPadding;

  const ListViewShimmer({
    super.key,
    this.itemCount = 5,
    this.verticalSpacing = 8.0,
    this.horizontalPadding = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(
            vertical: verticalSpacing,
            horizontal: horizontalPadding
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                leading: _buildShimmerBox(48, 48, isCircle: true),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  _buildShimmerBox(200, 20),
                  const SizedBox(height: 8),
                  _buildShimmerBox(100, 16),
                  ],
                ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox(double width, double height, {bool isCircle = false}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(isCircle ? 24 : 4),
        ),
      ),
    );
  }
}