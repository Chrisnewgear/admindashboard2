
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// class TableShimmer extends StatelessWidget {
//   final int itemCount;
//   final double verticalSpacing;
//   final double horizontalPadding;
//   final bool isCircleAvatar;

//   const  TableShimmer({
//     super.key,
//     this.itemCount = 5,
//     this.verticalSpacing = 8.0,
//     this.horizontalPadding = 16.0,
//     this.isCircleAvatar = true,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: itemCount,
//       itemBuilder: (context, index) {
//         return Container(
//           margin: EdgeInsets.symmetric(
//             vertical: verticalSpacing,
//             horizontal: horizontalPadding
//           ),
//           padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 spreadRadius: 1,
//                 blurRadius: 3,
//                 offset: const Offset(0, 1),
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               Row(
//                 children: [
//                   _buildShimmerBox(
//                     40,
//                     40,
//                     isCircle: isCircleAvatar
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         _buildShimmerBox(190, 16),
//                         const SizedBox(height: 8),
//                         _buildShimmerBox(110, 12),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   _buildShimmerBox(60, 30, isCircle: true),
//                   const SizedBox(width: 60),
//                   _buildShimmerBox(60, 20)
//                 ],
//               ),
//             ],
//           )
//         );
//       },
//     );
//   }

//   Widget _buildShimmerBox(
//     double width,
//     double height, {
//     bool isCircle = false,
//   }) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: isCircle
//           ? BorderRadius.circular(height / 2)
//           : BorderRadius.circular(4),
//       ),
//     );
//   }
// }


// class TableShimmer extends StatelessWidget {
//   final int itemCount;
//   final double verticalSpacing;
//   final double horizontalPadding;

//   const TableShimmer({
//     super.key,
//     this.itemCount = 5,
//     this.verticalSpacing = 8.0,
//     this.horizontalPadding = 16.0,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Header shimmer
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _buildShimmerBox(120, 24),
//                 const SizedBox(width: 16),
//                 _buildShimmerBox(120, 24),
//                 const SizedBox(width: 16),
//                 _buildShimmerBox(120, 24),
//                 const SizedBox(width: 16),
//                 _buildShimmerBox(120, 24),
//                 const SizedBox(width: 16),
//                 _buildShimmerBox(120, 24),
//                 const SizedBox(width: 16),
//                 _buildShimmerBox(120, 24),
//                 const SizedBox(width: 16),
//                 _buildShimmerBox(120, 24),
//                 const SizedBox(width: 16),
//                 _buildShimmerBox(120, 24),
//                 // Row(
//                 //   children: [
//                 //     _buildShimmerBox(200, 40, isInput: true),
//                 //     const SizedBox(width: 16),
//                 //     _buildShimmerBox(100, 40),
//                 //   ],
//                 // ),
//               ],
//             ),
//             //const SizedBox(height: 16),
//             // Table header
//             // Row(
//             //   children: [
//             //     Expanded(flex: 2, child: _buildShimmerBox(80, 20)),
//             //     const SizedBox(width: 16),
//             //     Expanded(flex: 2, child: _buildShimmerBox(80, 20)),
//             //     const SizedBox(width: 16),
//             //     Expanded(child: _buildShimmerBox(80, 20)),
//             //   ],
//             // ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: itemCount,
//                 itemBuilder: (context, index) {
//                   return Padding(
//                     padding: EdgeInsets.symmetric(vertical: verticalSpacing),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           flex: 10,
//                           child: Row(
//                             children: [
//                               _buildShimmerBox(40, 40, isCircle: true),
//                               const SizedBox(width: 150),
//                               _buildShimmerBox(150, 20),
//                               const SizedBox(width: 40),
//                               _buildShimmerBox(150, 20),
//                               const SizedBox(width: 40),
//                               _buildShimmerBox(150, 20),
//                               const SizedBox(width: 40),
//                               _buildShimmerBox(150, 20),
//                               const SizedBox(width: 40),
//                               _buildShimmerBox(150, 20),
//                               const SizedBox(width: 40),
//                               _buildShimmerBox(150, 20),
//                             ],
//                           ),
//                         ),
//                         //const SizedBox(width: 16),  
//                         // Expanded(
//                         //   flex: 2,
//                         //   child: _buildShimmerBox(120, 20),
//                         // ),
//                         //const SizedBox(width: 16),
//                         Expanded(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               _buildShimmerBox(40, 40),
//                               const SizedBox(width: 8),
//                               _buildShimmerBox(40, 40),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmerBox(double width, double height, {
//     bool isCircle = false,
//     bool isInput = false,
//   }) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(isCircle ? 50 : isInput ? 8 : 4),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:shimmer/shimmer.dart';

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
                      // const SizedBox(width: 16),
                      // Expanded(
                      //   flex: 2,
                      //   child: _buildShimmerBox(150, 20),
                      // ),
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
