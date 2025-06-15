// ===============================
// 3. AUTH NOTIFIER - Lógica de autenticación
// ===============================
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../repositories/firebase_auth_repository.dart';
import '../models/user_model.dart';
import 'auth_state.dart';

// Provider para FirebaseAuthRepository
final firebaseAuthRepositoryProvider = Provider<FirebaseAuthRepository>((ref) {
  return FirebaseAuthRepository();
});

// Provider principal para AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(firebaseAuthRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthRepository _firebaseAuthRepository;

  AuthNotifier(this._firebaseAuthRepository) : super(const AuthState()) {
    // Escuchar cambios de estado de autenticación
    _firebaseAuthRepository.authStateChanges.listen((fb_auth.User? firebaseUser) {
      _handleAuthStateChange(firebaseUser);
    });
  }

  // Manejo centralizado de cambios de estado de autenticación
  void _handleAuthStateChange(fb_auth.User? firebaseUser) async {
    if (firebaseUser != null) {
      // Si no hay usuario local o es diferente al de Firebase
      if (state.user == null || state.user!.id != firebaseUser.uid) {
        await _loadUserDataFromFirestore(firebaseUser.uid);
        
        // Si no se pudo cargar de Firestore, crear usuario básico
        if (state.user == null) {
          final newUser = User(
            id: firebaseUser.uid,
            name: firebaseUser.displayName ?? 'Usuario Firebase',
            phone: firebaseUser.phoneNumber,
            boletaNumber: _extractBoletaFromEmail(firebaseUser.email ?? ''),
            role: UserRole.customer,
            status: UserStatus.active,
            lastActive: DateTime.now(),
          );
          
          state = state.copyWith(user: newUser);
        }
      }
    } else {
      // Usuario deslogueado
      if (state.user != null) {
        state = state.copyWith(
          user: null,
          isNewUser: false,
        );
      }
    }
    
    if (!state.isInitialized) {
      state = state.copyWith(isInitialized: true);
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
    return '$boletaNumber@ciberecus.mx';
  }

  // Setter para loading state
  void _setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  // Setter para error messages
  void _setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  // Limpiar errores
  void clearError() {
    state = state.copyWith(errorMessage: null);
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
        state = state.copyWith(isNewUser: false);
      } on fb_auth.FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          // Usuario en campus DB pero no en Firebase, registrarlo
          await _firebaseAuthRepository.registerWithEmailAndPassword(email, password);
          state = state.copyWith(isNewUser: true);
        } else {
          throw Exception('Error de autenticación de Firebase: ${e.message}');
        }
      }

      // 5. Crear objeto User completo con datos del campus
      final fb_auth.User? firebaseUser = _firebaseAuthRepository.getCurrentUser();
      if (firebaseUser != null) {
        // Obtener el rol del campus DB
        final userRole = _parseUserRole(campusUser['role'] ?? 'customer');
        final userName = campusUser['name'] ?? firebaseUser.displayName ?? _getNameFromBoletaNumber(boletaNumber);
        
        final newUser = User(
          id: firebaseUser.uid,
          name: userName,
          phone: firebaseUser.phoneNumber,
          boletaNumber: boletaNumber,
          role: userRole,
          status: UserStatus.active,
          lastActive: DateTime.now(),
        );

        state = state.copyWith(user: newUser);

        // Si es usuario nuevo, actualizar perfil en Firebase y guardar en Firestore
        if (state.isNewUser) {
          await _updateFirebaseProfile();
          await _saveUserDataToFirestore();
        } else {
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
      if (firebaseUser != null && state.user != null) {
        await firebaseUser.updateDisplayName(state.user!.name);
      }
    } catch (e) {
      print('Error updating Firebase profile: $e');
    }
  }

  // Guardar datos adicionales del usuario en Firestore
  Future<void> _saveUserDataToFirestore() async {
    if (state.user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(state.user!.id)
          .set(
            state.user!.toMap(),
            SetOptions(merge: true),
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
          final user = User.fromMap(data);
          state = state.copyWith(user: user);
        }
      }
    } catch (e) {
      print('Error loading user data from Firestore: $e');
    }
  }

  // Método para completar el registro
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

      if (state.user != null) {
        final updatedUser = state.user!.copyWith(
          name: name,
          phone: phone,
        );
        state = state.copyWith(user: updatedUser);
      }

      await _saveUserDataToFirestore();
      state = state.copyWith(isNewUser: false);

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
      state = const AuthState(); // Reset completo del estado
    } catch (e) {
      _setError('Error al cerrar sesión: $e');
    }
  }

  // Método para actualizar perfil
  Future<bool> updateProfile({String? name, String? phone}) async {
    try {
      if (state.user == null) return false;

      _setLoading(true);
      _setError(null);

      // Actualizar en Firebase
      final fb_auth.User? firebaseUser = _firebaseAuthRepository.getCurrentUser();
      if (firebaseUser != null && name != null) {
        await firebaseUser.updateDisplayName(name);
      }

      final updatedUser = state.user!.copyWith(
        name: name,
        phone: phone,
      );
      state = state.copyWith(user: updatedUser);

      await _saveUserDataToFirestore();

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Método para verificar si hay una sesión activa
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    
    await Future.delayed(Duration(milliseconds: 500));
    
    final fb_auth.User? firebaseUser = _firebaseAuthRepository.getCurrentUser();
    if (firebaseUser != null) {
      await _loadUserDataFromFirestore(firebaseUser.uid);
    }
    
    _setLoading(false);
  }

  // Generar nombre a partir del número de boleta
  String _getNameFromBoletaNumber(String boletaNumber) {
    return 'Usuario $boletaNumber';
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
    if (state.user == null) return 'Usuario';
    return getRoleDisplayName(state.user!.role.toString().split('.').last);
  }

  // Método para verificar permisos
  bool hasPermission(String permission) {
    if (state.user == null) return false;
    
    switch (state.user!.role) {
      case UserRole.admin:
        return true;
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

  // Método para convertir string de rol a UserRole enum
  UserRole _parseUserRole(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'store':
        return UserRole.store;
      case 'deliverer':
        return UserRole.deliverer;
      case 'admin':
        return UserRole.admin;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  // Método para cambiar el rol del usuario
  Future<void> updateUserRole(UserRole newRole) async {
    try {
      _setLoading(true);
      _setError(null);

      if (state.user == null) {
        throw Exception('No hay usuario autenticado');
      }

      // Actualizar el rol del usuario
      final updatedUser = state.user!.copyWith(role: newRole);
      state = state.copyWith(user: updatedUser);

      // Guardar en Firestore
      await _saveUserDataToFirestore();

      _setLoading(false);
    } catch (e) {
      _setError('Error al cambiar rol: ${e.toString()}');
      _setLoading(false);
      rethrow;
    }
  }
}