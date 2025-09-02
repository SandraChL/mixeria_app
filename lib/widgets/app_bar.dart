import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? logoAsset; // ruta del logo
  final int cartCount; // contador del carrito
  final int? orderNumber; //número de orden actual
  final VoidCallback? onLogoTap;
  final VoidCallback? onCartTap;
  final bool showMenuButton; // muestra el botón para abrir el Drawer
  final Color color; // color base (verde)
  final Color colorDark;

  const AppTopBar({
    super.key,
    this.logoAsset,
    this.cartCount = 0,
    this.orderNumber, // 👈
    this.onLogoTap,
    this.onCartTap,
    this.showMenuButton = true,
    this.color = AppColors.primarycolor,
    this.colorDark = AppColors.primaryDark,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, colorDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: showMenuButton
          ? Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
          : null,
      titleSpacing: 0,
      title: Row(
        children: [
          if (logoAsset != null)
            GestureDetector(
              onTap: onLogoTap,
              child: Image.asset(
                logoAsset!,
                height: 36,
                fit: BoxFit.contain,
              ),
            ),
          if (orderNumber != null) ...[
            const SizedBox(width: 15),
            Text(
              "Orden #$orderNumber",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ],
      ),
      actions: [
        // Icono carrito con badge
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
                onPressed: onCartTap,
                tooltip: 'Carrito',
              ),
              if (cartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Text(
                      cartCount > 99 ? '99+' : '$cartCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
