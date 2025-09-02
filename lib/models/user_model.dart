class UserModel {
  final String name;
  final String email;
  final String tier;           // p.ej. VIP, Gold, Frecuente
  final int purchaseCount;     // compras realizadas
  final int points;            // puntos acumulados
  final int nextTierTarget;    // meta para siguiente nivel
  final String? activeOrderId; // orden activa (opcional)

  const UserModel({
    required this.name,
    required this.email,
    required this.tier,
    required this.purchaseCount,
    required this.points,
    required this.nextTierTarget,
    this.activeOrderId,
  });

  // Si mañana usas API/JSON, puedes agregar fromJson aquí.
}
