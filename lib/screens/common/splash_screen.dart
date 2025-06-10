import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // Comentado para evitar errores si no se llama, puedes descomentarlo si lo necesitas
  void _initalizeAuthState() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login("guilli@gmail.com", "mamiLenia");
    print(success);
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // _initalizeAuthState();
    _checkAuthStatus();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 0.8, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  void _checkAuthStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Verificar estado de autenticación
    await authProvider.checkAuthStatus();

    // Esperar a que termine la animación
    await Future.delayed(Duration(seconds: 3));

    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      // Redirigir según el rol del usuario
      _redirectBasedOnRole(authProvider.user!.role.name);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
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
        route = '/login';
    }

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.splash),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // --- CAMBIO AQUÍ ---
                      // Se elimina el Container y el Padding.
                      // Se coloca el logo directamente con un tamaño definido.
                      Image.asset(
                        'assets/images/logo.png',
                        width:
                            250, // Un poco más grande para que sea el foco principal
                        height: 250,
                      ),

                      // --- FIN DEL CAMBIO ---
                      SizedBox(height: 32),

                      // Título principal
                      Text(
                        'UBERecus Eat',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          // Consejo: Añadir una sombra al texto puede darle profundidad
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 8),

                      // Subtítulo
                      Text(
                        'Comida escolar a tu alcance',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                        ),
                      ),

                      SizedBox(height: 60),

                      // Indicador de carga
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 3,
                        ),
                      ),

                      SizedBox(height: 16),

                      Text(
                        'Cargando...',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
