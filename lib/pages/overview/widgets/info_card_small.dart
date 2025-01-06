import 'package:admindashboard/widgets/custom_text.dart';
import 'package:flutter/material.dart';

// class InfoCardSmall extends StatelessWidget {
//   final String title;
//   final String value;
//   final bool isActive;
//   final Function() onTap;

//   const InfoCardSmall({
//     super.key,
//     required this.title,
//     required this.value,
//     this.isActive = false,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         child: Container(
//             padding: const EdgeInsets.all(24),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: isActive ? active : lightGrey, width: .5),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 CustomText(
//                   text: title,
//                   size: 24,
//                   weight: FontWeight.w300,
//                   color: isActive ? active : lightGrey,
//                 ),
//                 CustomText(
//                   text: value,
//                   size: 24,
//                   weight: FontWeight.bold,
//                   color: isActive ? active : dark,
//                 )
//               ],
//             )),
//       ),
//     );
//   }
// }




// class InfoCardSmall extends StatelessWidget {
//   final String title;
//   final String value;
//   final bool isActive;
//   final Function() onTap;
//   final bool isLoading;

//   const InfoCardSmall({
//     super.key,
//     required this.title,
//     required this.value,
//     this.isActive = false,
//     required this.onTap,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           curve: Curves.easeInOut,
//           transform: isActive
//               ? Matrix4.diagonal3Values(1.05, 1.05, 1.0) // Scaling effect
//               : Matrix4.identity(),
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: isActive ? Colors.blueAccent.withOpacity(0.1) : Colors.white,
//             borderRadius: BorderRadius.circular(12),
//             boxShadow: [
//               if (isActive)
//                 BoxShadow(
//                   color: Colors.blueAccent.withOpacity(0.5),
//                   blurRadius: 15,
//                   spreadRadius: 1,
//                 ),
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.2),
//                 blurRadius: 10,
//                 spreadRadius: 2,
//                 offset: const Offset(0, 5),
//               ),
//             ],
//             border: Border.all(
//               color: isActive ? Colors.blueAccent : const Color(0xFFDDDDDD),
//               width: 1.5,
//             ),
//           ),
//           child: isLoading
//               ? Center(
//                   child: CircularProgressIndicator(
//                     color: isActive ? Colors.blueAccent : const Color(0xFFCCCCCC),
//                   ),
//                 )
//               : Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w500,
//                         color: isActive ? Colors.blueAccent : Colors.black54,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Text(
//                       value,
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: isActive ? Colors.blueAccent : Colors.black87,
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }


// class InfoCardSmall extends StatelessWidget {
//   final String title;
//   final String value;
//   final bool isActive;
//   final Function() onTap;
//   final bool isLoading;

//   const InfoCardSmall({
//     super.key,
//     required this.title,
//     required this.value,
//     this.isActive = false,
//     required this.onTap,
//     this.isLoading = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: onTap,
//         child: Container(
//           margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//           padding: const EdgeInsets.all(24),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: const Color(0xFF4A6FA5).withOpacity(0.08),
//                 blurRadius: 20,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//             border: Border.all(
//               color: isActive ? const Color(0xFF4A6FA5) : Colors.transparent,
//               width: 2,
//             ),
//           ),
//           child: isLoading
//               ? const Center(
//                   child: CircularProgressIndicator(
//                     color: Color(0xFF4A6FA5),
//                   ),
//                 )
//               : Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.flight_takeoff,
//                           color: const Color(0xFF4A6FA5),
//                           size: 20,
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             title,
//                             style: const TextStyle(
//                               fontSize: 16,
//                               color: Color(0xFF2D3748),
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       value,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1A202C),
//                       ),
//                     ),
//                     if (isActive)
//                       Container(
//                         margin: const EdgeInsets.only(top: 12),
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 6,
//                         ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF4A6FA5).withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: const Text(
//                           'Get started',
//                           style: TextStyle(
//                             color: Color(0xFF4A6FA5),
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }

class InfoCardSmall extends StatelessWidget {
  final String title;
  final String value;
  final bool isActive;
  final Function() onTap;

  const InfoCardSmall({
    super.key, 
    required this.title,
    required this.value,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: title,
                      size: 16,
                      weight: FontWeight.w600,
                      color: const Color(0xFF2D3748),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                width: 40,
                alignment: Alignment.center,
                child: CustomText(
                  text: value,
                  size: 16,
                  weight: FontWeight.w500,
                  color: Colors.grey[700]!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}