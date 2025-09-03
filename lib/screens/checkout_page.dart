// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/colors.dart';
import '../widgets/app_footer.dart';
import 'start_order_page.dart';

enum PaymentMethod { card, cash }

class CheckoutPage extends StatefulWidget {
  final double total;
  final int orderNumber;

  const CheckoutPage({
    super.key,
    required this.total,
    required this.orderNumber,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod _method = PaymentMethod.card;

  // Duración configurable del aviso/loader de Efectivo
  static const Duration alertDuration = Duration(seconds: 5);

  // Form & controllers
  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final cardCtrl =
      TextEditingController(); // 16 dígitos (formateo con espacios)
  final expiryCtrl = TextEditingController(); // MM/AA (formateo)
  final cvvCtrl = TextEditingController(); // 3-4 dígitos

  final cashCtrl = TextEditingController(); // efectivo recibido

  bool saveCard = false;
  bool processing = false;

  @override
  void dispose() {
    nameCtrl.dispose();
    cardCtrl.dispose();
    expiryCtrl.dispose();
    cvvCtrl.dispose();
    cashCtrl.dispose();
    super.dispose();
  }

  // ===== Validaciones simples =====
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Ingresa el nombre del titular';
    if (v.trim().length < 3) return 'Nombre demasiado corto';
    return null;
  }

  String _digitsOnly(String s) => s.replaceAll(RegExp(r'\D'), '');

  String? _validateCard(String? v) {
    final digits = _digitsOnly(v ?? '');
    if (digits.length < 16) return 'La tarjeta debe tener 16 dígitos';
    return null;
  }

  String? _validateExpiry(String? v) {
    final val = v?.trim() ?? '';
    final exp = RegExp(r'^\d{2}/\d{2}$');
    if (!exp.hasMatch(val)) return 'Formato MM/AA';
    final mm = int.tryParse(val.substring(0, 2)) ?? 0;
    if (mm < 1 || mm > 12) return 'Mes inválido';
    // (opcional) validar si ya caducó con DateTime.now()
    return null;
  }

  String? _validateCVV(String? v) {
    final digits = _digitsOnly(v ?? '');
    if (digits.length < 3 || digits.length > 4) return 'CVV inválido';
    return null;
  }

  String? _validateCash(String? v) {
    final given = double.tryParse(v?.replaceAll(',', '.') ?? '');
    if (given == null) return 'Ingresa un monto';
    if (given < widget.total) return 'El efectivo no alcanza el total';
    return null;
  }

  double get _change {
    final given = double.tryParse(cashCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final change = given - widget.total;
    return change > 0 ? change : 0.0;
  }

  bool get _isValidForPay {
    if (_method == PaymentMethod.card) {
      return _formKey.currentState?.validate() ?? false;
    } else {
      return _validateCash(cashCtrl.text) == null;
    }
  }

  Future<void> _confirmPay() async {
    if (!_isValidForPay) return;
    setState(() => processing = true);

    if (_method == PaymentMethod.cash) {
      // 1) Diálogo con loader y mensaje
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          final given =
              double.tryParse(cashCtrl.text.replaceAll(',', '.')) ?? 0.0;
          final change = (given - widget.total).clamp(0, double.infinity);
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¡Perfecto!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Orden #${widget.orderNumber}', // 👈 muestra el número de orden
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Puedes pasar a caja. Estamos preparando tu cambio… ',
                        ),
                        if (given > 0) ...[
                          const SizedBox(height: 10),
                          Text(
                            'Entregaste: \$${given.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Cambio: \$${change.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // 2) Simula proceso en caja usando la duración configurable
      await Future.delayed(alertDuration);

      if (!mounted) return;

      // 3) Cierra el diálogo
      Navigator.of(context).pop(); // close dialog

      // 4) Redirige a StartOrderPage limpiando el stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const StartOrderPage()),
        (route) => false,
      );
    } else {
      // Tarjeta: simulación de pasarela
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            insetPadding: const EdgeInsets.symmetric(horizontal: 40),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '¡Perfecto!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pase a caja a pagar con su número de orden #${widget.orderNumber}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Espera simulada
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      Navigator.of(context).pop(); // cierra el diálogo

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const StartOrderPage()),
        (route) => false,
      );
    }
  }

  // Formateo simple MM/AA
  void _onExpiryChanged(String v) {
    final d = _digitsOnly(v);
    String out = d;
    if (d.length >= 3) {
      out =
          '${d.substring(0, 2)}/${d.substring(2, d.length > 4 ? 4 : d.length)}';
    }
    if (out != v) {
      expiryCtrl.value = TextEditingValue(
        text: out,
        selection: TextSelection.collapsed(offset: out.length),
      );
    }
  }

  // Espaciado de tarjeta 1234 5678 9012 3456
  void _onCardChanged(String v) {
    final d = _digitsOnly(v);
    final chunks = <String>[];
    for (int i = 0; i < d.length; i += 4) {
      chunks.add(d.substring(i, i + 4 > d.length ? d.length : i + 4));
    }
    final out = chunks.join(' ');
    if (out != v) {
      cardCtrl.value = TextEditingValue(
        text: out,
        selection: TextSelection.collapsed(offset: out.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primarycolor;

    return Scaffold(
      appBar: AppBar(title: const Text('Pago')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Total
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  const Text(
                    'Total a pagar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    '\$${widget.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Método de pago
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Método de pago',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Selector
            Row(
              children: [
                Expanded(
                  child: _MethodTile(
                    selected: _method == PaymentMethod.card,
                    icon: Icons.credit_card,
                    label: 'Tarjeta',
                    onTap: () => setState(() => _method = PaymentMethod.card),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MethodTile(
                    selected: _method == PaymentMethod.cash,
                    icon: Icons.payments_outlined,
                    label: 'Efectivo',
                    onTap: () => setState(() => _method = PaymentMethod.cash),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Contenido variable
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child:
                    _method == PaymentMethod.card
                        ? _CardForm(
                          key: const ValueKey('card'),
                          formKey: _formKey,
                          nameCtrl: nameCtrl,
                          cardCtrl: cardCtrl,
                          expiryCtrl: expiryCtrl,
                          cvvCtrl: cvvCtrl,
                          saveCard: saveCard,
                          onToggleSave: (v) => setState(() => saveCard = v),
                          onCardChanged: _onCardChanged,
                          onExpiryChanged: _onExpiryChanged,
                          onFormChanged: () => setState(() {}),
                          validators: (
                            _validateName,
                            _validateCard,
                            _validateExpiry,
                            _validateCVV,
                          ),
                        )
                        : _CashForm(
                          key: const ValueKey('cash'),
                          cashCtrl: cashCtrl,
                          validateCash: _validateCash,
                          change: _change,
                          onChanged:
                              (_) => setState(
                                () {},
                              ), // recalcula UI (cambio/botón)
                        ),
              ),
            ),

            // Botón pagar
            SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      (!_isValidForPay || processing) ? null : _confirmPay,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: const StadiumBorder(),
                  ),
                  child:
                      processing
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text(
                            _method == PaymentMethod.card
                                ? 'Pagar \$${widget.total.toStringAsFixed(2)}'
                                : 'Confirmar pago en efectivo',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color:
                                  (!_isValidForPay || processing)
                                      ? Colors.black
                                      : Colors.white,
                            ),
                          ),
                ),
              ),
            ),
            SizedBox(height: 14),
            // Footer SIEMPRE
            const AppFooter(),
          ],
        ),
      ),
    );
  }
}

// ======= Widgets auxiliares =======

class _MethodTile extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MethodTile({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : Colors.black87),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController cardCtrl;
  final TextEditingController expiryCtrl;
  final TextEditingController cvvCtrl;
  final bool saveCard;
  final ValueChanged<bool> onToggleSave;
  final ValueChanged<String> onCardChanged;
  final ValueChanged<String> onExpiryChanged;
  final VoidCallback onFormChanged;

  // Tupla de validadores (posicionales)
  final String? Function(String?) validators_name;
  final String? Function(String?) validators_card;
  final String? Function(String?) validators_exp;
  final String? Function(String?) validators_cvv;

  _CardForm({
    super.key,
    required this.formKey,
    required this.nameCtrl,
    required this.cardCtrl,
    required this.expiryCtrl,
    required this.cvvCtrl,
    required this.saveCard,
    required this.onToggleSave,
    required this.onCardChanged,
    required this.onExpiryChanged,
    required this.onFormChanged,
    required (
      String? Function(String?) name,
      String? Function(String?) card,
      String? Function(String?) exp,
      String? Function(String?) cvv,
    )
    validators,
  }) : validators_name = validators.$1,
       validators_card = validators.$2,
       validators_exp = validators.$3,
       validators_cvv = validators.$4;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        children: [
          TextFormField(
            controller: nameCtrl,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre del titular',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: validators_name,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onChanged: (_) => onFormChanged(),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: cardCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // solo números
              LengthLimitingTextInputFormatter(16), // máximo 16 dígitos
            ],
            decoration: const InputDecoration(
              labelText: 'Número de tarjeta',
              prefixIcon: Icon(Icons.credit_card),
              hintText: '1234 5678 9012 3456',
            ),
            // onChanged: onCardChanged,
            // validator: validators_card,
            onChanged: (v) {
              onCardChanged(v);
              onFormChanged(); // 👈
            },
          ),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: expiryCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d/]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Vencimiento',
                    hintText: 'MM/AA',
                    prefixIcon: Icon(Icons.date_range),
                  ),
                  // onChanged: onExpiryChanged,
                  // validator: validators_exp,
                  onChanged: (v) {
                    onExpiryChanged(v);
                    onFormChanged(); // 👈
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: cvvCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'CVV',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                  validator: validators_cvv,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (_) => onFormChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            value: saveCard,
            onChanged: onToggleSave,
            title: const Text('Guardar tarjeta para la próxima'),
            dense: true,
          ),
        ],
      ),
    );
  }
}

class _CashForm extends StatelessWidget {
  final TextEditingController cashCtrl;
  final String? Function(String?) validateCash;
  final double change;
  final ValueChanged<String>? onChanged;

  const _CashForm({
    super.key,
    required this.cashCtrl,
    required this.validateCash,
    required this.change,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        TextFormField(
          controller: cashCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          decoration: const InputDecoration(
            labelText: '¿Con cuánto pagas?',
            prefixIcon: Icon(Icons.attach_money),
            hintText: 'Ej: 100.00',
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validateCash,
          onChanged: onChanged, // notifica al padre para recalcular UI
        ),
        const SizedBox(height: 12),
        if (change > 0)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                const Icon(Icons.change_circle_outlined, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Cambio:',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  '\$${change.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
