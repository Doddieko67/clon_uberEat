import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _boletaNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Limpiar errores previos cuando se entra a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).clearError();
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.login(
        _boletaNumberController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        if (authProvider.isNewUser) {
          Navigator.pushReplacementNamed(context, '/register');
        } else {
          // Redirigir según el rol
          final role = authProvider.user!.role;
          _redirectBasedOnRole(role.name);
        }
      } else if (mounted && authProvider.errorMessage != null) {
        // Mostrar error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.textPrimary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    authProvider.errorMessage!,
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

  void _redirectBasedOnRole(String role) {
    String route;
    switch (role) {
      case 'customer':
        route = '/customer-home';
        break;
      case 'store':
        route = '/store-dashboard';
        break;
      case 'deliverer':
        route = '/deliverer-dashboard';
        break;
      case 'admin':
        route = '/admin-dashboard';
        break;
      default:
        route = '/customer-home';
    }

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Fondo oscuro
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),

              // Logo y encabezado
              _buildHeader(),

              SizedBox(height: 40),

              // Formulario de login
              _buildLoginForm(),

              SizedBox(height: 24),

              // Botón de login
              _buildLoginButton(),

              SizedBox(height: 20),

              // Información adicional
              _buildInfoText(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // --- INICIO DEL CAMBIO ---
        // Logo desde assets en lugar del icono
        Container(
          margin: EdgeInsets.only(bottom: 24),
          child: Image.asset(
            'assets/images/logo.png', // Ruta a tu logo
            width: 220, // Ajusta el tamaño según tu logo
            height: 220,
          ),
        ),

        // --- FIN DEL CAMBIO ---
        Text(
          'Bienvenido',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary, // Texto blanco
          ),
        ),

        SizedBox(height: 8),

        Text(
          'Inicia sesión en tu cuenta de UBERecus Eat',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary, // Texto secundario claro
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
          // Campo de boleta
          TextFormField(
            controller: _boletaNumberController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: AppColors.textPrimary), // Texto blanco
            decoration: InputDecoration(
              labelText: 'Número de boleta',
              hintText: '20XX03XXXX',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.textSecondary,
              ),
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
              // El tema ya maneja el resto de estilos oscuros
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu número de boleta';
              }
              if (value.length != 10 || !RegExp(r'^\d+$').hasMatch(value)) {
                return 'Por favor ingresa un número de boleta válido';
              }
            },
          ),

          SizedBox(height: 16),

          // Campo de contraseña
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: TextStyle(color: AppColors.textPrimary), // Texto blanco
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

  Widget _buildLoginButton() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
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
            onPressed: authProvider.isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: authProvider.isLoading
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

  Widget _buildInfoText() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant, // Fondo oscuro para el info
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
              color: AppColors.textSecondary, // Texto claro sobre fondo oscuro
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
