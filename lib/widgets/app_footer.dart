import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: Colors.grey.shade100, // fondo claro
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Texto ©
          const Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Mixeria',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' © 2025   '), // espacio antes de íconos
              ],
            ),
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),

          // Íconos redes sociales
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.facebook, size: 18, color: Colors.blue),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              //abre enlace de Facebook
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.instagram, size: 18, color: Colors.purple),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              // abre enlace de Instagram
            },
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.globe, size: 18, color: Colors.green),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              // abre enlace de la web
            },
          ),
        ],
      ),
    );
  }
}
