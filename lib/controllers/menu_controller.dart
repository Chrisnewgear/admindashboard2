import 'package:admindashboard/constants/style.dart';
import 'package:admindashboard/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyMenuController extends GetxController{
  static MyMenuController instance = Get.find();
  var activeItem = "".obs;
  var hoverItem = "".obs;

  @override
  void onInit() {
    super.onInit();
    activeItem.value = overviewPageDisplayName;
    // Inicializamos también el hoverItem con el mismo valor
    hoverItem.value = overviewPageDisplayName;
  }

  changeActiveItemTo(String itemName) {
    activeItem.value = itemName;
    // Actualizamos también el hoverItem cuando cambia el item activo
    hoverItem.value = itemName;
  }

  onHover(String itemName) {
    if (!isActive(itemName)) {
      hoverItem.value = itemName;
    }
  }

  // Modificamos este método para mantener el hover en el item activo
  isHovering(String itemName) {
    if(isActive(itemName)) {
      return true; // Siempre retorna true para el item activo
    }
    return hoverItem.value == itemName;
  }

  isActive(String itemName) => activeItem.value == itemName;

  Widget returnIconFor(String itemName) {
    switch (itemName) {
      case overviewPageDisplayName:
        return _customIcon(Icons.trending_up, itemName);
      case driversPageDisplayName:
        return _customIcon(Icons.house_rounded, itemName);
      case clientsPageDisplayName:
        return _customIcon(Icons.people_alt_outlined, itemName);
      case roleManagementWidgetDisplayName:
        return _customIcon(Icons.assignment_ind, itemName);
      default:
        return _customIcon(Icons.exit_to_app, itemName);
    }
  }

  Widget _customIcon(IconData icon, String itemName) {
    if (isActive(itemName)) return Icon(icon, size: 22, color: dark);
    return Icon(icon, color: isHovering(itemName) ? dark : lightGrey);
  }
}