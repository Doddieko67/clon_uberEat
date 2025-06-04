import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Limpiar errores previos cuando se entra a la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).clearError();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.resetPassword(
        _emailController.text.trim(),
      );

      if (success && mounted) {
        setState(() {
          _emailSent = true;
        });
        _animationController.forward();

        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.textPrimary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Email de recuperación enviado',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
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

  void _resendEmail() {
    setState(() {
      _emailSent = false;
    });
    _animationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Fondo oscuro
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Recuperar Contraseña',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),

              // Icono principal
              _buildMainIcon(),

              SizedBox(height: 32),

              // Contenido principal
              Expanded(
                child: SingleChildScrollView(
                  child: !_emailSent
                      ? _buildResetPasswordForm()
                      : _buildEmailSentContent(),
                ),
              ),

              // Botón de acción en la parte inferior
              _buildActionButton(),

              SizedBox(height: 16),

              // Link para volver al login
              _buildBackToLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainIcon() {
    return Center(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 400),
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: _emailSent
              ? LinearGradient(
                  colors: [AppColors.success, Color(0xFF388E3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : AppGradients.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_emailSent ? AppColors.success : AppColors.primary)
                  .withOpacity(0.4),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          _emailSent ? Icons.mark_email_read : Icons.lock_reset,
          size: 50,
          color: AppColors.textOnPrimary,
        ),
      ),
    );
  }

  Widget _buildResetPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recuperar contraseña',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary, // Texto blanco
          ),
        ),

        SizedBox(height: 8),

        Text(
          'Ingresa tu email y te enviaremos un enlace para restablecer tu contraseña.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary, // Texto secundario claro
            height: 1.4,
          ),
        ),

        SizedBox(height: 40),

        Form(
          key: _formKey,
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: AppColors.textPrimary), // Texto blanco
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'ejemplo@escuela.edu',
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppColors.textSecondary,
              ),
              labelStyle: TextStyle(color: AppColors.textSecondary),
              hintStyle: TextStyle(color: AppColors.textTertiary),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Ingresa un email válido';
              }
              return null;
            },
          ),
        ),

        SizedBox(height: 24),

        // Información adicional
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant, // Fondo oscuro
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryWithOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'El enlace de recuperación expirará en 24 horas por seguridad.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors
                        .textSecondary, // Texto claro sobre fondo oscuro
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailSentContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          children: [
            Text(
              '¡Email enviado!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary, // Texto blanco
              ),
            ),

            SizedBox(height: 16),

            Text(
              'Hemos enviado un enlace de recuperación a:',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 12),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface, // Fondo oscuro
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success, width: 1),
              ),
              child: Text(
                _emailController.text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success, // Verde para éxito
                ),
              ),
            ),

            SizedBox(height: 24),

            Text(
              'Revisa tu bandeja de entrada y sigue las instrucciones del email.',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32),

            // Instrucciones adicionales
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.schedule, 'El enlace expira en 24 horas'),
                  SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.folder_outlined,
                    'Revisa también la carpeta de spam',
                  ),
                  SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.refresh,
                    'Puedes reenviar el email si es necesario',
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Reenviar email
            TextButton.icon(
              onPressed: _resendEmail,
              icon: Icon(Icons.refresh, color: AppColors.primary),
              label: Text(
                '¿No recibiste el email? Reenviar',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primaryWithOpacity(0.1),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (_emailSent) {
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.success, Color(0xFF388E3C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back, color: AppColors.textOnPrimary),
          label: Text(
            'Volver al inicio de sesión',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textOnPrimary,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

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
          child: ElevatedButton.icon(
            onPressed: authProvider.isLoading ? null : _resetPassword,
            icon: authProvider.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.textOnPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Icon(Icons.send, color: AppColors.textOnPrimary),
            label: Text(
              authProvider.isLoading ? 'Enviando...' : 'Enviar enlace',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textOnPrimary,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackToLoginLink() {
    return TextButton(
      onPressed: () {
        Navigator.pop(context);
      },
      child: Text(
        'Volver al inicio de sesión',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
      ),
    );
  }
}
