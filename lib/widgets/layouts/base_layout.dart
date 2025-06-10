// widgets/layouts/base_layout.dart - LAYOUT BASE ABSTRACTO
import 'package:flutter/material.dart';

abstract class BaseLayout extends StatelessWidget {
  final Widget child;
  final String? currentRoute;

  const BaseLayout({Key? key, required this.child, this.currentRoute})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final route = currentRoute ?? ModalRoute.of(context)?.settings.name;

    // Si no debe mostrar navegación, retornar el screen original
    if (!shouldShowNavigation(route)) {
      return child;
    }

    // Si debe mostrar navegación, envolver con el layout específico
    return Scaffold(
      body: child,
      bottomNavigationBar: buildBottomNavigation(context, route),
    );
  }

  // Métodos abstractos que cada layout implementará
  bool shouldShowNavigation(String? route);
  Widget buildBottomNavigation(BuildContext context, String? route);
  int getIndexFromRoute(String? route);
}
