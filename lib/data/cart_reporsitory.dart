import '../models/cart_item.dart';

abstract class CartRepository {
  Future<int> fetchCartCount();
  Future<List<CartItem>> fetchCartItems();
  Stream<int> watchCartCount();

  // agrega estas operaciones al contrato
  Future<void> addItem(CartItem item);
  Future<void> removeOne(String id);
  Future<void> clear();
}
