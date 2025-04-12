
import 'package:flutter/material.dart';

class GuestProvider extends ChangeNotifier {
  String? _token;
  String? _email;

  String? get token => _token;
  String? get email => _email;

  void setGuestData({required String token, required String email}) {
    _token = token;
    _email = email;
    notifyListeners();
  }

  void clearGuest() {
    _token = null;
    _email = null;
    notifyListeners();
  }
}
