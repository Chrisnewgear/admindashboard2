
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const rootRoute = "/";
const overviewPageDisplayName = "Overview";
const overviewPageRoute = "/overview";
const visitasPageDisplayName = "Visits";
const visitasPageRoute = "/drivers";
const clientsPageDisplayName = "Clients";
const clientsPageRoute = "/clients";
const authenticationPageDisplayName = "Log out";
const authenticationPageRoute = "/auth";
const registerPageDisplayName = "sign up";
const registerPageRoute = "/register";
const verifyEmailDisplayName = "verify mail";
const verifyEmailPageRoute = "/verify-email";
const myTeamWidgetDisplayName = "My team";
const myTeamWidgetPageRoute = "/myteam";
const roleManagementWidgetDisplayName = "Roles";
const roleManagementWidgetPageRoute = "/roles";
const profileDisplayName = "Profile";
const profilePageRoute = "/profile";
const pageNotFoundDisplayName = "Page not found";
const pageNotFoundPageRoute = "/404";

class MenuItem {
  final String name;
  final String route;
  final IconData? icon; // Agregado para el icono

  MenuItem(this.name, this.route, {this.icon});
}

Future<List<MenuItem>> getSideMenuItemRoutes() async {
  // Lista base de elementos del menú
  List<MenuItem> menuItems = [
    MenuItem(overviewPageDisplayName, overviewPageRoute),
    MenuItem(visitasPageDisplayName, visitasPageRoute),
    MenuItem(clientsPageDisplayName, clientsPageRoute),
    //MenuItem(profileDisplayName, profilePageRoute),
  ];

  try {
    // Obtener el usuario actual
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Verificar el rol en Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Si el usuario es Admin, agregar la opción de gestión de roles
        if (userData['Role'] == 'Admin') {
          menuItems.add(
            MenuItem(
                roleManagementWidgetDisplayName, roleManagementWidgetPageRoute),
          );
        }

        if(userData['Role'] == 'Supervisor'){
          menuItems.add(
            MenuItem(
                myTeamWidgetDisplayName, myTeamWidgetPageRoute),
          );
        }
      }
    }

    return menuItems;
  } catch (e) {
    return menuItems; // Retorna el menú base en caso de error
  }
}
