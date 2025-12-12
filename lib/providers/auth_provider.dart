import 'package:flutter/material.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isGuest = false;

  User? get user => _user;
  bool get isGuest => _isGuest;
  bool get isAdmin => _user?.role == 0;

  void login(User user) {
    _user = user;
    _isGuest = false;
    notifyListeners();
  }

  void loginAsGuest() {
    _user = null;
    _isGuest = true;
    notifyListeners();
  }

  void logout() {
    _user = null;
    _isGuest = false;
    notifyListeners();
  }
}
