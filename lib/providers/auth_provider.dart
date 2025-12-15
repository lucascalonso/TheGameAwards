import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthProvider with ChangeNotifier {
  final UserRepository _repository = UserRepository();
  
  User? _user;
  bool _isGuest = false;

  User? get user => _user;
  bool get isGuest => _isGuest;

  // Verifica se o usuário logado é admin (role == 0)
  bool get isAdmin => _user != null && _user!.role == 0;

  // Login
  Future<bool> login(String email, String password) async {
    try {
      final user = await _repository.loginUser(email, password);
      if (user != null) {
        _user = user;
        _isGuest = false;
        notifyListeners(); // Avisa o main.dart para mudar a tela
        return true;
      }
    } catch (e) {
      print("Erro no login: $e");
    }
    return false;
  }

  // Cadastro
  Future<bool> register(String name, String email, String password, bool isAdmin) async {
    try {
      // Verifica se email existe
      final exists = await _repository.checkEmailExists(email);
      if (exists) return false;

      final newUser = User(
        name: name,
        email: email,
        password: password,
        role: isAdmin ? 0 : 1, // 0 = Admin, 1 = Comum
      );

      await _repository.registerUser(newUser);
      return true; // Cadastro com sucesso
    } catch (e) {
      print("Erro no cadastro: $e");
      return false;
    }
  }

  // Entrar como convidado (sem cadastro)
  void loginAsGuest() {
    _user = null;
    _isGuest = true;
    notifyListeners();
  }

  // Deslogar
  void logout() {
    _user = null;
    _isGuest = false;
    notifyListeners();
  }
}
