import 'package:admindashboard/pages/404/error.dart';
import 'package:admindashboard/pages/clients/clients_page.dart';
import 'package:admindashboard/pages/myteam/myteam_page.dart';
import 'package:admindashboard/pages/visits/visits_page.dart';
import 'package:admindashboard/pages/overview/overview.dart';
import 'package:admindashboard/pages/profile/profile_page.dart';
import 'package:admindashboard/pages/roles/role_page.dart';
import 'package:admindashboard/routing/routes.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case overviewPageRoute:
      return _getPageRoute(const OverviewPage());
    case visitasPageRoute:
      return _getPageRoute(const VisitsManagementWidget());
    case clientsPageRoute:
      return _getPageRoute(const ClientsPage());
    case roleManagementWidgetPageRoute:
      return _getPageRoute(const RoleManagementWidget());
    case myTeamWidgetPageRoute:
      return _getPageRoute(const MyTeamPage());
    case profilePageRoute:
      return _getPageRoute(const ProfileWidget());
    default:
      return _getPageRoute(const PageNotFound());
  }
}
PageRoute _getPageRoute(Widget child){
  return MaterialPageRoute(builder: (context) => child);
}