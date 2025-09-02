import 'dart:async';
import '../models/product_model.dart';
import 'products_repository.dart';

class FakeProductsRepository implements ProductsRepository {
  // datos mock
  static final _all = <ProductModel>[
    ProductModel(
      id: 'p1',
      categoryId: 'hotcakes',
      name: 'Hot Cake Simple',
      subtitle: 'Hot Cake Simple',
      price: 40,
      imageUrl: 'assets/images/PQ_simple.png',
    ),
    ProductModel(
      id: 'p2',
      categoryId: 'hotcakes',
      name: 'Hot Cake Doble',
      subtitle: 'Hot Cake Doble',
      price: 48,
      imageUrl: 'assets/images/PQ_doble.png',
    ),
    ProductModel(
      id: 'p3',
      categoryId: 'hotcakes',
      name: 'Hot Cake Mix',
      subtitle: 'Hot Cake Mix',
      price: 50,
      imageUrl: 'assets/images/PQ_mix.png',
    ),

    // ===== WAFFLES =====
    ProductModel(
      id: 'wf_1',
      categoryId: 'waffles',
      name: 'Waffle Simple',
      subtitle: 'Azúcar glass y miel',
      price: 42,
      imageUrl: 'assets/images/WF_simple.png',
    ),
    ProductModel(
      id: 'wf_2',
      categoryId: 'waffles',
      name: 'Waffle Doble',
      subtitle: 'Fresa + crema batida',
      price: 52,
      imageUrl: 'assets/images/WF_doble.png',
    ),
    ProductModel(
      id: 'wf_3',
      categoryId: 'waffles',
      name: 'Waffle Mix',
      subtitle: 'Chispas de chocolate, helado...',
      price: 50,
      imageUrl: 'assets/images/WF_mix.png',
    ),

    // ===== BEBIDAS =====
    ProductModel(
      id: 'bb_1',
      categoryId: 'bebidas',
      name: 'Té de Manzanilla',
      subtitle: '12 oz',
      price: 35,
      imageUrl: 'assets/images/T_manzanilla.png',
    ),
    ProductModel(
      id: 'bb_2',
      categoryId: 'bebidas',
      name: 'Té de Verde',
      subtitle: '12 oz',
      price: 32,
      imageUrl: 'assets/images/T_verde.png',
    ),
    ProductModel(
      id: 'bb_3',
      categoryId: 'bebidas',
      name: 'Té Negro',
      subtitle: '12 oz',
      price: 38,
      imageUrl: 'assets/images/T_negro.png',
    ),
    ProductModel(
      id: 'bb_4',
      categoryId: 'bebidas',
      name: 'Té de Canela',
      subtitle: '12 oz',
      price: 38,
      imageUrl: 'assets/images/T_canela.png',
    ),
    ProductModel(
      id: 'bb_5',
      categoryId: 'bebidas',
      name: 'Cafe Americano',
      subtitle: '12 oz',
      price: 38,
      imageUrl: 'assets/images/cafe-americano.png',
    ),
    ProductModel(
      id: 'bb_6',
      categoryId: 'bebidas',
      name: 'Coca-cola',
      subtitle: '600 ml',
      price: 38,
      imageUrl: 'assets/images/R_coca.png',
    ),
    ProductModel(
      id: 'bb_7',
      categoryId: 'bebidas',
      name: 'Squirt',
      subtitle: '600 ml',
      price: 38,
      imageUrl: 'assets/images/R_squirt.png',
    ),
    ProductModel(
      id: 'bb_8',
      categoryId: 'bebidas',
      name: 'Manzana',
      subtitle: '600 ml',
      price: 38,
      imageUrl: 'assets/images/R_manzana.png',
    ),
    ProductModel(
      id: 'bb_9',
      categoryId: 'bebidas',
      name: 'Agua',
      subtitle: '600 ml',
      price: 38,
      imageUrl: 'assets/images/Agua.png',
    ),
    ProductModel(
      id: 'bb_10',
      categoryId: 'bebidas',
      name: 'Jugo',
      subtitle: '600 ml',
      price: 38,
      imageUrl: 'assets/images/Jugo.png',
    ),

    // ===== ESQUITES =====
    ProductModel(
      id: 'eq_1',
      categoryId: 'esquites',
      name: 'Esquite Chico',
      subtitle: 'vaso chico',
      price: 35,
      imageUrl: 'assets/images/no-fotos.png',
    ),
    ProductModel(
      id: 'eq_2',
      categoryId: 'esquites',
      name: 'Esquite Grande',
      subtitle: 'vaso grande',
      price: 35,
      imageUrl: 'assets/images/no-fotos.png',
    ),

    // ===== FRITURAS =====
    ProductModel(
      id: 'ft_1',
      categoryId: 'frituras',
      name: 'Papas Chicas',
      subtitle: 'vaso chico',
      price: 35,
      imageUrl: 'assets/images/no-fotos.png',
    ),
    ProductModel(
      id: 'ft_2',
      categoryId: 'frituras',
      name: 'Papas Grandes',
      subtitle: 'vaso grande',
      price: 35,
      imageUrl: 'assets/images/no-fotos.png',
    ),
    ProductModel(
      id: 'ft_3',
      categoryId: 'frituras',
      name: 'Sopa Instantanea',
      subtitle: '...',
      price: 35,
      imageUrl: 'assets/images/no-fotos.png',
    ),

    // ===== HELADOS =====
    ProductModel(
      id: 'hd_1',
      categoryId: 'helados',
      name: 'Helado Simple',
      subtitle: 'solo 1 bola',
      price: 35,
      imageUrl: 'assets/images/no-fotos.png',
    ),
    ProductModel(
      id: 'hd_2',
      categoryId: 'helados',
      name: 'Helado Doble',
      subtitle: 'solo 2 bola',
      price: 35,
      imageUrl: 'assets/images/no-fotos.png',
    ),
    ProductModel(
      id: 'hd_3',
      categoryId: 'helados',
      name: 'Helado Mix',
      subtitle: 'mas de 2 bolas',
      price: 35,
      imageUrl: 'assets/images/no-fotos.png',
    ),

    // ===== FRUTAS =====
    ProductModel(
      id: 'fr_1',
      categoryId: 'frutas',
      name: 'Coctel Chico',
      subtitle: 'vaso chico',
      price: 35,
      imageUrl: 'assets/images/no-fotos.png',
    ),
    ProductModel(
      id: 'fr_2',
      categoryId: 'frutas',
      name: 'Coctel Grande',
      subtitle: 'vaso grande',
      price: 35,
      imageUrl: 'assets/images/no-fotos.png',
    ),
    ProductModel(
      id: 'fr_3',
      categoryId: 'frutas',
      name: 'Coctel Mix',
      subtitle: 'vaso mix',
      price: 35,
      imageUrl: 'assets/images/no-fotos.png',
    ),
  ];

  @override
  Future<List<ProductModel>> fetchByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _all.where((p) => p.categoryId == categoryId).toList();
  }
}
