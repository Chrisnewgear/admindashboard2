import 'package:admindashboard/pages/clients/clients.dart';
import 'package:admindashboard/pages/drivers/drivers.dart';
import 'package:admindashboard/pages/overview/overview.dart';
//import 'package:admindashboard/pages/signup/signup.dart';
import 'package:admindashboard/routing/routes.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings){
  switch (settings.name){
      case overviewPageRoute:
        return _getPageRoute(const OverviewPage());
      case driversPageRoute:
        return _getPageRoute(const DriversPage());
      case clientsPageRoute:
        return _getPageRoute(const ClientsPage());
      // case registerPageRoute:
      //   return _getPageRoute(const RegisterPage());
      default:
        return _getPageRoute(const OverviewPage());
    }
}

PageRoute _getPageRoute(Widget child){
  return MaterialPageRoute(builder: (context) => child);
}