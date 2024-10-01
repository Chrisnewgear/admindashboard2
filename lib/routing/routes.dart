
const rootRoute = "/";

const overviewPageDisplayName = "Overview";
const overviewPageRoute = "/overview";

const driversPageDisplayName = "Drivers";
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

const pageNotFoundDisplayName = "Page not found";
const pageNotFoundPageRoute = "/404";

class MenuItem {
  final String name;
  final String route;

  MenuItem(this.name, this.route);
}

List<MenuItem> sideMenuItemRoutes = [
  MenuItem(overviewPageDisplayName, overviewPageRoute),
  MenuItem(driversPageDisplayName, driversPageRoute),
  MenuItem(clientsPageDisplayName, clientsPageRoute),
  MenuItem(roleManagementWidgetDisplayName, roleManagementWidgetPageRoute),
  //MenuItem(authenticationPageDisplayName, authenticationPageRoute),
  //MenuItem(registerPageDisplayName, registerPageRoute),
  //MenuItem(pageNotFoundDisplayName, pageNotFoundPageRoute),
];