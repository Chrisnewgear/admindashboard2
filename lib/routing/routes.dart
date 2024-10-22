// const rootRoute = "/";

// const overviewPageDisplayName = "Overview";
// const overviewPageRoute = "/overview";

// const driversPageDisplayName = "Visits";
// const driversPageRoute = "/drivers";

// const clientsPageDisplayName = "Clients";
// const clientsPageRoute = "/clients";

// const authenticationPageDisplayName = "Log out";
// const authenticationPageRoute = "/auth";

// const registerPageDisplayName = "sign up";
// const registerPageRoute = "/register";

// const verifyEmailDisplayName = "verify mail";
// const verifyEmailPageRoute = "/verify-email";

// const roleManagementWidgetDisplayName = "Roles";
// const roleManagementWidgetPageRoute = "/roles";

// const profileDisplayName = "Profile";
// const profilePageRoute = "/profile";

// const pageNotFoundDisplayName = "Page not found";
// const pageNotFoundPageRoute = "/404";

// class MenuItem {
//   final String name;
//   final String route;

//   MenuItem(this.name, this.route);
// }

// List<MenuItem> sideMenuItemRoutes = [
//   MenuItem(overviewPageDisplayName, overviewPageRoute),
//   MenuItem(driversPageDisplayName, driversPageRoute),
//   MenuItem(clientsPageDisplayName, clientsPageRoute),
//   MenuItem(roleManagementWidgetDisplayName, roleManagementWidgetPageRoute),
//   //MenuItem(authenticationPageDisplayName, authenticationPageRoute),
//   //MenuItem(registerPageDisplayName, registerPageRoute),
//   //MenuItem(pageNotFoundDisplayName, pageNotFoundPageRoute),
// ];

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const rootRoute = "/";
const overviewPageDisplayName = "Overview";
const overviewPageRoute = "/overview";
const driversPageDisplayName = "Visits";
const driversPageRoute = "/drivers";
const clientsPageDisplayName = "Clients";
const clientsPageRoute = "/clients";
const authenticationPageDisplayName = "Log out";
const authenticationPageRoute = "/auth";
const registerPageDisplayName = "sign up";
const registerPageRoute = "/register";
const verifyEmailDisplayName = "verify mail";
const verifyEmailPageRoute = "/verify-email";
const roleManagementWidgetDisplayName = "Roles";
const roleManagementWidgetPageRoute = "/roles";
const profileDisplayName = "Profile";
const profilePageRoute = "/profile";
const pageNotFoundDisplayName = "Page not found";
const pageNotFoundPageRoute = "/404";

class MenuItem {
  final String name;
  final String route;

  MenuItem(this.name, this.route);
}

Future<List<MenuItem>> getSideMenuItemRoutes() async {
  // Lista base de elementos del menú
  List<MenuItem> menuItems = [
    MenuItem(overviewPageDisplayName, overviewPageRoute),
    MenuItem(driversPageDisplayName, driversPageRoute),
    MenuItem(clientsPageDisplayName, clientsPageRoute),
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
      }
    }

    return menuItems;
  } catch (e) {
    print('Error al verificar el rol del usuario: $e');
    return menuItems; // Retorna el menú base en caso de error
  }
}
