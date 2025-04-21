// 📁 lib/providers/guest_provider.dart

import 'package:flutter/material.dart';

class GuestProvider extends ChangeNotifier {
  String _nombre = "Usuario";

  String get nombre => _nombre;

  void cambiarNombre(String nuevoNombre) {
    _nombre = nuevoNombre;
    notifyListeners();
  }
}
