
import 'package:flutter/material.dart';

class TableShimmer extends StatelessWidget {
  final int itemCount;
  final double verticalSpacing;
  final double horizontalPadding;
  final bool isCircleAvatar;

  const TableShimmer({
    super.key,
    this.itemCount = 5,
    this.verticalSpacing = 8.0,
    this.horizontalPadding = 16.0,
    this.isCircleAvatar = true,
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
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              _buildShimmerBox(
                40,
                40,
                isCircle: isCircleAvatar
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(120, 16),
                    const SizedBox(height: 8),
                    _buildShimmerBox(80, 12),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildShimmerBox(60, 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox(
    double width, 
    double height, {
    bool isCircle = false,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: isCircle 
          ? BorderRadius.circular(height / 2) 
          : BorderRadius.circular(4),
      ),
    );
  }
}