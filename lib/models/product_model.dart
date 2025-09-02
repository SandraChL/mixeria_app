class ProductModel {
  final String id;
  final String categoryId;
  final String name;
  final String subtitle;   // p.ej. “Hot Cake Simple”
  final double price;
  final String imageUrl;   // asset o url
  final bool isNetwork;

  const ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.subtitle,
    required this.price,
    required this.imageUrl,
    this.isNetwork = false,
  });
}
