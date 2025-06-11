// ===============================
// auth_state.dart - Estado inmutable con Freezed
// ===============================
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/user_model.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    User? user,
    @Default(false) bool isLoading,
    @Default(false) bool isNewUser,
    @Default(false) bool isInitialized,
    String? errorMessage,
  }) = _AuthState;

  // Computed properties
  const AuthState._();
  bool get isAuthenticated => user != null;
}