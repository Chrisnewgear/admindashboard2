import 'package:admindashboard/pages/clients/clients.dart';
import 'package:admindashboard/pages/drivers/drivers.dart';
import 'package:admindashboard/pages/overview/overview.dart';
import 'package:admindashboard/routing/routes.dart';
import 'package:flutter/material.dart';

Route<dynamic> generateRoute(RouteSettings settings){
  switch (settings.name){
      case OverViewPageRoute:
        return _getPageRoute(const OverviewPage());
      case DriversPagePageRoute:
        return _getPageRoute(const DriversPage());
      case ClientsPageRoute:
        return _getPageRoute(const ClientsPage());
      default:
        return _getPageRoute(const OverviewPage());
    }
}

PageRoute _getPageRoute(Widget child){
  return MaterialPageRoute(builder: (context) => child);
}