import 'package:admindashboard/constants/controllers.dart';
import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/helpers/responsiveness.dart';
import 'package:admindashboard/pages/authentication/authentication.dart';
import 'package:admindashboard/routing/routes.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Importar FirebaseAuth

AppBar topNavigationBar(BuildContext context, GlobalKey<ScaffoldState> key) {
  return AppBar(
    leading: !ResponsiveWidget.isSmallScreen(context)
        ? Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Image.asset(
              "assets/icons/goSoftwareSolutions-01.png",
              width: 40,
            ),
          )
        : IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              key.currentState!.openDrawer();
            },
          ),
    elevation: 0,
    title: Row(
      children: [
        if (!ResponsiveWidget.isSmallScreen(context))
          Visibility(
            child: CustomText(
              text: "Dashboard",
              color: lightGrey,
              size: 20,
              weight: FontWeight.bold,
            ),
          ),
        Expanded(child: Container()),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!ResponsiveWidget.isSmallScreen(context)) ...[
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: dark.withOpacity(.7),
                ),
                onPressed: () {},
              ),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications,
                      color: dark.withOpacity(.7),
                    ),
                    onPressed: () {},
                  ),
                  Positioned(
                    top: 7,
                    right: 7,
                    child: Container(
                      width: 12,
                      height: 12,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: active,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: light, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 22,
                color: lightGrey,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return FutureBuilder<User?>(
                    future: FirebaseAuth.instance.authStateChanges().first,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        );
                      }
                      if (snapshot.hasData && snapshot.data != null) {
                        User user = snapshot.data!;
                        // Calculamos el ancho disponible para el texto
                        final textSpan = TextSpan(
                          text: user.email,
                          style: const TextStyle(fontSize: 14),
                        );
                        final textPainter = TextPainter(
                          text: textSpan,
                          textDirection: TextDirection.ltr,
                        )..layout();

                        // Si el texto es más ancho que el espacio disponible, mostramos solo el nombre
                        final availableWidth =
                            MediaQuery.of(context).size.width -
                                600; // Ajusta este valor según necesites
                        final shouldTruncate =
                            textPainter.width > availableWidth;

                        return SizedBox(
                          width: shouldTruncate ? null : null,
                          child: CustomText(
                            text: shouldTruncate
                                ? (user.displayName?.split(' ').first ??
                                    'Usuario')
                                : (user.displayName ?? user.email!),
                            color: lightGrey,
                          ),
                        );
                      }
                      return const CustomText(
                        text: 'Usuario',
                        color: Color(0xFFA4A6B3),
                      );
                    },
                  );
                },
              ),
            ],
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                margin: const EdgeInsets.all(2),
                child: PopupMenuButton<String>(
                  icon: CircleAvatar(
                    backgroundColor: light,
                    child: Icon(
                      Icons.person_2_outlined,
                      color: dark,
                    ),
                  ),
                  onSelected: (String value) {
                    if (kDebugMode) {
                      print("Seleccionaste: $value");
                    }
                  },
                  offset: const Offset(0, 40),
                  itemBuilder: (BuildContext context) {
                    return <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'Perfil',
                        onTap: () {
                          // Navigator.of(context).pushReplacement(
                          //   MaterialPageRoute(
                          //       builder: (context) => const ProfileWidget()),
                          // );
                          navigationController.navigateTo(profilePageRoute);
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.person,
                                color: Colors.black), // Icono para la opción
                            SizedBox(
                                width: 8), // Espacio entre el icono y el texto
                            Text('Profile'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Settings',
                        child: Row(
                          children: [
                            Icon(Icons.settings,
                                color: Colors.black), // Icono para la opción
                            SizedBox(width: 8),
                            Text('Settings'),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'Log Out',
                        onTap: () async {
                          WidgetsBinding.instance
                              .addPostFrameCallback((_) async {
                            bool? confirmLogout = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    width: 320,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'Cerrar Sesión',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              icon: const Icon(Icons.close),
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Está seguro de cerrar la sesión?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(false),
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                              ),
                                              child: const Text(
                                                'Cancelar',
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context)
                                                      .pop(true),
                                              style: TextButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                              ),
                                              child: const Text(
                                                'Cerrar sesión',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );

                            if (confirmLogout == true) {
                              await FirebaseAuth.instance.signOut();
                              menuController.changeActiveItemTo(overviewPageDisplayName);
                              if (context.mounted) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AuthenticationPage()),
                                );
                              }
                            }
                          });
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.logout, color: Colors.black),
                            SizedBox(width: 8),
                            Text('Log Out'),
                          ],
                        ),
                      )

                      // PopupMenuItem<String>(
                      //   value: 'Log Out',
                      //   onTap: () async {
                      //     WidgetsBinding.instance
                      //         .addPostFrameCallback((_) async {
                      //       bool? confirmLogout = await showDialog<bool>(
                      //         context: context,
                      //         builder: (BuildContext context) {
                      //           return Dialog(
                      //             shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(16),
                      //             ),
                      //             child: Container(
                      //               padding: const EdgeInsets.all(20),
                      //               width: 320,
                      //               child: Column(
                      //                 mainAxisSize: MainAxisSize.min,
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   Row(
                      //                     mainAxisAlignment:
                      //                         MainAxisAlignment.spaceBetween,
                      //                     children: [
                      //                       const Text(
                      //                         'Cerrar Sesión',
                      //                         style: TextStyle(
                      //                           fontSize: 18,
                      //                           fontWeight: FontWeight.bold,
                      //                         ),
                      //                       ),
                      //                       IconButton(
                      //                         padding: EdgeInsets.zero,
                      //                         constraints:
                      //                             const BoxConstraints(),
                      //                         icon: const Icon(Icons.close),
                      //                         onPressed: () =>
                      //                             Navigator.of(context)
                      //                                 .pop(false),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                   const SizedBox(height: 16),
                      //                   const Text(
                      //                     'Está seguro de cerrar la sesión?',
                      //                     style: TextStyle(
                      //                       fontSize: 14,
                      //                       color: Colors.black87,
                      //                     ),
                      //                   ),
                      //                   const SizedBox(height: 24),
                      //                   Row(
                      //                     mainAxisAlignment:
                      //                         MainAxisAlignment.end,
                      //                     children: [
                      //                       TextButton(
                      //                         onPressed: () =>
                      //                             Navigator.of(context)
                      //                                 .pop(false),
                      //                         style: TextButton.styleFrom(
                      //                           padding:
                      //                               const EdgeInsets.symmetric(
                      //                             horizontal: 16,
                      //                             vertical: 8,
                      //                           ),
                      //                         ),
                      //                         child: const Text(
                      //                           'Cancelar',
                      //                           style: TextStyle(
                      //                             color: Colors.black54,
                      //                             fontSize: 14,
                      //                           ),
                      //                         ),
                      //                       ),
                      //                       const SizedBox(width: 8),
                      //                       TextButton(
                      //                         onPressed: () =>
                      //                             Navigator.of(context)
                      //                                 .pop(true),
                      //                         style: TextButton.styleFrom(
                      //                           backgroundColor: Colors.red,
                      //                           padding:
                      //                               const EdgeInsets.symmetric(
                      //                             horizontal: 16,
                      //                             vertical: 8,
                      //                           ),
                      //                         ),
                      //                         child: const Text(
                      //                           'Cerrar sesión',
                      //                           style: TextStyle(
                      //                             color: Colors.white,
                      //                             fontSize: 14,
                      //                           ),
                      //                         ),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           );
                      //         },
                      //       );

                      //       if (confirmLogout == true) {
                      //         // Restablecer la opción de menú a 'overview'
                      //         navigationController.navigateTo(overviewPageRoute);

                      //         await FirebaseAuth.instance.signOut();
                      //         Navigator.of(context).pushReplacement(
                      //           MaterialPageRoute(
                      //               builder: (context) =>
                      //                   const AuthenticationPage()),
                      //         );

                      //         //const HorizontalMenuItem(itemName: overviewPageDisplayName );

                      //         MenuItem(overviewPageDisplayName, overviewPageRoute);
                      //       }
                      //     });
                      //   },
                      //   child: const Row(
                      //     children: [
                      //       Icon(Icons.logout, color: Colors.black),
                      //       SizedBox(width: 8),
                      //       Text('Log Out'),
                      //     ],
                      //   ),
                      // ),
                    ];
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    ),
    iconTheme: IconThemeData(color: dark),
    backgroundColor: Colors.transparent,
  );
}
