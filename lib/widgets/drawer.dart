// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../utils/colors.dart';

class AppStoreDrawer extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userTier; // p. ej. "VIP", "Gold", "Frecuente"
  final int purchaseCount; // compras realizadas
  final int points; // puntos acumulados
  final int nextTierTarget; // meta de compras para siguiente nivel
  final String? activeOrderId; // orden activa (si existe), p. ej. "ORD-12345"

  final VoidCallback? onOrders;
  final VoidCallback? onTrackActiveOrder;
  final VoidCallback? onRewards;
  final VoidCallback? onPaymentMethods;
  final VoidCallback? onWishlist;
  final VoidCallback? onNotifications;
  final VoidCallback? onHelp;
  final VoidCallback? onSettings;
  final VoidCallback? onLogout;

  const AppStoreDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userTier,
    required this.purchaseCount,
    required this.points,
    required this.nextTierTarget,
    this.activeOrderId,
    this.onOrders,
    this.onTrackActiveOrder,
    this.onRewards,
    this.onPaymentMethods,
    this.onWishlist,
    this.onNotifications,
    this.onHelp,
    this.onSettings,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final green = AppColors.primarycolor;
    final greenDark = AppColors.primaryDark;

    final progress = (purchaseCount / nextTierTarget).clamp(0, 1).toDouble();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [green, greenDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  // Avatar con iniciales y marco blanco
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(userName),
                      style: TextStyle(
                        color: greenDark,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre
                        Text(
                          'Hola, $userName',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Email
                        Text(
                          userEmail,
                          style: TextStyle(
                            color: Colors.white.withOpacity(.85),
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Tier + puntos
                        Row(
                          children: [
                            _chip(
                              text: userTier,
                              icon: Icons.workspace_premium_rounded,
                            ),
                            const SizedBox(width: 8),
                            _chip(
                              text: '$points pts',
                              icon: Icons.star_rounded,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Métricas rápidas (compras + progreso a siguiente nivel)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      _metric(
                        context,
                        label: 'Compras',
                        value: '$purchaseCount',
                        icon: Icons.shopping_bag_outlined,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Progreso a siguiente nivel',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation(green),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$purchaseCount / $nextTierTarget compras',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Opciones
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _tile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Mis órdenes',
                    subtitle: 'Historial de compras',
                    onTap: () {
                      Navigator.pop(context);
                      onOrders?.call();
                    },
                  ),
                  if (activeOrderId != null)
                    _tile(
                      icon: Icons.local_shipping_outlined,
                      title: 'Seguimiento de pedido',
                      subtitle: 'Orden: $activeOrderId',
                      onTap: () {
                        Navigator.pop(context);
                        onTrackActiveOrder?.call();
                      },
                    ),
                  _tile(
                    icon: Icons.card_giftcard_outlined,
                    title: 'Recompensas',
                    subtitle: 'Canjea tus puntos',
                    onTap: () {
                      Navigator.pop(context);
                      onRewards?.call();
                    },
                  ),
                  _tile(
                    icon: Icons.payment_outlined,
                    title: 'Métodos de pago',
                    subtitle: 'Tarjetas y otros',
                    onTap: () {
                      Navigator.pop(context);
                      onPaymentMethods?.call();
                    },
                  ),
                  _tile(
                    icon: Icons.favorite_border,
                    title: 'Favoritos',
                    subtitle: 'Tu wishlist',
                    onTap: () {
                      Navigator.pop(context);
                      onWishlist?.call();
                    },
                  ),
                  _tile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notificaciones',
                    subtitle: 'Promos y avisos',
                    onTap: () {
                      Navigator.pop(context);
                      onNotifications?.call();
                    },
                  ),
                  const Divider(),
                  _tile(
                    icon: Icons.help_outline,
                    title: 'Ayuda y soporte',
                    onTap: () {
                      Navigator.pop(context);
                      onHelp?.call();
                    },
                  ),
                  _tile(
                    icon: Icons.settings_outlined,
                    title: 'Configuración',
                    onTap: () {
                      Navigator.pop(context);
                      onSettings?.call();
                    },
                  ),
                ],
              ),
            ),

            // Cerrar sesión
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(color: Colors.redAccent),
              ),
              onTap: () {
                Navigator.pop(context);
                onLogout?.call();
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  static Widget _chip({required String text, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _metric(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap,
    );
  }
}
