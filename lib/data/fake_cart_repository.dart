import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import 'cart_reporsitory.dart';

class FakeCartRepository implements CartRepository {
  FakeCartRepository({bool seedDemo = false}) {
    _items =
        seedDemo
            ? [
              const CartItem(
                id: '1',
                name: 'Hot Cakes',
                qty: 2,
                price: 49.0,
                options: [],
                extrasTotal: 0,
              ),
              const CartItem(
                id: '2',
                name: 'Café Latte',
                qty: 1,
                price: 35.0,
                options: [],
                extrasTotal: 0,
              ),
            ]
            : []; // 👈 vacío por defecto
    _emitCount();
  }

  late List<CartItem> _items;
  final _countController = StreamController<int>.broadcast();

  void _emitCount() {
    final total = _items.fold<int>(0, (acc, it) => acc + it.qty);
    _countController.add(total);
  }

  // ===== Implementación del contrato =====
  @override
  Future<int> fetchCartCount() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _items.fold<int>(0, (acc, it) => acc + it.qty);
  }

  @override
  Future<List<CartItem>> fetchCartItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List<CartItem>.unmodifiable(_items);
  }

  @override
  Stream<int> watchCartCount() => _countController.stream;

  /// Fusiona por (id + options + extrasTotal). Si no existe, crea línea nueva.
  @override
  Future<void> addItem(CartItem item) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final idx = _items.indexWhere(
      (e) =>
          e.id == item.id &&
          listEquals(e.options, item.options) &&
          e.extrasTotal == item.extrasTotal,
    );

    if (idx == -1) {
      _items = [..._items, item];
    } else {
      final curr = _items[idx];
      _items[idx] = CartItem(
        id: curr.id,
        name: curr.name,
        qty: curr.qty + item.qty,
        price: curr.price,
        options: curr.options,
        extrasTotal: curr.extrasTotal,
      );
    }
    _emitCount();
  }

  /// Decrementa 1 en la PRIMERA línea que coincida por id.
  /// (Si quieres decrementar una línea específica por opciones, crea removeOneExact)
  @override
  Future<void> removeOne(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final curr = _items[idx];
      final newQty = curr.qty - 1;
      if (newQty <= 0) {
        _items = List.of(_items)..removeAt(idx);
      } else {
        _items[idx] = CartItem(
          id: curr.id,
          name: curr.name,
          qty: newQty,
          price: curr.price,
          options: curr.options,
          extrasTotal: curr.extrasTotal,
        );
      }
      _emitCount();
    }
  }

  @override
  Future<void> clear() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _items = [];
    _emitCount();
  }

  void dispose() {
    _countController.close();
  }
}
