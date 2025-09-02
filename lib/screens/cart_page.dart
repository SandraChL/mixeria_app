// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../data/cart_reporsitory.dart';
import '../models/cart_item.dart';
import '../utils/colors.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  final CartRepository cartRepo;
  const CartPage({super.key, required this.cartRepo});

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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Carrito vaciado')),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<CartItem>>(
        future: _futureItems,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
          }
          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text('Tu carrito está vacío.'));
          }

          final total = items.fold<double>(0, (acc, it) => acc + it.subtotal);

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length + 1,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, i) {
                      if (i == items.length) {
                        return ListTile(
                          title: const Text('Total',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          trailing: Text('\$${total.toStringAsFixed(2)}'),
                        );
                      }
                      final it = items[i];
                      return ListTile(
                        leading: CircleAvatar(child: Text(it.qty.toString())),
                        title: Text(it.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('\$${it.unit.toStringAsFixed(2)} c/u'),
                            if (it.options.isNotEmpty) const SizedBox(height: 4),
                            if (it.options.isNotEmpty)
                              Wrap(
                                spacing: 6,
                                runSpacing: -6,
                                children: it.options
                                    .map((o) => Chip(
                                          label: Text(o),
                                          visualDensity: VisualDensity.compact,
                                          padding: EdgeInsets.zero,
                                        ))
                                    .toList(),
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Quitar 1',
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () async {
                                await widget.cartRepo.removeOne(it.id);
                                await _reload();
                              },
                            ),
                            IconButton(
                              tooltip: 'Agregar 1',
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () async {
                                await widget.cartRepo.addItem(CartItem(
                                  id: it.id,
                                  name: it.name,
                                  qty: 1,
                                  price: it.price,
                                  options: it.options,
                                  extrasTotal: it.extrasTotal,
                                ));
                                await _reload();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ===== Botón Pagar =====
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.lock),
                      onPressed: items.isNotEmpty
                          ? () async {
                              final paid = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CheckoutPage(total: total),
                                ),
                              );

                              if (paid == true) {
                                // Simula éxito de pago: limpia carrito
                                await widget.cartRepo.clear();
                                await _reload();
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pago realizado con éxito'),
                                  ),
                                );
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                         backgroundColor: AppColors.primarycolor,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: const StadiumBorder(),
                      ),
                      label: Text(
                        items.isNotEmpty
                            ? 'Pagar \$${total.toStringAsFixed(2)}'
                            : 'Pagar',
                        style: TextStyle(
                          color: items.isNotEmpty ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w700,
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
