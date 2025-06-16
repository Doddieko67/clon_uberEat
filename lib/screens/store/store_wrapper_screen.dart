import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../providers/store_provider.dart';
import 'store_dashboard_screen.dart';

class StoreWrapperScreen extends ConsumerWidget {
  const StoreWrapperScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userStoreAsync = ref.watch(userStoreProvider);

    return userStoreAsync.when(
      data: (store) {
        if (store == null) {
          // User doesn't have a store, redirect to onboarding
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/store/onboarding');
          });
          
          return Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          );
        }
        
        // User has a store, show dashboard
        return StoreDashboardScreen();
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Verificando configuración de tienda...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      error: (error, stack) {
        // Error checking store, redirect to onboarding
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/store/onboarding');
        });
        
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error al verificar la tienda',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Redirigiendo a configuración...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}