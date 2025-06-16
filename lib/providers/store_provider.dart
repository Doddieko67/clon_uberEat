import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clonubereat/models/store_model.dart';
import 'package:clonubereat/models/menu_item_model.dart';
import 'package:clonubereat/models/category_model.dart';
import 'package:clonubereat/models/user_model.dart';
import 'package:clonubereat/models/operating_hours.dart';
import 'auth_provider.dart';

class StoreNotifier extends StateNotifier<List<Store>> {
  StoreNotifier() : super([]) {
    _loadMockStores();
  }

  void _loadMockStores() {
    // Datos mock tipados usando los modelos correctos
    final mockStores = [
      Store(
        id: '1',
        name: 'Cafeter�a Central',
        storeName: 'Cafeter�a Central',
        address: 'Edificio Central, Planta Baja',
        category: 'Mexicana',
        rating: 4.8,
        reviewCount: 245,
        deliveryFee: 15.0,
        deliveryTime: 25,
        isOpen: true,
        status: UserStatus.active,
        lastActive: DateTime.now(),
        openingHours: OperatingHours(
          monday: TimeRange(open: '07:00', close: '22:00'),
          tuesday: TimeRange(open: '07:00', close: '22:00'),
          wednesday: TimeRange(open: '07:00', close: '22:00'),
          thursday: TimeRange(open: '07:00', close: '22:00'),
          friday: TimeRange(open: '07:00', close: '22:00'),
          saturday: TimeRange(open: '08:00', close: '20:00'),
          sunday: TimeRange(open: '08:00', close: '20:00'),
        ),
        description: 'Comida tradicional mexicana con ingredientes frescos del d�a',
        specialOffer: '2x1 en tacos los martes',
        hasSpecialOffer: true,
      ),
      Store(
        id: '2',
        name: 'Pizza Campus',
        storeName: 'Pizza Campus',
        address: 'Cafeter�a Ingenier�a, 2do piso',
        category: 'Italiana',
        rating: 4.6,
        reviewCount: 189,
        deliveryFee: 20.0,
        deliveryTime: 30,
        isOpen: true,
        status: UserStatus.active,
        lastActive: DateTime.now(),
        openingHours: OperatingHours(
          monday: TimeRange(open: '11:00', close: '23:00'),
          tuesday: TimeRange(open: '11:00', close: '23:00'),
          wednesday: TimeRange(open: '11:00', close: '23:00'),
          thursday: TimeRange(open: '11:00', close: '23:00'),
          friday: TimeRange(open: '11:00', close: '00:00'),
          saturday: TimeRange(open: '11:00', close: '00:00'),
          sunday: TimeRange(open: '11:00', close: '22:00'),
        ),
        description: 'Las mejores pizzas artesanales del campus',
      ),
      Store(
        id: '3',
        name: 'Sushi Sakura',
        storeName: 'Sushi Sakura',
        address: 'Centro Comercial Campus',
        category: 'Asi�tica',
        rating: 4.9,
        reviewCount: 156,
        deliveryFee: 35.0,
        deliveryTime: 35,
        isOpen: true,
        status: UserStatus.active,
        lastActive: DateTime.now(),
        openingHours: OperatingHours(
          monday: TimeRange(open: '12:00', close: '22:00'),
          tuesday: TimeRange(open: '12:00', close: '22:00'),
          wednesday: TimeRange(open: '12:00', close: '22:00'),
          thursday: TimeRange(open: '12:00', close: '22:00'),
          friday: TimeRange(open: '12:00', close: '23:00'),
          saturday: TimeRange(open: '12:00', close: '23:00'),
          sunday: TimeRange(open: '12:00', close: '21:00'),
        ),
        description: 'Sushi fresco y aut�ntica comida japonesa',
        specialOffer: 'Descuento 15% en rollos especiales',
        hasSpecialOffer: true,
      ),
      Store(
        id: '4',
        name: 'Healthy Bites',
        storeName: 'Healthy Bites',
        address: 'Gimnasio Universitario',
        category: 'Saludable',
        rating: 4.4,
        reviewCount: 98,
        deliveryFee: 25.0,
        deliveryTime: 20,
        isOpen: true,
        status: UserStatus.active,
        lastActive: DateTime.now(),
        openingHours: OperatingHours(
          monday: TimeRange(open: '06:00', close: '20:00'),
          tuesday: TimeRange(open: '06:00', close: '20:00'),
          wednesday: TimeRange(open: '06:00', close: '20:00'),
          thursday: TimeRange(open: '06:00', close: '20:00'),
          friday: TimeRange(open: '06:00', close: '20:00'),
          saturday: TimeRange(open: '07:00', close: '18:00'),
          sunday: TimeRange(open: '07:00', close: '18:00'),
        ),
        description: 'Comida saludable, jugos naturales y smoothies',
      ),
      Store(
        id: '5',
        name: 'Dulce Tentaci�n',
        storeName: 'Dulce Tentaci�n',
        address: 'Biblioteca Central, entrada',
        category: 'Postres',
        rating: 4.7,
        reviewCount: 134,
        deliveryFee: 15.0,
        deliveryTime: 15,
        isOpen: false,
        status: UserStatus.active,
        lastActive: DateTime.now(),
        openingHours: OperatingHours(
          monday: TimeRange(open: '09:00', close: '18:00'),
          tuesday: TimeRange(open: '09:00', close: '18:00'),
          wednesday: TimeRange(open: '09:00', close: '18:00'),
          thursday: TimeRange(open: '09:00', close: '18:00'),
          friday: TimeRange(open: '09:00', close: '19:00'),
          saturday: TimeRange(open: '10:00', close: '17:00'),
          sunday: TimeRange(open: '10:00', close: '17:00'),
        ),
        description: 'Postres artesanales, pasteles y caf� gourmet',
      ),
      Store(
        id: '6',
        name: 'Burger Junction',
        storeName: 'Burger Junction',
        address: 'Food Court, Local 3',
        category: 'Americana',
        rating: 4.5,
        reviewCount: 201,
        deliveryFee: 20.0,
        deliveryTime: 25,
        isOpen: true,
        status: UserStatus.active,
        lastActive: DateTime.now(),
        openingHours: OperatingHours(
          monday: TimeRange(open: '11:00', close: '22:00'),
          tuesday: TimeRange(open: '11:00', close: '22:00'),
          wednesday: TimeRange(open: '11:00', close: '22:00'),
          thursday: TimeRange(open: '11:00', close: '22:00'),
          friday: TimeRange(open: '11:00', close: '23:00'),
          saturday: TimeRange(open: '11:00', close: '23:00'),
          sunday: TimeRange(open: '12:00', close: '21:00'),
        ),
        description: 'Hamburguesas gourmet y papas artesanales',
        specialOffer: 'Combo hamburguesa + papas + refresco',
        hasSpecialOffer: true,
      ),
    ];

    state = mockStores;
  }

  Store? getStoreById(String id) {
    try {
      return state.firstWhere((store) => store.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Store> getStoresByCategory(String category) {
    return state.where((store) => store.category == category).toList();
  }

  List<Store> searchStores(String query) {
    if (query.isEmpty) return state;
    
    final lowerQuery = query.toLowerCase();
    return state.where((store) => 
      store.storeName.toLowerCase().contains(lowerQuery) ||
      store.description?.toLowerCase().contains(lowerQuery) == true ||
      store.category.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  List<String> getAvailableCategories() {
    return state.map((store) => store.category).toSet().toList();
  }

  // Firestore methods
  Future<void> createStore(Store store) async {
    try {
      final firestore = FirebaseFirestore.instance;
      
      // Convert store to map for Firestore
      final storeData = {
        'id': store.id,
        'name': store.name,
        'phone': store.phone,
        'boletaNumber': store.boletaNumber,
        'role': store.role.toString().split('.').last,
        'status': store.status.toString().split('.').last,
        'lastActive': store.lastActive.toIso8601String(),
        'photoUrl': store.photoUrl,
        'notes': store.notes,
        'storeName': store.storeName,
        'address': store.address,
        'latitude': store.latitude,
        'longitude': store.longitude,
        'category': store.category,
        'rating': store.rating,
        'reviewCount': store.reviewCount,
        'openingHours': _operatingHoursToMap(store.openingHours),
        'isOpen': store.isOpen,
        'bannerUrl': store.bannerUrl,
        'description': store.description,
        'deliveryFee': store.deliveryFee,
        'deliveryTime': store.deliveryTime,
        'specialOffer': store.specialOffer,
        'hasSpecialOffer': store.hasSpecialOffer,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await firestore.collection('stores').doc(store.id).set(storeData);
      
      // Update local state
      state = [...state, store];
      
    } catch (e) {
      throw Exception('Error al crear la tienda: $e');
    }
  }

  Map<String, dynamic> _operatingHoursToMap(OperatingHours hours) {
    return {
      'monday': _timeRangeToMap(hours.monday),
      'tuesday': _timeRangeToMap(hours.tuesday),
      'wednesday': _timeRangeToMap(hours.wednesday),
      'thursday': _timeRangeToMap(hours.thursday),
      'friday': _timeRangeToMap(hours.friday),
      'saturday': _timeRangeToMap(hours.saturday),
      'sunday': _timeRangeToMap(hours.sunday),
    };
  }

  Map<String, dynamic> _timeRangeToMap(TimeRange timeRange) {
    return {
      'open': timeRange.open,
      'close': timeRange.close,
    };
  }

  Future<Store?> getStoreForUser(String userId) async {
    try {
      final firestore = FirebaseFirestore.instance;
      final doc = await firestore.collection('stores').doc(userId).get();
      
      if (doc.exists) {
        return _storeFromFirestore(doc);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Store _storeFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Store(
      id: data['id'],
      name: data['name'],
      phone: data['phone'],
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => UserStatus.active,
      ),
      lastActive: DateTime.parse(data['lastActive']),
      photoUrl: data['photoUrl'],
      notes: data['notes'],
      storeName: data['storeName'],
      address: data['address'],
      category: data['category'],
      rating: (data['rating'] as num).toDouble(),
      reviewCount: data['reviewCount'],
      openingHours: _operatingHoursFromMap(data['openingHours']),
      isOpen: data['isOpen'],
      bannerUrl: data['bannerUrl'],
      description: data['description'],
      deliveryFee: (data['deliveryFee'] as num).toDouble(),
      deliveryTime: data['deliveryTime'],
      specialOffer: data['specialOffer'],
      hasSpecialOffer: data['hasSpecialOffer'] ?? false,
    );
  }

  OperatingHours _operatingHoursFromMap(Map<String, dynamic> data) {
    return OperatingHours(
      monday: _timeRangeFromMap(data['monday']),
      tuesday: _timeRangeFromMap(data['tuesday']),
      wednesday: _timeRangeFromMap(data['wednesday']),
      thursday: _timeRangeFromMap(data['thursday']),
      friday: _timeRangeFromMap(data['friday']),
      saturday: _timeRangeFromMap(data['saturday']),
      sunday: _timeRangeFromMap(data['sunday']),
    );
  }

  TimeRange _timeRangeFromMap(Map<String, dynamic> data) {
    // Handle both DayHours format and TimeRange format
    if (data.containsKey('isOpen')) {
      // DayHours format from Firestore
      return TimeRange(
        open: data['openTime'] ?? '00:00',
        close: data['closeTime'] ?? '00:00',
      );
    } else {
      // TimeRange format
      return TimeRange(
        open: data['open'] ?? '00:00',
        close: data['close'] ?? '00:00',
      );
    }
  }
}

class MenuItemNotifier extends StateNotifier<Map<String, List<MenuItem>>> {
  MenuItemNotifier() : super({}) {
    _loadMockMenuItems();
  }

  void _loadMockMenuItems() {
    // Datos mock del men� usando modelos tipados
    final mockMenuItems = {
      '1': [ // Cafeter�a Central
        // Populares
        MenuItem(
          id: 'pop1',
          storeId: '1',
          name: 'Tacos de Pastor',
          description: 'Deliciosos tacos al pastor con pi�a, cebolla y cilantro',
          price: 45.0,
          category: 'Populares',
          isAvailable: true,
          ingredients: ['Carne de cerdo', 'Pi�a', 'Cebolla', 'Cilantro', 'Tortilla'],
          calories: 280,
          preparationTime: 15,
          isPopular: true,
        ),
        MenuItem(
          id: 'pop2',
          storeId: '1',
          name: 'Quesadillas de Flor de Calabaza',
          description: 'Quesadillas con flor de calabaza y queso Oaxaca',
          price: 55.0,
          originalPrice: 65.0,
          category: 'Populares',
          isAvailable: true,
          ingredients: ['Flor de calabaza', 'Queso Oaxaca', 'Tortilla', 'Epazote'],
          calories: 320,
          preparationTime: 12,
          isPopular: true,
        ),
        // Tacos
        MenuItem(
          id: 'taco1',
          storeId: '1',
          name: 'Tacos de Carnitas',
          description: 'Tacos de carnitas estilo Michoac�n',
          price: 40.0,
          category: 'Tacos',
          isAvailable: true,
          ingredients: ['Carnitas', 'Cebolla', 'Cilantro', 'Salsa verde'],
          calories: 260,  
          preparationTime: 10,
        ),
        MenuItem(
          id: 'taco2',
          storeId: '1',
          name: 'Tacos de Pollo',
          description: 'Tacos de pollo asado con verduras',
          price: 42.0,
          category: 'Tacos',
          isAvailable: true,
          ingredients: ['Pollo', 'Lechuga', 'Tomate', 'Aguacate'],
          calories: 240,
          preparationTime: 12,
        ),
        // Quesadillas
        MenuItem(
          id: 'ques1',
          storeId: '1',
          name: 'Quesadilla de Champi�ones',
          description: 'Con champi�ones frescos y queso derretido',
          price: 50.0,
          category: 'Quesadillas',
          isAvailable: true,
          ingredients: ['Champi�ones', 'Queso', 'Tortilla'],
          calories: 290,
          preparationTime: 15,
        ),
        // Bebidas
        MenuItem(
          id: 'beb1',
          storeId: '1',
          name: 'Agua de Horchata',
          description: 'Refrescante agua de horchata casera',
          price: 25.0,
          category: 'Bebidas',
          isAvailable: true,
          ingredients: ['Arroz', 'Canela', 'Leche', 'Az�car'],
          calories: 180,
          preparationTime: 5,
        ),
        MenuItem(
          id: 'beb2',
          storeId: '1',
          name: 'Caf� de Olla',
          description: 'Caf� tradicional con canela y piloncillo',
          price: 20.0,
          category: 'Bebidas',
          isAvailable: true,
          ingredients: ['Caf�', 'Canela', 'Piloncillo'],
          calories: 45,
          preparationTime: 8,
        ),
      ],
      // Agregar men�s para otras tiendas...
    };

    state = mockMenuItems;
  }

  List<MenuItem> getMenuForStore(String storeId) {
    return state[storeId] ?? [];
  }

  List<MenuItem> getMenuByCategory(String storeId, String category) {
    final menu = state[storeId] ?? [];
    return menu.where((item) => item.category == category).toList();
  }

  List<String> getCategoriesForStore(String storeId) {
    final menu = state[storeId] ?? [];
    return menu.map((item) => item.category).toSet().toList();
  }

  MenuItem? getMenuItemById(String itemId) {
    for (final storeMenu in state.values) {
      try {
        return storeMenu.firstWhere((item) => item.id == itemId);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  List<MenuItem> searchMenuItems(String storeId, String query) {
    final menu = state[storeId] ?? [];
    if (query.isEmpty) return menu;
    
    final lowerQuery = query.toLowerCase();
    return menu.where((item) => 
      item.name.toLowerCase().contains(lowerQuery) ||
      item.description.toLowerCase().contains(lowerQuery) ||
      item.ingredients?.any((ingredient) => 
        ingredient.toLowerCase().contains(lowerQuery)) == true
    ).toList();
  }
}

// Providers principales
final storeProvider = StateNotifierProvider<StoreNotifier, List<Store>>((ref) {
  return StoreNotifier();
});

// Provider to check if current user has a store
final userStoreProvider = FutureProvider<Store?>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  final userId = auth.user?.id;
  
  if (userId == null) return null;
  
  final storeNotifier = ref.read(storeProvider.notifier);
  return await storeNotifier.getStoreForUser(userId);
});

final menuItemProvider = StateNotifierProvider<MenuItemNotifier, Map<String, List<MenuItem>>>((ref) {
  return MenuItemNotifier();
});

// Providers derivados
final storeByIdProvider = Provider.family<Store?, String>((ref, id) {
  final stores = ref.watch(storeProvider);
  try {
    return stores.firstWhere((store) => store.id == id);
  } catch (e) {
    return null;
  }
});

final menuForStoreProvider = Provider.family<List<MenuItem>, String>((ref, storeId) {
  final menuItems = ref.watch(menuItemProvider);
  return menuItems[storeId] ?? [];
});

final menuByCategoryProvider = Provider.family<List<MenuItem>, ({String storeId, String category})>((ref, params) {
  final menu = ref.watch(menuForStoreProvider(params.storeId));
  return menu.where((item) => item.category == params.category).toList();
});

final categoriesForStoreProvider = Provider.family<List<String>, String>((ref, storeId) {
  final menu = ref.watch(menuForStoreProvider(storeId));
  return menu.map((item) => item.category).toSet().toList();
});

final storeSearchProvider = Provider.family<List<Store>, String>((ref, query) {
  final stores = ref.watch(storeProvider);
  if (query.isEmpty) return stores;
  
  final lowerQuery = query.toLowerCase();
  return stores.where((store) => 
    store.storeName.toLowerCase().contains(lowerQuery) ||
    store.description?.toLowerCase().contains(lowerQuery) == true ||
    store.category.toLowerCase().contains(lowerQuery)
  ).toList();
});

final menuSearchProvider = Provider.family<List<MenuItem>, ({String storeId, String query})>((ref, params) {
  final menu = ref.watch(menuForStoreProvider(params.storeId));
  if (params.query.isEmpty) return menu;
  
  final lowerQuery = params.query.toLowerCase();
  return menu.where((item) => 
    item.name.toLowerCase().contains(lowerQuery) ||
    item.description.toLowerCase().contains(lowerQuery) ||
    item.ingredients?.any((ingredient) => 
      ingredient.toLowerCase().contains(lowerQuery)) == true
  ).toList();
});