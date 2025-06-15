import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/cart_provider.dart';

class CustomerShell extends StatelessWidget {
  final Widget child;

  const CustomerShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: CustomerBottomNavBar(),
    );
  }
}

class CustomerBottomNavBar extends ConsumerWidget {
  const CustomerBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String location = GoRouterState.of(context).uri.path;
    final cartItemsCount = ref.watch(cartItemsCountProvider);
    
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          elevation: 0,
          currentIndex: _getSelectedIndex(location),
          onTap: (index) => _onTap(context, index),
          items: [
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.home_outlined, Icons.home, location == '/customer'),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: _buildCartIcon(cartItemsCount, location == '/customer/cart'),
              label: 'Carrito',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.receipt_long_outlined, Icons.receipt_long, location == '/customer/orders'),
              label: 'Pedidos',
            ),
            BottomNavigationBarItem(
              icon: _buildIcon(Icons.person_outline, Icons.person, location == '/customer/profile'),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(IconData outlinedIcon, IconData filledIcon, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Icon(
        isSelected ? filledIcon : outlinedIcon,
        size: 24,
      ),
    );
  }

  Widget _buildCartIcon(int cartItemsCount, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Stack(
        children: [
          Icon(
            isSelected ? Icons.shopping_cart : Icons.shopping_cart_outlined,
            size: 24,
          ),
          if (cartItemsCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 1),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  cartItemsCount > 99 ? '99+' : cartItemsCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  int _getSelectedIndex(String location) {
    switch (location) {
      case '/customer':
        return 0;
      case '/customer/cart':
        return 1;
      case '/customer/orders':
        return 2;
      case '/customer/profile':
        return 3;
      default:
        return 0;
    }
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/customer');
        break;
      case 1:
        context.go('/customer/cart');
        break;
      case 2:
        context.go('/customer/orders');
        break;
      case 3:
        context.go('/customer/profile');
        break;
    }
  }
}