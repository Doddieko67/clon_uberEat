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
    final authProvider = ref.read(authNotifierProvider.notifier);
    final success = await authProvider.login("2022031111", "123456");
    print("Login success: $success");
    
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
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.surface,
              AppColors.primary,
              AppColors.primaryDark,
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _mainAnimationController,
              _loadingAnimationController,
            ]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo real con animación suave
                    _buildAnimatedLogo(),
                    
                    SizedBox(height: 40),
                    
                    // App title
                    _buildAnimatedTitle(),
                    
                    SizedBox(height: 16),
                    
                    // Subtitle
                    _buildAnimatedSubtitle(),
                    
                    SizedBox(height: 60),
                    
                    // Loading simple
                    _buildSimpleLoadingIndicator(),
                    
                    SizedBox(height: 20),
                    
                    // Loading text
                    _buildLoadingText(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  
  Widget _buildAnimatedLogo() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: ClipOval(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAnimatedTitle() {
    return Text(
      'UBERecus Eat',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 1.5,
        shadows: [
          Shadow(
            blurRadius: 10.0,
            color: AppColors.primary.withOpacity(0.5),
            offset: Offset(0, 2),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAnimatedSubtitle() {
    return Transform.translate(
      offset: Offset(0, _slideAnimation.value),
      child: Opacity(
        opacity: _fadeAnimation.value,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.textPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.textPrimary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            'Comida escolar a tu alcance',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSimpleLoadingIndicator() {
    return SizedBox(
      width: 50,
      height: 50,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
      ),
    );
  }
  
  
  Widget _buildLoadingText() {
    return Text(
      'Preparando tu experiencia...',
      style: TextStyle(
        fontSize: 14,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w300,
        letterSpacing: 0.5,
      ),
    );
  }
  
  
}