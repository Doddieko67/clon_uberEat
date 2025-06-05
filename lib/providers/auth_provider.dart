import 'package:flutter/material.dart';

// Modelo de usuario para gestión de estado
class User {
  final String id;
  final String name;
  final String email;
  final String role; // 'customer', 'store', 'deliverer', 'admin'
  final String? photoUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
  });

  // Método para crear una copia del usuario con campos actualizados
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? photoUrl,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  // Convertir a Map para guardar en base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
    };
  }

  // Crear User desde Map de base de datos
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'customer',
      photoUrl: map['photoUrl'],
    );
  }
}

// Provider para gestión de autenticación
class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _user = User(
      id: 'dev-user-123',
      name: 'Usuario Demo',
      email: 'demo@campus.edu',
      role: 'costumer',
    );
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  // Setter para loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Setter para error messages
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Limpiar errores
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Método de login
  Future<bool> login(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      // Simular llamada a Firebase Auth
      await Future.delayed(Duration(seconds: 2));

      // Simulación de validación básica
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email y contraseña son requeridos');
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Email no válido');
      }

      if (password.length < 6) {
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      }

      // Simular login exitoso
      _user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _getNameFromEmail(email),
        email: email,
        role: _getRoleFromEmail(email), // Determinar rol basado en el email
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Método de registro
  Future<bool> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    try {
      _setLoading(true);
      _setError(null);

      // Simular llamada a Firebase Auth
      await Future.delayed(Duration(seconds: 2));

      // Validaciones básicas
      if (name.trim().isEmpty) {
        throw Exception('El nombre es requerido');
      }

      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email y contraseña son requeridos');
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Email no válido');
      }

      if (password.length < 6) {
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      }

      // Simular registro exitoso
      _user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
        email: email,
        role: role,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Método para restablecer contraseña
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _setError(null);

      // Simular llamada a Firebase Auth
      await Future.delayed(Duration(seconds: 1));

      if (email.isEmpty) {
        throw Exception('El email es requerido');
      }

      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        throw Exception('Email no válido');
      }

      // Simular envío exitoso
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Método para actualizar perfil
  Future<bool> updateProfile({String? name, String? photoUrl}) async {
    try {
      if (_user == null) return false;

      _setLoading(true);
      _setError(null);

      // Simular llamada a Firebase
      await Future.delayed(Duration(seconds: 1));

      _user = _user!.copyWith(
        name: name ?? _user!.name,
        photoUrl: photoUrl ?? _user!.photoUrl,
      );

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Método para verificar si hay una sesión activa (para splash screen)
  Future<void> checkAuthStatus() async {
    _setLoading(true);

    // Simular verificación de token guardado
    await Future.delayed(Duration(seconds: 2));

    // Aquí verificarías si hay un token válido guardado
    // Por ahora simulamos que no hay sesión activa
    _user = null;

    _setLoading(false);
  }

  // Métodos auxiliares para simulación
  String _getNameFromEmail(String email) {
    String username = email.split('@')[0];
    return username
        .replaceAll('.', ' ')
        .split(' ')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  String _getRoleFromEmail(String email) {
    // Simular determinación de rol basado en el dominio del email
    if (email.contains('admin')) return 'admin';
    if (email.contains('store') || email.contains('tienda')) return 'store';
    if (email.contains('delivery') || email.contains('repartidor'))
      return 'deliverer';
    return 'customer'; // Por defecto
  }

  // Método para obtener el nombre del rol en español
  String getRoleDisplayName(String role) {
    switch (role) {
      case 'customer':
        return 'Cliente';
      case 'store':
        return 'Tienda';
      case 'deliverer':
        return 'Repartidor';
      case 'admin':
        return 'Administrador';
      default:
        return 'Usuario';
    }
  }
}
