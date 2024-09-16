import 'package:admindashboard/constants/controllers.dart';
import 'package:admindashboard/routing/router.dart';
import 'package:admindashboard/routing/routes.dart';
import 'package:flutter/material.dart';

Navigator localNavigator() => Navigator(
      key: navigationController.navigatorKey,
      onGenerateRoute: generateRoute,
      initialRoute: overviewPageRoute,
    );
