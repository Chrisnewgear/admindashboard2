import 'package:admindashboard/constants/style.dart';
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



import 'package:flutter/material.dart';

class InfoCardSmall extends StatelessWidget {
  final String title;
  final String value;
  final bool isActive;
  final Function() onTap;
  final bool isLoading;

  const InfoCardSmall({
    super.key,
    required this.title,
    required this.value,
    this.isActive = false,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          transform: isActive
              ? Matrix4.diagonal3Values(1.05, 1.05, 1.0) // Scaling effect
              : Matrix4.identity(),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isActive ? Colors.blueAccent.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(
              color: isActive ? Colors.blueAccent : const Color(0xFFDDDDDD),
              width: 1.5,
            ),
          ),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: isActive ? Colors.blueAccent : const Color(0xFFCCCCCC),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isActive ? Colors.blueAccent : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.blueAccent : Colors.black87,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
