import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends ConsumerStatefulWidget {  // CAMBIO
  const LoginScreen({Key? key}) : super(key: key);  // CAMBIO
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();  // CAMBIO
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _boletaNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // CAMBIO: usar WidgetsBinding con ref
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).clearError();
    });
  }

  @override
  void dispose() {
    _boletaNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      // CAMBIO: usar ref.read en lugar de Provider.of
      final authNotifier = ref.read(authNotifierProvider.notifier);

      final success = await authNotifier.login(
        _boletaNumberController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // CAMBIO: usar ref.read para obtener estado
        final authState = ref.read(authNotifierProvider);
        
        if (authState.isNewUser) {
          context.pushReplacement('/register');
        } else {
          final role = authState.user!.role;
          _redirectBasedOnRole(role);
        }
      } else if (mounted) {
        // CAMBIO: usar ref.read para obtener error
        final errorMessage = ref.read(authNotifierProvider).errorMessage;
        if (errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error_outline, color: AppColors.textPrimary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _redirectBasedOnRole(UserRole role) {
    String route;
    switch (role) {
      case UserRole.customer:
        route = '/customer';
        break;
      case UserRole.store:
        route = '/store';
        break;
      case UserRole.deliverer:
        route = '/deliverer';
        break;
      case UserRole.admin:
        route = '/admin-dashboard';
        break;
      default:
        route = '/customer';
    }

    context.pushReplacement(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              _buildHeader(),
              SizedBox(height: 40),
              _buildLoginForm(),
              SizedBox(height: 24),
              _buildLoginButton(),
              SizedBox(height: 20),
              _buildInfoText(),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: () => context.go('/debug/places'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            icon: Icon(Icons.search),
            label: Text('Test Places'),
            heroTag: "places",
          ),
          SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: () => context.go('/debug/maps'),
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textOnSecondary,
            icon: Icon(Icons.map),
            label: Text('Test Maps'),
            heroTag: "maps",
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 24),
          child: Image.asset(
            'assets/images/logo.png',
            width: 220,
            height: 220,
          ),
        ),
        Text(
          'Bienvenido',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Inicia sesión en tu cuenta de UBERecus Eat',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _boletaNumberController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Número de boleta',
              hintText: '20XX03XXXX',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.textSecondary,
              ),
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu número de boleta';
              }
              if (value.length != 10 || !RegExp(r'^\d+$').hasMatch(value)) {
                return 'Por favor ingresa un número de boleta válido';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              hintText: 'Tu contraseña',
              prefixIcon: Icon(
                Icons.lock_outlined,
                color: AppColors.textSecondary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu contraseña';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoText() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryWithOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          SizedBox(height: 8),
          Text(
            'UBERecus Eat está disponible solo dentro del campus escolar. Debes ingresar tu número de boleta y contraseña que usas para entrar en SAES.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    // CAMBIO: Consumer de Riverpod en lugar de Provider
    return Consumer(
      builder: (context, ref, child) {
        final authState = ref.watch(authNotifierProvider);  // CAMBIO: watch en lugar de read
        
        return Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppGradients.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryWithOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: authState.isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authState.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.textOnPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnPrimary,
                    ),
                  ),
          ),
        );
      },
    );
  }
  
}
