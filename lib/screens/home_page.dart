import 'dart:async';
import 'package:flutter/material.dart';

import '../data/cart_reporsitory.dart';
import '../widgets/app_bar.dart';
import '../widgets/drawer.dart';
import 'cart_page.dart';

// Carrito
import '../data/fake_cart_repository.dart';

// Usuario (Drawer)
import '../data/user_repository.dart';
import '../data/fake_user_repository.dart';
import '../models/user_model.dart';

// Categorías (Grid en Home)
import '../models/category_model.dart';
import '../data/categories_repository.dart';
import '../data/fake_categories_repository.dart';
import '../widgets/category_card.dart';

import 'product_list.dart';
import 'start_order_page.dart';

class HomePage extends StatefulWidget {
    final int orderNumber;

  const HomePage({
    super.key,
    required this.orderNumber,
    this.userRepo,
    this.cartRepo,
    this.categoriesRepo,
    
  });


  final UserRepository? userRepo;
  final CartRepository? cartRepo;
  final CategoriesRepository? categoriesRepo;



  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final UserRepository _userRepo;
  late final CartRepository _cartRepo;
  late final CategoriesRepository _catRepo;

  late Future<UserModel> _futureUser;
  Future<List<CategoryModel>>? _futureCategories;

  int _cartCount = 0;
  late final Stream<int> _cartCountStream;
  late final StreamSubscription<int> _cartSub;

  @override
  void initState() {
    super.initState();

    _userRepo = widget.userRepo ?? FakeUserRepository();
    _cartRepo = widget.cartRepo ?? FakeCartRepository();
    _catRepo = widget.categoriesRepo ?? FakeCategoriesRepository();

    _futureUser = _userRepo.fetchCurrentUser();

    _cartRepo.fetchCartCount().then((value) {
      if (mounted) setState(() => _cartCount = value);
    });
    _cartCountStream = _cartRepo.watchCartCount();
    _cartSub = _cartCountStream.listen((value) {
      if (mounted) setState(() => _cartCount = value);
    });
  }

  @override
  void dispose() {
    _cartSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(
        logoAsset: 'assets/images/logo-mix.png',
        cartCount: _cartCount,
        orderNumber: widget.orderNumber,
        onLogoTap: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const StartOrderPage()),
            (route) => false, // elimina historial para que no regrese a Home
          );
        },
        onCartTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => CartPage(cartRepo: _cartRepo)),
          );
        },
      ),

      drawer: FutureBuilder<UserModel>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _drawerLoading();
          }
          if (snapshot.hasError) {
            return _drawerError(snapshot.error.toString());
          }
          final u = snapshot.data!;
          return AppStoreDrawer(
            userName: u.name,
            userEmail: u.email,
            userTier: u.tier,
            purchaseCount: u.purchaseCount,
            points: u.points,
            nextTierTarget: u.nextTierTarget,
            activeOrderId: u.activeOrderId,
            onOrders: () => _open(context, 'Mis Órdenes'),
            onTrackActiveOrder:
                () => _open(
                  context,
                  'Seguimiento de pedido (${u.activeOrderId})',
                ),
            onRewards: () => _open(context, 'Recompensas'),
            onPaymentMethods: () => _open(context, 'Métodos de pago'),
            onWishlist: () => _open(context, 'Favoritos'),
            onNotifications: () => _open(context, 'Notificaciones'),
            onHelp: () => _open(context, 'Ayuda y soporte'),
            onSettings: () => _open(context, 'Configuración'),
            onLogout: () => Navigator.of(context).popUntil((r) => r.isFirst),
          );
        },
      ),

      // ===== BODY: Grid de categorías =====
      body: FutureBuilder<List<CategoryModel>>(
        future: _futureCategories ??= _catRepo.fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No pudimos cargar las categorías 😅'),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed:
                          () => setState(() {
                            _futureCategories = _catRepo.fetchCategories();
                          }),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const Center(child: Text('No hay categorías disponibles.'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int cross = 2;
              if (width >= 600) cross = 3;
              if (width >= 900) cross = 4;

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cross,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: categories.length,
                itemBuilder: (context, i) {
                  final c = categories[i];
                  final provider =
                      c.isNetwork
                          ? NetworkImage(c.imageUrl)
                          : AssetImage(c.imageUrl) as ImageProvider;

                  return CategoryCard(
                    title: c.title,
                    background: c.background,
                    image: provider,
                    onTap: () {
                      //NAVEGAR A LA PANTALLA DE PRODUCTOS
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ProductListPage(
                                categoryId: c.id,
                                title: c.title,
                                cartRepo: _cartRepo, // para agregar al carrito
                                // productsRepo: ApiProductsRepository(), // cuando tengas API
                              ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ===== Helpers Drawer =====
  static void _open(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _DummyPage(title: title)),
    );
  }

  Drawer _drawerLoading() => const Drawer(
    child: SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Cargando tu cuenta…'),
          ],
        ),
      ),
    ),
  );

  Drawer _drawerError(String error) => Drawer(
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('No pudimos cargar tu cuenta 😅'),
            const SizedBox(height: 8),
            Text(error),
          ],
        ),
      ),
    ),
  );
}

class _DummyPage extends StatelessWidget {
  final String title;
  const _DummyPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('Aquí va: $title')),
    );
  }
}
