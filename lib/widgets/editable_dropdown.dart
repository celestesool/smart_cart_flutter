import 'package:flutter/material.dart';

class EditableDropdown extends StatefulWidget {
  final int initialValue;
  final Function(int) onChanged;

  const EditableDropdown({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<EditableDropdown> createState() => _EditableDropdownState();
}

class _EditableDropdownState extends State<EditableDropdown> {
  late TextEditingController _controller;
  late int _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
    _controller = TextEditingController(text: _selectedValue.toString());
  }

  void _onTextChanged(String value) {
    final number = int.tryParse(value);
    if (number != null && number > 0) {
      _selectedValue = number;
      widget.onChanged(_selectedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cantidad'),
            onChanged: _onTextChanged,
          ),
        ),
        const SizedBox(width: 10),
        DropdownButton<int>(
          value: _selectedValue <= 10 ? _selectedValue : null,
          items: List.generate(10, (i) => i + 1)
              .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.toString()),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedValue = value;
                _controller.text = value.toString();
              });
              widget.onChanged(value);
            }
          },
        ),
      ],
    );
  }
}
