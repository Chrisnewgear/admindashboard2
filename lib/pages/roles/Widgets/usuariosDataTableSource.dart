import 'package:admindashboard/models/usuarios.dart';
import 'package:admindashboard/pages/roles/Widgets/role_color_util.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class UsuariosDataTableSource extends DataTableSource {
  final List<Usuario> usuarios;
  final Function(Usuario) deleteUsuario;
  final Function(BuildContext, dynamic) showUsuarioFormDialog;
  final BuildContext context;
  final bool addAvatar; // Nuevo parámetro

  UsuariosDataTableSource(
    this.usuarios,
    this.deleteUsuario,
    this.showUsuarioFormDialog,
    this.context, {
    this.addAvatar = false, // Por defecto, no se muestran los avatares
  });

  @override
  DataRow? getRow(int index) {
    final usuario = usuarios[index];
    return DataRow2(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Theme.of(context).colorScheme.primary.withOpacity(0.08);
          }
          if (states.contains(WidgetState.hovered)) {
            return Colors.grey.withOpacity(0.05);
          }
          if (index % 2 == 0) return Colors.grey.withOpacity(0.02);
          return null;
        },
      ),
      cells: [
        if (addAvatar) DataCell(_buildAvatarCell(usuario)), // Celda de avatar
        DataCell(Text('${usuario.nombres} ${usuario.apellidos}')),
        //DataCell(Text(usuario.apellidos)),
        DataCell(Text(usuario.email)),
        DataCell(Text(usuario.telefono)),
        DataCell(_buildRoleCell(usuario.role)),
        DataCell(_buildDateCell(usuario.fechaIngreso)),
        DataCell(_buildActionsCell(usuario)),
      ],
      onTap: () => showUsuarioFormDialog(context, usuario),
    );
  }

  Widget _buildAvatarCell(Usuario usuario) {
    final imageUrl =
        usuario.imageUrl; // Suponiendo que el usuario tiene este campo
    final name = usuario.nombres;

    return CircleAvatar(
      backgroundColor: imageUrl == null ? _getColorForLetter(name[0]) : null,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
      child: imageUrl == null
          ? Text(
              name[0].toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  Color _getColorForLetter(String letter) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.orange,
      Colors.orange,
      Colors.yellow.shade700,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
      Colors.deepPurple,
      Colors.deepOrange,
      Colors.deepPurpleAccent,
      Colors.indigo,
      Colors.indigoAccent,
      Colors.pinkAccent,
      Colors.purpleAccent,
      Colors.redAccent,
      Colors.teal,
      Colors.tealAccent,
      Colors.greenAccent,
      Colors.lightGreen,
      Colors.lightGreenAccent,
      Colors.amber,
      Colors.amberAccent,
      Colors.purple,
    ];
    final index = (letter.codeUnitAt(0) - 65) % colors.length;
    return colors[index];
  }

  Widget _buildRoleCell(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: RoleColorUtil.getRoleColor(role).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RoleColorUtil.getRoleColor(role).withOpacity(0.3),
        ),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: RoleColorUtil.getRoleColor(role),
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildDateCell(DateTime date) {
    return Text(
      DateFormat('dd/MM/yy').format(date),
      style: TextStyle(
        color: Colors.grey[800],
        fontSize: 13,
      ),
    );
  }

  Widget _buildActionsCell(Usuario usuario) {
    // Si el rol del usuario es 'Admin', mostrar solo el icono de editar
    if (usuario.role.toLowerCase() == 'admin') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit_outlined, color: Colors.blue[700]),
            onPressed: () => showUsuarioFormDialog(context, usuario),
          ),
        ],
      );
    }

    // Para roles diferentes de 'Admin', mostrar los iconos de editar y eliminar
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.edit_outlined, color: Colors.blue[700]),
          onPressed: () => showUsuarioFormDialog(context, usuario),
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _showDeleteConfirmationDialog(usuario),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(Usuario usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Usuario'),
          content: Text(
              '¿Está seguro de eliminar al usuario ${usuario.nombres} ${usuario.apellidos}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                deleteUsuario(usuario);
                Navigator.of(context).pop();
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => usuarios.length;

  @override
  int get selectedRowCount => 0;
}
