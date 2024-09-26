import 'package:admindashboard/constants/style.dart';
import 'package:flutter/material.dart';

class RoleManagementWidget extends StatefulWidget {
  const RoleManagementWidget({super.key});

  @override
  _RoleManagementWidgetState createState() => _RoleManagementWidgetState();
}

class _RoleManagementWidgetState extends State<RoleManagementWidget>
    with SingleTickerProviderStateMixin {
  List<String> roles = ['Vendedor', 'Supervisor'];
  String selectedRole = 'Vendedor';
  final TextEditingController _controller = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Colores

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administrar Roles', style: TextStyle(color: light)),
        backgroundColor: active,
        iconTheme: IconThemeData(
            color: light), // Cambiado el color de la flecha hacia atrás a light
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona un rol:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: light,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDropdown(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _buildTextField(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 200, // Ajusta este valor según tus necesidades
                  child: _buildSaveButton(),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _buildRoleList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: light,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: lightGrey, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedRole,
            isExpanded: true,
            onChanged: (String? newRole) {
              setState(() {
                selectedRole = newRole!;
              });
            },
            items: roles.map<DropdownMenuItem<String>>((String role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Text(role),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Nombre del usuario',
        filled: true,
        fillColor: light,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: lightGrey),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: () {
        print('Usuario: ${_controller.text}, Rol: $selectedRole');
        _controller.clear();
      },
      icon: Icon(Icons.save, color: light),
      label: Text('Guardar', style: TextStyle(color: light)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: active,
      ),
    );
  }

  Widget _buildRoleList() {
    return ListView.builder(
      itemCount: roles.length,
      itemBuilder: (context, index) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 6),
          color: light,
          child: ListTile(
            leading: Icon(Icons.person, color: active),
            title: Text(roles[index], style: TextStyle(color: dark)),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                setState(() {
                  roles.removeAt(index);
                });
              },
            ),
          ),
        );
      },
    );
  }
}
