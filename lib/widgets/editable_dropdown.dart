// 📁 lib/widgets/editable_dropdown.dart

import 'package:flutter/material.dart';

class EditableDropdown extends StatelessWidget {
  final List<String> opciones;
  final String? valorSeleccionado;
  final void Function(String?) onChanged;

  const EditableDropdown({
    super.key,
    required this.opciones,
    required this.valorSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: valorSeleccionado,
      items: opciones
          .map((opcion) => DropdownMenuItem(
                value: opcion,
                child: Text(opcion),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: const InputDecoration(
        labelText: 'Seleccione una opción',
        border: OutlineInputBorder(),
      ),
    );
  }
}
