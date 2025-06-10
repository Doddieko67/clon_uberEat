import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:clonubereat/models/user_model.dart';

import '../repositories/firebase_auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

// Provider para gestión de autenticación
class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;


  bool _isNewUser = false;
  bool _isInitialized = false;

  bool get isNewUser => _isNewUser;
  bool get isInitialized => _isInitialized;

  late final FirebaseAuthRepository _firebaseAuthRepository;

  AuthProvider({FirebaseAuthRepository? firebaseAuthRepository}) {
    _firebaseAuthRepository = firebaseAuthRepository ?? FirebaseAuthRepository();
    _user = null;

    // Listen to Firebase auth state changes to keep _user updated
    _firebaseAuthRepository.authStateChanges.listen((fb_auth.User? firebaseUser) {
      _handleAuthStateChange(firebaseUser);
    });
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  String? get errorMessage => _errorMessage;

  // Manejo centralizado de cambios de estado de autenticación
  void _handleAuthStateChange(fb_auth.User? firebaseUser) async {
    // Solo actualizar si hay un cambio real en el usuario
    if (firebaseUser != null) {
      // Si no hay usuario local o es diferente al de Firebase
      if (_user == null || _user!.id != firebaseUser.uid) {
        // Si no hay usuario local o es diferente al de Firebase, intentar cargar de Firestore
        // Esto es crucial para mantener el estado del usuario persistente
        if (_user == null || _user!.id != firebaseUser.uid) {
          await _loadUserDataFromFirestore(firebaseUser.uid);
          _user ??= User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Usuario Firebase',
            phone: firebaseUser.phoneNumber,
            boletaNumber: _extractBoletaFromEmail(firebaseUser.email ?? ''),
            role: UserRole.customer,
            status: UserStatus.active,
            lastActive: DateTime.now(),
          );
          notifyListeners();
        }
      }
    } else {
      // Usuario deslogueado
      if (_user != null) {
        _user = null;
        _isNewUser = false;
        notifyListeners();
      }
    }
    
    if (!_isInitialized) {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Extraer número de boleta del email
  String _extractBoletaFromEmail(String email) {
    if (email.contains('@')) {
      return email.split('@')[0];
    }
    return email;
  }

  // Convertir número de boleta a email
  String _boletaToEmail(String boletaNumber) {
    if (boletaNumber.contains('@')) {
      return boletaNumber;
    }
    // Asumir dominio del campus - ajustar según tu caso
    return '$boletaNumber@ciberecus.mx';
  }

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
  Future<bool> login(String boletaNumber, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      // 1. Cargar la base de datos simulada del campus
      final campusDb = await _loadCampusDb();

      // 2. Buscar el usuario en la base de datos del campus
      final campusUser = campusDb.firstWhere(
        (user) => user['boletaNumber'] == boletaNumber && user['password'] == password,
        orElse: () => {},
      );

      if (campusUser.isEmpty) {
        throw Exception('Credenciales inválidas. Número de boleta o contraseña incorrectos.');
      }

      // 3. Convertir boletaNumber a email para Firebase
      final email = _boletaToEmail(boletaNumber);

      // 4. Intentar login en Firebase
      try {
        await _firebaseAuthRepository.signInWithEmailAndPassword(email, password);
        _isNewUser = false; // Usuario existe en Firebase
      } on fb_auth.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // Usuario en campus DB pero no en Firebase, registrarlo
          await _firebaseAuthRepository.registerWithEmailAndPassword(email, password);
          _isNewUser = true; // Usuario nuevo en Firebase
        } else {
          // Otros errores de Firebase auth
          throw Exception('Error de autenticación de Firebase: ${e.message}');
        }
      }

      // 5. Crear objeto User completo con datos del campus
      final fb_auth.User? firebaseUser = _firebaseAuthRepository.getCurrentUser();
      if (firebaseUser != null) {
        _user = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? _getNameFromBoletaNumber(boletaNumber),
          phone: firebaseUser.phoneNumber,
          boletaNumber: boletaNumber,
          role: UserRole.customer,
          status: UserStatus.active,
          lastActive: DateTime.now(),
        );



        // Si es usuario nuevo, actualizar perfil en Firebase y guardar en Firestore
        if (_isNewUser) {
          await _updateFirebaseProfile(); // Actualiza display name en Firebase Auth
          await _saveUserDataToFirestore(); // Guarda todos los datos en Firestore
        } else {
          // Si el usuario ya existe, asegúrate de que los datos de Firestore estén cargados
          await _loadUserDataFromFirestore(firebaseUser.uid);
        }
      } else {
        throw Exception('Error: No se pudo obtener el usuario de Firebase después de la autenticación.');
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Actualizar perfil en Firebase
  Future<void> _updateFirebaseProfile() async {
    try {
      final fb_auth.User? firebaseUser = _firebaseAuthRepository.getCurrentUser();
      if (firebaseUser != null && _user != null) {
        await firebaseUser.updateDisplayName(_user!.name);
        // Para el teléfono, idealmente guardar en Firestore
        // await _saveUserDataToFirestore();
      }
    } catch (e) {
      // Log error but don't fail the login process
      print('Error updating Firebase profile: $e');
    }
  }

  // Guardar datos adicionales del usuario en Firestore
  Future<void> _saveUserDataToFirestore() async {
    if (_user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.id)
          .set(
            _user!.toMap(), // Usar el método toMap del modelo User
            SetOptions(merge: true), // Fusionar datos existentes
          );
    }
  }

  // Cargar datos adicionales del usuario desde Firestore
  Future<void> _loadUserDataFromFirestore(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          _user = User.fromMap(data); // Usar el método fromMap del modelo User
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error loading user data from Firestore: $e');
    }
  }
  // }

  // Método para completar el registro (añadir información adicional)
  Future<bool> completeRegistration(String name, String phone) async {
    try {
      _setLoading(true);
      _setError(null);

      final fb_auth.User? firebaseUser = _firebaseAuthRepository.getCurrentUser();
      if (firebaseUser == null) {
        throw Exception('No hay usuario autenticado para completar el registro.');
      }

      // Actualizar perfil en Firebase
      await firebaseUser.updateDisplayName(name);

          if (_user != null) {
      // La forma ideal es usando un método `copyWith` en tu modelo User
      _user = _user!.copyWith(
        name: name, // Actualiza el nombre
        phone: phone, // Actualiza el teléfono
      );
      // Si tu modelo no tiene `copyWith`, puedes hacerlo manualmente:
      // _user!.name = name;
      // _user!.phone = phone;
    } else {
        // Si _user es nulo, quizás necesites crearlo por primera vez aquí
        // Esto depende de cómo gestiones tu estado.
        // Ejemplo: _user = User(id: firebaseUser.uid, email: firebaseUser.email, name: name, phone: phone);
    }

      await _saveUserDataToFirestore();

      _isNewUser = false; // Registro completado

      _setLoading(false);
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _setError('Error al completar el registro en Firebase: ${e.message}');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('Ocurrió un error inesperado al completar el registro: $e');
      _setLoading(false);
      return false;
    }
  }

  // Método para cerrar sesión
  Future<void> logout() async {
    try {
      await _firebaseAuthRepository.signOut();
      _user = null;
      _isNewUser = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError('Error al cerrar sesión: $e');
    }
  }

  // Método para actualizar perfil
  Future<bool> updateProfile({String? name, String? phone}) async {
    try {
      if (_user == null) return false;

      _setLoading(true);
      _setError(null);

      // Actualizar en Firebase
      final fb_auth.User? firebaseUser = _firebaseAuthRepository.getCurrentUser();
      if (firebaseUser != null) {
        if (name != null) {
          await firebaseUser.updateDisplayName(name);
        }
      }
      _user = _user!.copyWith(
      name: name,
      phone: phone
    );

      await _saveUserDataToFirestore();

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
    
    // Esperar a que Firebase se inicialice y el listener se ejecute
    await Future.delayed(Duration(milliseconds: 500));
    
    // Si hay usuario de Firebase pero no datos completos, intentar cargar desde Firestore
    final fb_auth.User? firebaseUser = _firebaseAuthRepository.getCurrentUser();
    if (firebaseUser != null) {
      await _loadUserDataFromFirestore(firebaseUser.uid);
    }
    
    _setLoading(false);
  }

  // Métodos auxiliares para parsing




  // Generar nombre a partir del número de boleta
  String _getNameFromBoletaNumber(String boletaNumber) {
    return 'Usuario $boletaNumber';
  }

  // Método auxiliar heredado (mejorado)
  String _getNameFromEmail(String email) {
    if (email.isEmpty) return 'Usuario';
    
    String username = email.split('@')[0];
    return username
        .replaceAll('.', ' ')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty ? '' : 
             word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  // Método para cargar la base de datos simulada
  Future<List<Map<String, dynamic>>> _loadCampusDb() async {
    try {
      final String response = await rootBundle.loadString('assets/campus_db.json');
      final List<dynamic> data = json.decode(response);
      return data.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error al cargar la base de datos del campus: $e');
    }
  }

  // Método para obtener el nombre del rol en español
  String getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
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

  // Método para obtener el nombre del rol del usuario actual
  String getCurrentUserRoleDisplayName() {
    if (_user == null) return 'Usuario';
    return getRoleDisplayName(_user!.role.toString().split('.').last);
  }

  // Método para verificar permisos
  bool hasPermission(String permission) {
    if (_user == null) return false;
    
    switch (_user!.role) {
      case UserRole.admin:
        return true; // Admin tiene todos los permisos
      case UserRole.store:
        return ['manage_menu', 'view_orders', 'update_order_status'].contains(permission);
      case UserRole.deliverer:
        return ['view_deliveries', 'update_delivery_status'].contains(permission);
      case UserRole.customer:
        return ['place_order', 'view_order_history'].contains(permission);
      default:
        return false;
    }
  }
}