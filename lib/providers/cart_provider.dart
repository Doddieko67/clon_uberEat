import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clonubereat/models/cart_model.dart';
import 'package:clonubereat/models/cart_item_model.dart';
import 'package:clonubereat/models/menu_item_model.dart';
import 'package:clonubereat/models/store_model.dart';

class CartNotifier extends StateNotifier<Cart> {
  CartNotifier() : super(Cart.empty('default_cart'));

  // Códigos promocionales disponibles
  static const Map<String, double> _promoCodes = {
    'ESTUDIANTE10': 10.0,
    'PRIMERAVEZ': 15.0,
    'CAMPUS20': 20.0,
  };

  void addItem(MenuItem menuItem, {int quantity = 1}) {
    final cartItem = CartItem.fromMenuItem(menuItem, quantity: quantity);
    state = state.addItem(cartItem);
  }

  void removeItem(String itemId) {
    state = state.removeItem(itemId);
  }

  void updateItemQuantity(String itemId, int quantity) {
    state = state.updateItemQuantity(itemId, quantity);
  }

  void incrementItem(String itemId) {
    final item = state.items.firstWhere((item) => item.id == itemId);
    if (item.quantity < 15) { // Límite máximo como en la UI actual
      updateItemQuantity(itemId, item.quantity + 1);
    }
  }

  void decrementItem(String itemId) {
    final item = state.items.firstWhere((item) => item.id == itemId);
    if (item.quantity > 1) {
      updateItemQuantity(itemId, item.quantity - 1);
    }
  }

  bool applyPromoCode(String code) {
    final discount = _promoCodes[code.toUpperCase()];
    if (discount != null) {
      state = state.applyPromoCode(code.toUpperCase(), discount);
      return true;
    }
    return false;
  }

  void removePromoCode() {
    state = state.removePromoCode();
  }

  void clearCart() {
    state = state.clear();
  }

  void setStore(Store store) {
    state = state.copyWith(
      storeId: store.id,
      store: store,
    );
  }

  bool canAddItemFromStore(String storeId) {
    // Si el carrito está vacío o es de la misma tienda, permitir
    return state.isEmpty || state.storeId == storeId;
  }

  void clearCartForNewStore(Store store) {
    state = Cart.empty('default_cart').copyWith(
      storeId: store.id,
      store: store,
    );
  }

  // Métodos para buscar por ID de MenuItem
  CartItem? getCartItemByMenuId(String menuItemId) {
    try {
      return state.items.firstWhere(
        (item) => item.menuItem.id == menuItemId,
      );
    } catch (e) {
      return null;
    }
  }

  // Métodos para buscar por ID de CartItem
  CartItem? getCartItemById(String cartItemId) {
    try {
      return state.items.firstWhere(
        (item) => item.id == cartItemId,
      );
    } catch (e) {
      return null;
    }
  }

  // Método de conveniencia - mantener compatibilidad
  CartItem? getCartItem(String menuItemId) {
    return getCartItemByMenuId(menuItemId);
  }

  int getItemQuantity(String menuItemId) {
    final cartItem = getCartItemByMenuId(menuItemId);
    return cartItem?.quantity ?? 0;
  }

  bool hasItem(String menuItemId) {
    return getCartItemByMenuId(menuItemId) != null;
  }

  // Método mejorado para decrementar usando MenuItem ID
  void decrementItemByMenuId(String menuItemId) {
    final cartItem = getCartItemByMenuId(menuItemId);
    if (cartItem != null && cartItem.quantity > 1) {
      updateItemQuantity(cartItem.id, cartItem.quantity - 1);
    }
  }

  // Método mejorado para incrementar usando MenuItem ID  
  void incrementItemByMenuId(String menuItemId) {
    final cartItem = getCartItemByMenuId(menuItemId);
    if (cartItem != null) {
      updateItemQuantity(cartItem.id, cartItem.quantity + 1);
    }
  }
}

// Provider principal del carrito
final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

// Providers derivados para facilitar el acceso a propiedades específicas
final cartItemsCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.totalItems;
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.total;
});

final cartSubtotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.subtotal;
});

final cartIsEmptyProvider = Provider<bool>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.isEmpty;
});

final cartDeliveryFeeProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.deliveryFee;
});

final cartTaxProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.tax;
});

final cartPromoDiscountProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.promoDiscount;
});

// Provider para obtener la cantidad de un item específico
final cartItemQuantityProvider = Provider.family<int, String>((ref, menuItemId) {
  final cart = ref.watch(cartProvider);
  final cartItem = cart.items.where((item) => item.menuItem.id == menuItemId).firstOrNull;
  return cartItem?.quantity ?? 0;
});

// Provider para verificar si un item está en el carrito
final cartHasItemProvider = Provider.family<bool, String>((ref, menuItemId) {
  final cart = ref.watch(cartProvider);
  return cart.items.any((item) => item.menuItem.id == menuItemId);
});