import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/helpers/responsiveness.dart';
import 'package:admindashboard/pages/authentication/authentication.dart';
import 'package:admindashboard/pages/profile/profile_page.dart';
import 'package:admindashboard/widgets/custom_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Importar FirebaseAuth

AppBar topNavigationBar(BuildContext context, GlobalKey<ScaffoldState> key) {
  return AppBar(
    leading: !ResponsiveWidget.isSmallScreen(context)
        ? Row(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 14),
                //margin: const EdgeInsets.only(right: 100),
                child: Image.asset("assets/icons/goSoftwareSolutions-01.png", width: 40),
              )
            ],
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
        Visibility(
          child: CustomText(
            text: "Dashboard",
            color: lightGrey,
            size: 20,
            weight: FontWeight.bold,
          ),
        ),
        Expanded(child: Container()),
        IconButton(
          icon: Icon(
            Icons.settings,
            color: dark.withOpacity(.7),
          ),
          onPressed: () {},
        ),
        Stack(children: [
          IconButton(
              icon: Icon(Icons.notifications, color: dark.withOpacity(.7)),
              onPressed: () {}),
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
                      border: Border.all(color: light, width: 2))))
        ]),
        Container(
          width: 1,
          height: 22,
          color: lightGrey,
        ),
        const SizedBox(
          width: 24,
        ),

        // FutureBuilder para mostrar el usuario actual
        FutureBuilder<User?>(
          future: FirebaseAuth.instance.authStateChanges().first,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Indicador de carga
            }
            if (snapshot.hasData && snapshot.data != null) {
              User user = snapshot.data!;
              return CustomText(
                text: user.displayName ?? user.email!,
                color: lightGrey,
              );
            } else {
              return const CustomText(
                text: 'Usuario',
                color: Color(0xFFA4A6B3),
              );
            }
          },
        ),

        const SizedBox(
          width: 16,
        ),

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
                // Acción a realizar al seleccionar una opción
                print("Seleccionaste: $value");
                // Aquí puedes navegar a una nueva pantalla o realizar otra acción
              },
              offset: const Offset(0, 40), // Desplaza el menú hacia abajo del icono
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'Perfil',
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => const ProfileWidget()),
                      );
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.person, color: Colors.black), // Icono para la opción
                        SizedBox(width: 8), // Espacio entre el icono y el texto
                        Text('Profile'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: Colors.black), // Icono para la opción
                        SizedBox(width: 8),
                        Text('Settings'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'Log Out',
                    onTap: () async {
                      // Delay the execution to avoid conflicts with PopupMenuItem
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        // Show confirmation dialog
                        bool? confirmLogout = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Confirm Logout'),
                              content: const Text('Are you sure you want to log out?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                TextButton(
                                  child: const Text('Log Out'),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            );
                          },
                        );

                        // If user confirms, proceed with logout
                        if (confirmLogout == true) {
                          // Cerrar sesión de Firebase
                          await FirebaseAuth.instance.signOut();

                          // Redirigir al usuario a la pantalla de autenticación
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const AuthenticationPage()),
                          );
                        }
                      });
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.logout, color: Colors.black), // Icono para la opción
                        SizedBox(width: 8),
                        Text('Log Out'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ),
        )
      ],
    ),
    iconTheme: IconThemeData(color: dark),
    backgroundColor: Colors.transparent,
  );
}
