import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'start_order_page.dart'; 

class CheckoutPage extends StatelessWidget {
  final double total;
  const CheckoutPage({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pago')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Método de pago',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Aquí iría la UI de selección de tarjeta/efectivo/…'),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Total a pagar',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              trailing: Text('\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16)),
            ),
            const Spacer(),
            SafeArea(
              top: false,
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // Aquí simulas el pago; en real, llamas a tu pasarela
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const StartOrderPage()),
                      (route) => false, // elimina historial para reiniciar
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primarycolor,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Confirmar pago',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
