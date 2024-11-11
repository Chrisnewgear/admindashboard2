// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:admindashboard/constants/style.dart';
// import 'package:admindashboard/widgets/custom_text.dart';

// class ProfileWidget extends StatelessWidget {
//   const ProfileWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final User? user = FirebaseAuth.instance.currentUser;

//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance.collection('Users').doc(user?.uid).snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         if (!snapshot.hasData || !snapshot.data!.exists) {
//           return const Center(child: Text('No user data found'));
//         }

//         final userData = snapshot.data!.data() as Map<String, dynamic>;

//         return SingleChildScrollView(
//           child: Container(
//             constraints: const BoxConstraints(maxWidth: 600),
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Perfil de Usuario',
//                   style: GoogleFonts.roboto(fontSize: 30, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 20),
//                 _buildProfileItem('Código', userData['Codigo'] ?? 'N/A'),
//                 _buildProfileItem('Nombre', userData['Nombre'] ?? 'N/A'),
//                 _buildProfileItem('Apellidos', userData['Apellidos'] ?? 'N/A'),
//                 _buildProfileItem('Email', userData['email'] ?? 'N/A'),
//                 _buildProfileItem('Teléfono', userData['Telefono'] ?? 'N/A'),
//                 const SizedBox(height: 30),
//                 Center(
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: active,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//                     ),
//                     onPressed: () {
//                       // Aquí puedes agregar la lógica para editar el perfil
//                     },
//                     child: const CustomText(
//                       text: "Editar Perfil",
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildProfileItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold, color: lightGrey),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: GoogleFonts.roboto(fontSize: 18),
//           ),
//           const Divider(),
//         ],
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_fonts/google_fonts.dart';

// class ProfileWidget extends StatelessWidget {
//   const ProfileWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final User? user = FirebaseAuth.instance.currentUser;

//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance.collection('Users').doc(user?.uid).snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         if (!snapshot.hasData || !snapshot.data!.exists) {
//           return const Center(child: Text('No user data found'));
//         }

//         final userData = snapshot.data!.data() as Map<String, dynamic>;

//         return Scaffold(
//           body: SingleChildScrollView(
//             child: Container(
//               constraints: const BoxConstraints(maxWidth: 450),
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     spreadRadius: 1,
//                     blurRadius: 10,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Tab navigation
//                   Row(
//                     children: [
//                       _buildTab('Edit Profile', isSelected: true),
//                       _buildTab('Preference'),
//                       _buildTab('Security'),
//                     ],
//                   ),
//                   const SizedBox(height: 30),
                  
//                   // Profile photo section
//                   Center(
//                     child: Stack(
//                       children: [
//                         Container(
//                           width: 100,
//                           height: 100,
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(Icons.photo_library_outlined, size: 40, color: Colors.grey),
//                         ),
//                         Positioned(
//                           right: 0,
//                           bottom: 0,
//                           child: Container(
//                             padding: const EdgeInsets.all(8),
//                             decoration: BoxDecoration(
//                               color: Colors.indigo,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 30),
                  
//                   // Form fields
//                   _buildTextField('Your Name', userData['Nombre'] ?? 'Charlene Reed'),
//                   _buildTextField('User Name', userData['Nombre'] ?? 'Charlene Reed'),
//                   _buildTextField('Email', userData['email'] ?? 'user@gmail.com'),
//                   _buildTextField('Password', '********', isPassword: true),
//                 ],
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTab(String text, {bool isSelected = false}) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         children: [
//           Text(
//             text,
//             style: TextStyle(
//               color: isSelected ? Colors.indigo : Colors.grey,
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           const SizedBox(height: 4),
//           if (isSelected)
//             Container(
//               height: 2,
//               width: 80,
//               color: Colors.indigo,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(String label, String value, {bool isPassword = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 14,
//               color: Colors.grey,
//             ),
//           ),
//           const SizedBox(height: 8),
//           TextField(
//             obscureText: isPassword,
//             controller: TextEditingController(text: value),
//             decoration: InputDecoration(
//               contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_fonts/google_fonts.dart';

// class ProfileWidget extends StatelessWidget {
//   const ProfileWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final User? user = FirebaseAuth.instance.currentUser;
//     final screenSize = MediaQuery.of(context).size;
//     final isSmallScreen = screenSize.width < 600;
//     final isPadSize = screenSize.width < 1024 && screenSize.width >= 600;

//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance.collection('Users').doc(user?.uid).snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         if (!snapshot.hasData || !snapshot.data!.exists) {
//           return const Center(child: Text('No user data found'));
//         }

//         final userData = snapshot.data!.data() as Map<String, dynamic>;

//         return Scaffold(
//           body: Center(
//             child: SingleChildScrollView(
//               child: Container(
//                 constraints: BoxConstraints(
//                   maxWidth: isSmallScreen 
//                       ? screenSize.width * 0.95
//                       : isPadSize 
//                           ? screenSize.width * 0.8 
//                           : 450,
//                 ),
//                 margin: EdgeInsets.symmetric(
//                   vertical: isSmallScreen ? 16 : 24,
//                   horizontal: isSmallScreen ? 12 : 24,
//                 ),
//                 padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(16),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.1),
//                       spreadRadius: 1,
//                       blurRadius: 10,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Tab navigation with horizontal scroll for small screens
//                     SingleChildScrollView(
//                       scrollDirection: Axis.horizontal,
//                       child: Row(
//                         children: [
//                           _buildTab('Edit Profile', isSelected: true),
//                           _buildTab('Preference'),
//                           _buildTab('Security'),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 30),
                    
//                     // Profile photo section
//                     Center(
//                       child: Stack(
//                         children: [
//                           Container(
//                             width: isSmallScreen ? 80 : 100,
//                             height: isSmallScreen ? 80 : 100,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               shape: BoxShape.circle,
//                             ),
//                             child: Icon(
//                               Icons.photo_library_outlined, 
//                               size: isSmallScreen ? 32 : 40, 
//                               color: Colors.grey
//                             ),
//                           ),
//                           Positioned(
//                             right: 0,
//                             bottom: 0,
//                             child: Container(
//                               padding: EdgeInsets.all(isSmallScreen ? 6 : 8),
//                               decoration: const BoxDecoration(
//                                 color: Colors.indigo,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: Icon(
//                                 Icons.camera_alt, 
//                                 size: isSmallScreen ? 16 : 20, 
//                                 color: Colors.white
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(height: isSmallScreen ? 20 : 30),
                    
//                     // Form fields
//                     _buildTextField(
//                       context,
//                       'Your Name', 
//                       userData['Nombre'] ?? 'Charlene Reed'
//                     ),
//                     _buildTextField(
//                       context,
//                       'User Name', 
//                       userData['Nombre'] ?? 'Charlene Reed'
//                     ),
//                     _buildTextField(
//                       context,
//                       'Email', 
//                       userData['email'] ?? 'user@gmail.com'
//                     ),
//                     _buildTextField(
//                       context,
//                       'Password', 
//                       '********', 
//                       isPassword: true
//                     ),
                    
//                     // Save Button
//                     const SizedBox(height: 20),
//                     Center(
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.indigo,
//                           padding: EdgeInsets.symmetric(
//                             horizontal: isSmallScreen ? 30 : 40,
//                             vertical: isSmallScreen ? 12 : 16,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         onPressed: () {
//                           // Add save functionality here
//                         },
//                         child: const Text(
//                           'Save Changes',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTab(String text, {bool isSelected = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 24),
//       child: Column(
//         children: [
//           Text(
//             text,
//             style: TextStyle(
//               color: isSelected ? Colors.indigo : Colors.grey,
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           const SizedBox(height: 4),
//           if (isSelected)
//             Container(
//               height: 2,
//               width: 80,
//               color: Colors.indigo,
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField(BuildContext context, String label, String value, {bool isPassword = false}) {
//     final isSmallScreen = MediaQuery.of(context).size.width < 600;

//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: isSmallScreen ? 12 : 14,
//               color: Colors.grey,
//             ),
//           ),
//           SizedBox(height: isSmallScreen ? 6 : 8),
//           TextField(
//             obscureText: isPassword,
//             controller: TextEditingController(text: value),
//             style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
//             decoration: InputDecoration(
//               contentPadding: EdgeInsets.symmetric(
//                 horizontal: isSmallScreen ? 12 : 16,
//                 vertical: isSmallScreen ? 8 : 12,
//               ),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//               enabledBorder: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide(color: Colors.grey[300]!),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_fonts/google_fonts.dart';

// class ProfileWidget extends StatelessWidget {
//   const ProfileWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final User? user = FirebaseAuth.instance.currentUser;
//     final screenSize = MediaQuery.of(context).size;
//     final isDesktop = screenSize.width > 1024;

//     return StreamBuilder<DocumentSnapshot>(
//       stream: FirebaseFirestore.instance.collection('Users').doc(user?.uid).snapshots(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         }

//         if (!snapshot.hasData || !snapshot.data!.exists) {
//           return const Center(child: Text('No user data found'));
//         }

//         final userData = snapshot.data!.data() as Map<String, dynamic>;

//         return Scaffold(
//           body: isDesktop 
//               ? _buildDesktopLayout(context, userData)
//               : _buildMobileLayout(context, userData),
//         );
//       },
//     );
//   }

//   Widget _buildDesktopLayout(BuildContext context, Map<String, dynamic> userData) {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(32.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Left sidebar with navigation
//             Card(
//               elevation: 2,
//               child: Container(
//                 width: 250,
//                 padding: const EdgeInsets.all(24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Profile photo section
//                     Center(
//                       child: Stack(
//                         children: [
//                           Container(
//                             width: 120,
//                             height: 120,
//                             decoration: BoxDecoration(
//                               color: Colors.grey[200],
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.photo_library_outlined,
//                               size: 50,
//                               color: Colors.grey,
//                             ),
//                           ),
//                           Positioned(
//                             right: 0,
//                             bottom: 0,
//                             child: Container(
//                               padding: const EdgeInsets.all(8),
//                               decoration: const BoxDecoration(
//                                 color: Colors.indigo,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: const Icon(
//                                 Icons.camera_alt,
//                                 size: 20,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     _buildNavItem('Edit Profile', isSelected: true),
//                     _buildNavItem('Preference'),
//                     _buildNavItem('Security'),
//                     _buildNavItem('Notifications'),
//                     _buildNavItem('Connected Accounts'),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(width: 24),
//             // Main content area
//             Expanded(
//               child: Card(
//                 elevation: 2,
//                 child: Container(
//                   padding: const EdgeInsets.all(32),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Edit Profile',
//                         style: GoogleFonts.roboto(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildTextField(
//                               context,
//                               'Your Name',
//                               userData['Nombre'] ?? 'Charlene Reed',
//                             ),
//                           ),
//                           const SizedBox(width: 24),
//                           Expanded(
//                             child: _buildTextField(
//                               context,
//                               'User Name',
//                               userData['Nombre'] ?? 'Charlene Reed',
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildTextField(
//                               context,
//                               'Email',
//                               userData['email'] ?? 'user@gmail.com',
//                             ),
//                           ),
//                           const SizedBox(width: 24),
//                           Expanded(
//                             child: _buildTextField(
//                               context,
//                               'Password',
//                               '********',
//                               isPassword: true,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 24),
//                       // Additional fields for desktop
//                       Row(
//                         children: [
//                           Expanded(
//                             child: _buildTextField(
//                               context,
//                               'Phone Number',
//                               userData['Telefono'] ?? '+1 234 567 890',
//                             ),
//                           ),
//                           const SizedBox(width: 24),
//                           Expanded(
//                             child: _buildTextField(
//                               context,
//                               'Location',
//                               userData['Location'] ?? 'New York, USA',
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 32),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           OutlinedButton(
//                             onPressed: () {},
//                             style: OutlinedButton.styleFrom(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 32,
//                                 vertical: 16,
//                               ),
//                             ),
//                             child: const Text('Cancel'),
//                           ),
//                           const SizedBox(width: 16),
//                           ElevatedButton(
//                             onPressed: () {},
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.indigo,
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 32,
//                                 vertical: 16,
//                               ),
//                             ),
//                             child: const Text(
//                               'Save Changes',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMobileLayout(BuildContext context, Map<String, dynamic> userData) {
//     return SingleChildScrollView(
//       child: Container(
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.95,
//         ),
//         margin: const EdgeInsets.symmetric(
//           vertical: 16,
//           horizontal: 12,
//         ),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 10,
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: [
//                   _buildTab('Edit Profile', isSelected: true),
//                   _buildTab('Preference'),
//                   _buildTab('Security'),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             Center(
//               child: Stack(
//                 children: [
//                   Container(
//                     width: 80,
//                     height: 80,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.photo_library_outlined,
//                       size: 32,
//                       color: Colors.grey,
//                     ),
//                   ),
//                   Positioned(
//                     right: 0,
//                     bottom: 0,
//                     child: Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: const BoxDecoration(
//                         color: Colors.indigo,
//                         shape: BoxShape.circle,
//                       ),
//                       child: const Icon(
//                         Icons.camera_alt,
//                         size: 16,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             _buildTextField(context, 'Your Name', userData['Nombre'] ?? 'Charlene Reed'),
//             _buildTextField(context, 'User Name', userData['Nombre'] ?? 'Charlene Reed'),
//             _buildTextField(context, 'Email', userData['email'] ?? 'user@gmail.com'),
//             _buildTextField(context, 'Password', '********', isPassword: true),
//             const SizedBox(height: 24),
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.indigo,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 32,
//                     vertical: 16,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//                 onPressed: () {},
//                 child: const Text(
//                   'Save Changes',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem(String text, {bool isSelected = false}) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(8),
//         color: isSelected ? Colors.indigo.withOpacity(0.1) : null,
//       ),
//       child: ListTile(
//         selected: isSelected,
//         selectedColor: Colors.indigo,
//         leading: Icon(
//           _getIconForNavItem(text),
//           color: isSelected ? Colors.indigo : Colors.grey,
//         ),
//         title: Text(
//           text,
//           style: TextStyle(
//             color: isSelected ? Colors.indigo : Colors.grey[700],
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//         onTap: () {
//           // Handle navigation
//         },
//       ),
//     );
//   }

//   IconData _getIconForNavItem(String text) {
//     switch (text) {
//       case 'Edit Profile':
//         return Icons.person_outline;
//       case 'Preference':
//         return Icons.settings_outlined;
//       case 'Security':
//         return Icons.security_outlined;
//       case 'Notifications':
//         return Icons.notifications_outlined;
//       case 'Connected Accounts':
//         return Icons.link_outlined;
//       default:
//         return Icons.circle_outlined;
//     }
//   }

//   Widget _buildTab(String text, {bool isSelected = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 24),
//       child: Column(
//         children: [
//           Text(
//             text,
//             style: TextStyle(
//               color: isSelected ? Colors.indigo : Colors.grey,
//               fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           const SizedBox(height: 4),
//           if (isSelected)
//             Container(
//               height: 2,
//               width: 80,
//               color: Colors.indigo,
//             ),
//         ],
//       ),
//     );
//   }

//   // Widget _buildTextField(BuildContext context, String label, String value,
//   //     {bool isPassword = false}) {
//   //   return Padding(
//   //     padding: const EdgeInsets.symmetric(vertical: 12),
//   //     child: Column(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         Text(
//   //           label,
//   //           style: const TextStyle(
//   //             fontSize: 14,
//   //             color: Colors.grey,
//   //           ),
//   //         ),
//   //         const SizedBox(height: 8),
//   //         TextField(
//   //           obscureText: isPassword,
//   //           controller: TextEditingController(text: value),
//   //           decoration: InputDecoration(
//   //             contentPadding:
//   //                 const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//   //             border: OutlineInputBorder(
//   //               borderRadius: BorderRadius.circular(8),
//   //               borderSide: BorderSide(color: Colors.grey[300]!),
//   //             ),
//   //             enabledBorder: OutlineInputBorder(
//   //               borderRadius: BorderRadius.circular(8),
//   //               borderSide: BorderSide(color: Colors.grey[300]!),
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

//     Widget _buildInputField(TextEditingController controller, String label,
//       {bool isEmail = false, required bool enabled}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: TextFormField(
//         enabled: enabled,
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.grey[300]!),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: Colors.grey[300]!),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: const BorderSide(color: Colors.indigo),
//           ),
//           filled: true,
//           fillColor: Colors.grey[50],
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Por favor ingrese $label';
//           }
//           if (isEmail &&
//               !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
//             return 'Por favor ingrese un email válido';
//           }
//           return null;
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({super.key});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController userNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController phoneController;
  late TextEditingController locationController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    userNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    phoneController = TextEditingController();
    locationController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 1024;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('No user data found'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        
        // Update controllers with user data
        nameController.text = userData['Nombre'] ?? '';
        userNameController.text = userData['Nombre'] ?? '';
        emailController.text = userData['email'] ?? '';
        passwordController.text = '********';
        phoneController.text = userData['Telefono'] ?? '';
        locationController.text = userData['Location'] ?? '';

        return Scaffold(
          body: isDesktop 
              ? _buildDesktopLayout(context)
              : _buildMobileLayout(context),
        );
      },
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left sidebar with navigation
            Card(
              elevation: 2,
              child: Container(
                width: 250,
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile photo section
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.photo_library_outlined,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Colors.indigo,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildNavItem('Edit Profile', isSelected: true),
                    _buildNavItem('Preference'),
                    _buildNavItem('Security'),
                    _buildNavItem('Notifications'),
                    _buildNavItem('Connected Accounts'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Main content area
            Expanded(
              child: Card(
                elevation: 2,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Profile',
                          style: GoogleFonts.roboto(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                nameController,
                                'Your Name',
                                enabled: true,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildInputField(
                                userNameController,
                                'User Name',
                                enabled: true,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                emailController,
                                'Email',
                                isEmail: true,
                                enabled: true,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildInputField(
                                passwordController,
                                'Password',
                                enabled: true,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: _buildInputField(
                                phoneController,
                                'Phone Number',
                                enabled: true,
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _buildInputField(
                                locationController,
                                'Location',
                                enabled: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  // Handle form submission
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab('Edit Profile', isSelected: true),
                    _buildTab('Preference'),
                    _buildTab('Security'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_library_outlined,
                        size: 32,
                        color: Colors.grey,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.indigo,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildInputField(nameController, 'Your Name', enabled: true),
              _buildInputField(userNameController, 'User Name', enabled: true),
              _buildInputField(emailController, 'Email', isEmail: true, enabled: true),
              _buildInputField(passwordController, 'Password', enabled: false),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Handle form submission
                    }
                  },
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String text, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Colors.indigo.withOpacity(0.1) : null,
      ),
      child: ListTile(
        selected: isSelected,
        selectedColor: Colors.indigo,
        leading: Icon(
          _getIconForNavItem(text),
          color: isSelected ? Colors.indigo : Colors.grey,
        ),
        title: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.indigo : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          // Handle navigation
        },
      ),
    );
  }

  IconData _getIconForNavItem(String text) {
    switch (text) {
      case 'Edit Profile':
        return Icons.person_outline;
      case 'Preference':
        return Icons.settings_outlined;
      case 'Security':
        return Icons.security_outlined;
      case 'Notifications':
        return Icons.notifications_outlined;
      case 'Connected Accounts':
        return Icons.link_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _buildTab(String text, {bool isSelected = false}) {
    return Padding(
      padding: const EdgeInsets.only(right: 24),
      child: Column(
        children: [
          Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.indigo : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              height: 2,
              width: 80,
              color: Colors.indigo,
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    TextEditingController controller, 
    String label,
    {bool isEmail = false, required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        enabled: enabled,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.indigo),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese $label';
          }
          if (isEmail &&
              !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Por favor ingrese un email válido';
          }
          return null;
        },
      ),
    );
  }
}