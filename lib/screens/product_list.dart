// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import '../data/cart_reporsitory.dart';
import '../models/product_model.dart';
import '../data/products_repository.dart';
import '../data/fake_products_repository.dart';
import '../utils/colors.dart';
import '../widgets/product_card.dart';

import '../models/cart_item.dart';
import '../widgets/product_options_sheet.dart';

class ProductListPage extends StatefulWidget {
  final String categoryId;
  final String title;
  final ProductsRepository? productsRepo;
  final CartRepository? cartRepo;

  const ProductListPage({
    super.key,
    required this.categoryId,
    required this.title,
    this.productsRepo,
    this.cartRepo,
  });

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final ProductsRepository _repo;
  late Future<List<ProductModel>> _future;

  /// id del producto -> cantidad elegida
  final Map<String, int> _qty = {};

  /// id del producto -> lista de personalizaciones (una por pieza)
  final Map<String, List<ProductCustomization>> _customByProduct = {};

  @override
  void initState() {
    super.initState();
    _repo = widget.productsRepo ?? FakeProductsRepository();
    _future = _repo.fetchByCategory(widget.categoryId);
  }

  int get totalPieces => _qty.values.fold(0, (acc, e) => acc + e);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<List<ProductModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 8),
                  Text(
                    'Sin productos en esta categoría',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // ===== GRID =====
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) {
                    int cross = 1;
                    if (c.maxWidth >= 700) cross = 2;
                    if (c.maxWidth >= 1000) cross = 3;

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cross,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        mainAxisExtent:
                            310, // ajusta si tu ProductCard cambia de alto
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, i) {
                        final p = products[i];
                        final q = _qty[p.id] ?? 0;

                        return ProductCard(
                          product: p,
                          quantity: q,
                          onAdd: () async {
                            final cat = widget.categoryId.toLowerCase();

                            // 1) Bebidas: NO sheet, solo contar; se agregan hasta "Ordenar"
                            if (cat == 'bebidas') {
                              setState(() {
                                _qty[p.id] = (_qty[p.id] ?? 0) + 1;
                              });
                              return;
                            }

                            // ----- Catálogos base (puedes moverlos a tu backend luego) -----
                            const basesGenericas = [
                              OptionItem('cajeta', 'Cajeta'),
                              OptionItem('chocolate', 'Chocolate'),
                              OptionItem('maple', 'Maple'),
                            ];
                            const toppingsGenericos = [
                              OptionItem('fresa', 'Fresa'),
                              OptionItem('nuez', 'Nuez'),
                              OptionItem('platano', 'Plátano'),
                              OptionItem('chispas', 'Chispas de chocolate'),
                            ];
                            const extrasGenericos = [
                              ExtraItem('cajeta', 'Cajeta', 10),
                              ExtraItem('nutella', 'Nutella', 15),
                              ExtraItem('lechera', 'Lechera', 10),
                              ExtraItem('m_fresa', 'Mermelada de Fresa', 10),
                            ];

                            // 2) Define qué mostrar según la categoría
                            List<OptionItem> bases = basesGenericas;
                            List<OptionItem> toppings = toppingsGenericos;
                            List<ExtraItem> extras = extrasGenericos;
                            String baseLabel = 'Base';
                            int maxToppings;

                            // Para “Doble” límite 2, si no 1 (sigue aplicando)
                            final isDoble = p.name.toLowerCase().contains(
                              'doble',
                            );
                            maxToppings = isDoble ? 2 : 1;

                            switch (cat) {
                              case 'esquites':
                                // Solo extras salados (con costo) + Salsas (sin costo) + Con todo
                                final List<OptionItem> bases =
                                    const []; // sin base
                                final List<OptionItem> toppings =
                                    const []; // sin toppings

                                final List<ExtraItem> extras = const [
                                  ExtraItem('queso', 'Queso rallado', 12),
                                  ExtraItem('crema', 'Crema', 10),
                                  ExtraItem('elote_extra', 'Elote extra', 15),
                                ];

                                final List<OptionItem> sauces = const [
                                  OptionItem('valentina', 'Valentina'),
                                  OptionItem('cholula', 'Cholula'),
                                  OptionItem('chamoy', 'Chamoy'),
                                ];

                                final res = await showProductOptionsSheet(
                                  context,
                                  productTitle: p.name,
                                  bases: bases,
                                  toppings: toppings,
                                  extras: extras,
                                  sauces: sauces,
                                  maxToppings: 0, // sin toppings
                                  baseLabel: 'Base',
                                  showConTodo: true, // 👈 mostrar toggle
                                  conTodoText:
                                      'Con todo (mayonesa, queso y chile en polvo)',
                                );

                                if (res != null) {
                                  setState(() {
                                    _qty[p.id] = (_qty[p.id] ?? 0) + 1;
                                    _customByProduct
                                        .putIfAbsent(p.id, () => [])
                                        .add(res);
                                  });
                                }
                                return; // importante: no seguir al flujo general

                              case 'frituras':
                                // Solo extras (puedes personalizar la lista si quieres aquí)
                                bases = const [];
                                toppings = const [];
                                // Extras salados ejemplo (precio)
                                extras = const [
                                  ExtraItem('queso', 'Queso', 12),
                                  ExtraItem('salsa_extra', 'Salsa extra', 7),
                                  ExtraItem('limon_extra', 'Limón extra', 5),
                                ];
                                break;

                              case 'helados':
                                baseLabel = 'Sabor de helado';
                                bases = const [
                                  OptionItem('vainilla', 'Vainilla'),
                                  OptionItem('chocolate', 'Chocolate'),
                                  OptionItem('fresa', 'Fresa'),
                                  OptionItem('napolitano', 'Napolitano'),
                                ];
                                // toppings y extras genéricos o los que prefieras
                                break;

                              case 'frutas':
                                bases = const [];
                                toppings = const [];
                                // extras ejemplo para frutas (precio)
                                extras = const [
                                  ExtraItem('granola', 'Granola', 10),
                                  ExtraItem('miel', 'Miel', 8),
                                  ExtraItem('yogurt', 'Yogurt', 12),
                                ];
                                break;

                              default:
                                // Otras categorías: base+toppings+extras genéricos como ya tenías
                                break;
                            }

                            // Si no hay nada que elegir (bases y toppings vacíos) pero SÍ extras,
                            // aún abrimos el sheet para seleccionar extras. Si quisieras saltarlo,
                            // podrías detectarlo aquí.
                            final res = await showProductOptionsSheet(
                              context,
                              productTitle: p.name,
                              bases: bases,
                              toppings: toppings,
                              extras: extras,
                              maxToppings: maxToppings,
                              baseLabel: baseLabel, // 👈 para helados
                            );

                            if (res != null) {
                              setState(() {
                                _qty[p.id] = (_qty[p.id] ?? 0) + 1;
                                _customByProduct
                                    .putIfAbsent(p.id, () => [])
                                    .add(res);
                              });
                              // No agregamos al carrito aquí (para evitar duplicados). Se agrega en "Ordenar".
                            }
                          },

                          onRemove: () {
                            if (q > 0) {
                              setState(() {
                                _qty[p.id] = q - 1;
                                // Remueve la última personalización asociada
                                final list = _customByProduct[p.id];
                                if (list != null && list.isNotEmpty) {
                                  list.removeLast();
                                  if (list.isEmpty) {
                                    _customByProduct.remove(p.id);
                                  }
                                }
                              });
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // ===== BOTÓN ORDENAR =====
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          totalPieces > 0
                              ? () async {
                                if (widget.cartRepo != null) {
                                  for (final p in products) {
                                    final customList =
                                        _customByProduct[p.id] ?? const [];
                                    final qtySelected = _qty[p.id] ?? 0;

                                    // 1) Agrega UNA línea por cada personalización guardada (categorías con sheet)
                                    for (final cus in customList) {
                                      final extraLabels =
                                          cus.extras
                                              .map(
                                                (e) =>
                                                    '${e.label} (+\$${e.price.toStringAsFixed(0)})',
                                              )
                                              .toList();

                                      await widget.cartRepo!.addItem(
                                        CartItem(
                                          id: p.id,
                                          name: p.name,
                                          qty: 1,
                                          price: p.price,
                                          options: [
                                            if (cus.baseId != null)
                                              'Base: ${cus.baseId}',
                                            if (cus.toppingIds.isNotEmpty)
                                              'Top: ${cus.toppingIds.join(", ")}',
                                            if (extraLabels.isNotEmpty)
                                              ...extraLabels.map(
                                                (x) => 'Extra: $x',
                                              ),
                                          ],
                                          extrasTotal: cus.extrasTotal,
                                        ),
                                      );
                                    }

                                    // 2) Agrega las piezas restantes SIN personalización (bebidas u otros sin sheet)
                                    final remaining =
                                        qtySelected - customList.length;
                                    if (remaining > 0) {
                                      await widget.cartRepo!.addItem(
                                        CartItem(
                                          id: p.id,
                                          name: p.name,
                                          qty:
                                              remaining, // agrega todas las restantes de golpe
                                          price: p.price,
                                          options: const [], // sin opciones
                                          extrasTotal: 0.0, // sin costo extra
                                        ),
                                      );
                                    }
                                  }
                                }

                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${totalPieces == 1 ? "1 pieza" : "$totalPieces piezas"} agregadas al carrito',
                                    ),
                                  ),
                                );
                                Navigator.pop(context);
                              }
                              : null,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primarycolor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        totalPieces > 0
                            ? 'Ordenar ($totalPieces ${totalPieces == 1 ? "pieza" : "piezas"})'
                            : 'Ordenar',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: totalPieces > 0 ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
