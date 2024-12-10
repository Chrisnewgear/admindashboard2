import 'package:flutter/material.dart';

class RoleColorUtil {
  /// Devuelve un Color basado en el rol proporcionado
  /// 
  /// [role] es el rol del usuario en minúsculas
  /// Retorna un Color predefinido según el rol
  static Color getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return const Color(0xFF1E293B); // Slate 800
      case 'supervisor':
        return const Color(0xFF059669); // Emerald 600
      case 'vendedor':
        return const Color(0xFF0284C7); // Sky 600
      default:
        return const Color(0xFF64748B); // Slate 500
    }
  }
}