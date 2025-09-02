class CartItem {
  final String id;
  final String name;
  final int qty;
  final double price;        // precio base del producto
  final List<String> options; // descripciones (Base, Top, Extras…)
  final double extrasTotal;  // cargo extra por unidad (sumatoria de extras)

  const CartItem({
    required this.id,
    required this.name,
    required this.qty,
    required this.price,
    this.options = const [],
    this.extrasTotal = 0.0,
  });

  // precio unitario real (base + extras)
  double get unit => price + extrasTotal;

  // subtotal de la línea
  double get subtotal => unit * qty;
}
