// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../data/cart_reporsitory.dart';
import '../models/cart_item.dart';
import '../utils/colors.dart';
import '../widgets/app_footer.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  final CartRepository cartRepo;
  final int orderNumber;

  const CartPage({
    super.key,
    required this.cartRepo,
    required this.orderNumber,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<CartItem>> _futureItems;

  @override
  void initState() {
    super.initState();
    _futureItems = widget.cartRepo.fetchCartItems();
  }

  Future<void> _reload() async {
    setState(() {
      _futureItems = widget.cartRepo.fetchCartItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito'),
        actions: [
          IconButton(
            tooltip: 'Vaciar carrito',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              await widget.cartRepo.clear();
              await _reload();
              if (!mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Carrito vaciado')));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CartItem>>(
        future: _futureItems,
        builder: (context, snapshot) {
          // ===== Estado: Cargando =====
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: const [
                Expanded(child: Center(child: CircularProgressIndicator())),
                AppFooter(),
              ],
            );
          }

          // ===== Estado: Error =====
          if (snapshot.hasError) {
            return Column(
              children: [
                Expanded(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                ),
                const AppFooter(),
              ],
            );
          }

          final items = snapshot.data ?? [];
          final hasItems = items.isNotEmpty;
          final total = items.fold<double>(0, (acc, it) => acc + it.subtotal);

          // ===== UI general con Footer SIEMPRE =====
          return Column(
            children: [
              // Contenido principal
              Expanded(
                child:
                    hasItems
                        ? RefreshIndicator(
                          onRefresh: _reload,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: items.length + 1,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, i) {
                              if (i == items.length) {
                                return ListTile(
                                  title: const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  trailing: Text(
                                    '\$${total.toStringAsFixed(2)}',
                                  ),
                                );
                              }
                              final it = items[i];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(it.qty.toString()),
                                ),
                                title: Text(it.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('\$${it.unit.toStringAsFixed(2)} c/u'),
                                    if (it.options.isNotEmpty)
                                      const SizedBox(height: 4),
                                    if (it.options.isNotEmpty)
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: -6,
                                        children:
                                            it.options
                                                .map(
                                                  (o) => Chip(
                                                    label: Text(o),
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      tooltip: 'Quitar 1',
                                      icon: const Icon(
                                        Icons.remove_circle_outline,
                                      ),
                                      onPressed: () async {
                                        await widget.cartRepo.removeOne(it.id);
                                        await _reload();
                                      },
                                    ),
                                    IconButton(
                                      tooltip: 'Agregar 1',
                                      icon: const Icon(
                                        Icons.add_circle_outline,
                                      ),
                                      onPressed: () async {
                                        await widget.cartRepo.addItem(
                                          CartItem(
                                            id: it.id,
                                            name: it.name,
                                            qty: 1,
                                            price: it.price,
                                            options: it.options,
                                            extrasTotal: it.extrasTotal,
                                          ),
                                        );
                                        await _reload();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                        : const Center(child: Text('Tu carrito está vacío.')),
              ),

              // Botón pagar SOLO si hay items
              if (hasItems) ...[
                SafeArea(
                  top: false,
                  child: SizedBox(
                    width: 300,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => CheckoutPage(
                                  total: total,
                                  orderNumber: widget.orderNumber,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primarycolor,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        'Proceder al pago',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              // Footer SIEMPRE
              const AppFooter(),
            ],
          );
        },
      ),
    );
  }
}
