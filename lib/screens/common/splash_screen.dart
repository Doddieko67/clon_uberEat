import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'dart:math';
import 'dart:ui';

class SplashScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainAnimationController;
  late AnimationController _loadingAnimationController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Evitar el error de Riverpod usando postFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initalizeAuthState();
    });
  }
  
  void _initalizeAuthState() async {
    // final authProvider = ref.read(authNotifierProvider.notifier);
    // final success = await authProvider.login("2022031111", "123456");
    // print("Login success: $success");
    
    // Después del login, navegar a la pantalla apropiada
    if (mounted) {
      await Future.delayed(Duration(seconds: 3)); // Mostrar splash un momento más
      _checkAuthStatus();
    }
  }

  void _setupAnimations() {
    // Main animation controller - más lento para menos ansiedad
    _mainAnimationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    
    // Loading animation controller - más suave
    _loadingAnimationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    // Fade animation - más gradual
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: Interval(0.0, 0.8, curve: Curves.easeInOut),
      ),
    );

    // Scale animation - menos drástico
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    
    // Slide animation - más sutil
    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );
    
    // Loading dots animation - más lento
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _mainAnimationController.forward();
    _loadingAnimationController.repeat();
  }

  void _checkAuthStatus() async {
    await ref.read(authNotifierProvider.notifier).checkAuthStatus();

    if (!mounted) return;

    // CAMBIO: usar ref.read para obtener el estado
    final authState = ref.read(authNotifierProvider);
    print("Estado de autenticación: $authState");
    
    if (authState.isAuthenticated) {
      _redirectBasedOnRole(authState.user!.role.name);
    } else {
      context.go('/login');
    }
  }

  void _redirectBasedOnRole(String role) {
    String route;
    switch (role) {
      case 'customer':
        route = '/customer';
        break;
      case 'store':
        route = '/store';
        break;
      case 'deliverer':
        route = '/deliverer';
        break;
      case 'admin':
        route = '/admin-dashboard';
        break;
      default:
        route = '/login';
    }

    context.go(route);
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppGradients.splash),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _mainAnimationController,
              _loadingAnimationController,
            ]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo original con imagen
                      _buildOriginalLogo(),
                      
                      SizedBox(height: 32),
                      
                      // Título con tema original
                      _buildThemeTitle(),
                      
                      SizedBox(height: 8),
                      
                      // Subtitle con colores del tema
                      _buildThemeSubtitle(),
                      
                      SizedBox(height: 60),
                      
                      // Loading con colores del tema
                      _buildThemeLoading(),
                      
                      SizedBox(height: 16),
                      
                      // Loading text
                      _buildThemeLoadingText(),
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
  
  Widget _buildOriginalLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: 250,
      height: 250,
    );
  }
  
  Widget _buildThemeTitle() {
    return Transform.translate(
      offset: Offset(0, _slideAnimation.value),
      child: Text(
        'UBERecus Eat',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          letterSpacing: 1.2,
          shadows: [
            Shadow(
              blurRadius: 15.0,
              color: AppColors.primary.withOpacity(0.3),
              offset: Offset(0, 4),
            ),
            Shadow(
              blurRadius: 5.0,
              color: AppColors.darkWithOpacity(0.5),
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildThemeSubtitle() {
    return Transform.translate(
      offset: Offset(0, _slideAnimation.value),
      child: Opacity(
        opacity: _fadeAnimation.value * 0.9,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            'Comida escolar a tu alcance',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildThemeLoading() {
    return SizedBox(
      width: 40,
      height: 40,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
        backgroundColor: AppColors.textPrimary.withOpacity(0.2),
        strokeWidth: 3,
      ),
    );
  }
  
  Widget _buildThemeLoadingText() {
    return AnimatedBuilder(
      animation: _loadingAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: 0.6 + (0.4 * _loadingAnimation.value),
          child: Text(
            'Preparando tu experiencia...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.5,
            ),
          ),
        );
      },
    );
  }
  
  
}