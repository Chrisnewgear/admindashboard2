import 'package:flutter/material.dart';


Future<void> showCustomAlert(BuildContext context, String message) async {
  // Store the original context
  if (!context.mounted) return; // Ensure the context is still valid before showing the dialog

  // return showDialog<void>(
  //   context: context,
  //   barrierDismissible: false, // User must tap a button to dismiss the alert
  //   builder: (BuildContext context) {
  //     return AlertDialog(
  //       title: const Text('Alert'),
  //       content: SingleChildScrollView(
  //         child: ListBody(
  //           children: <Widget>[
  //             Text(message),
  //           ],
  //         ),
  //       ),
  //       actions: <Widget>[
  //         TextButton(
  //           child: const Text('OK'),
  //           onPressed: () {
  //             Navigator.of(context).pop();
  //           },
  //         ),
  //       ],
  //     );
  //   },
  // );

  // return showDialog<void>(
//   context: context,
//   barrierDismissible: false, // User must tap a button to dismiss the alert
//   builder: (BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       title: const Row(
//         children: [
//           Icon(Icons.warning, color: Colors.orangeAccent),
//           SizedBox(width: 10),
//           Text(
//             'Alert',
//             style: TextStyle(
//               color: Colors.orangeAccent,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//       content: SingleChildScrollView(
//         child: ListBody(
//           children: <Widget>[
//             Text(
//               message,
//               style: const TextStyle(fontSize: 16, height: 1.5),
//             ),
//           ],
//         ),
//       ),
//       actions: <Widget>[
//         TextButton(
//           style: TextButton.styleFrom(
//             backgroundColor: const Color(0xFF3C19c0),
//             padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
//           ),
//           child: const Text(
//             'OK',
//             style: TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           onPressed: () {
//             Navigator.of(context).pop();
//           },
//         ),
//       ],
//       backgroundColor: Colors.white,
//       elevation: 5,
//     );
//   },
// );


return showDialog<void>(
  context: context,
  barrierDismissible: false, // User must tap a button to dismiss the alert
  builder: (BuildContext context) {
    bool isHovered = false; // Variable to track hover state

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orangeAccent),
              SizedBox(width: 10),
              Text(
                'Alert',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  message,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            MouseRegion(
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.orangeAccent),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: isHovered ? Color(0xFF3C19c0).withOpacity(0.1) : Colors.transparent,
                ),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: isHovered ? Colors.orangeAccent : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
          backgroundColor: Colors.white,
          elevation: 5,
        );
      },
    );
  },
);



}
