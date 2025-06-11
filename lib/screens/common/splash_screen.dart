import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';  // CAMBIO
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends ConsumerStatefulWidget {  // CAMBIO: StatefulWidget -> ConsumerStatefulWidget
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();  // CAMBIO: State -> ConsumerState
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthStatus();
  }
  // Comentado para evitar errores si no se llama, puedes descomentarlo si lo necesitas
  void _initalizeAuthState() async {
    final authProvider = ref.read(authNotifierProvider.notifier);
    final success = await authProvider.login("guilli@gmail.com", "mamiLenia");
    print(success);
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
    // CAMBIO: usar ref.read en lugar de Provider.of

    await Future.delayed(Duration(seconds: 3));

    await ref.read(authNotifierProvider.notifier).checkAuthStatus();

    if (!mounted) return;

    // CAMBIO: usar ref.read para obtener el estado
    final authState = ref.read(authNotifierProvider);
    print("Tratando de iniciar sesión $authState");
    
    if (authState.isAuthenticated) {
      _redirectBasedOnRole(authState.user!.role.name);
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
                      Image.asset(
                        'assets/images/logo.png',
                        width: 250,
                        height: 250,
                      ),
                      SizedBox(height: 32),
                      Text(
                        'UBERecus Eat',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
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
                      Text(
                        'Comida escolar a tu alcance',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      SizedBox(height: 60),
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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