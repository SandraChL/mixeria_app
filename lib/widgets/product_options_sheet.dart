// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';

class OptionItem {
  final String id;
  final String label;
  const OptionItem(this.id, this.label);
}

class ExtraItem {
  final String id;
  final String label;
  final double price;
  const ExtraItem(this.id, this.label, this.price);
}

class ProductCustomization {
  final String? baseId;              // selección simple
  final List<String> toppingIds;     // selección múltiple con límite
  final List<ExtraItem> extras;      // extras seleccionados con precio
  final List<String> sauceIds;       // salsas (sin precio)
  final bool conTodo;                //“Con todo”

  const ProductCustomization({
    this.baseId,
    this.toppingIds = const [],
    this.extras = const [],
    this.sauceIds = const [],
    this.conTodo = false,
  });

  double get extrasTotal => extras.fold(0.0, (acc, e) => acc + e.price);
}

/// Modal: Base (1), Toppings (multi c/ límite), Extras (con precio), Salsas (sin precio), Con Todo
Future<ProductCustomization?> showProductOptionsSheet(
  BuildContext context, {
  required String productTitle,
  required List<OptionItem> bases,
  required List<OptionItem> toppings,
  required List<ExtraItem> extras,
  List<OptionItem> sauces = const [],
  int maxToppings = 1,
  String baseLabel = 'Base',

  // 👇 NUEVOS parámetros para “con todo”
  bool showConTodo = false,
  String conTodoText = 'Con todo (mayonesa, queso y chile en polvo)',
}) async {
  assert(maxToppings >= 0);

  return await showModalBottomSheet<ProductCustomization>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      String? baseSel = bases.isNotEmpty ? bases.first.id : null;
      final Set<String> toppingSel = <String>{};
      final Set<String> extraSel = <String>{};
      final Set<String> sauceSel = <String>{};
      bool conTodo = false; // 👈 estado local

      final bottom = MediaQuery.of(ctx).viewInsets.bottom;

      return Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // handle
                  Center(
                    child: Container(
                      width: 36, height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    productTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),

                  // Base
                  if (bases.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(baseLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    _RoundedDropdown<String>(
                      value: baseSel,
                      items: bases.map((e) =>
                        DropdownMenuItem(value: e.id, child: Text(e.label))
                      ).toList(),
                      onChanged: (v) => baseSel = v,
                    ),
                  ],

                  // Toppings
                  if (toppings.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _RoundedExpansion(
                      title: Row(
                        children: [
                          const Text('Toppings', style: TextStyle(fontWeight: FontWeight.w600)),
                          const Spacer(),
                          StatefulBuilder(
                            builder: (_, __) => Text(
                              '${toppingSel.length}/$maxToppings',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        StatefulBuilder(
                          builder: (context, setSB) {
                            final atLimit = toppingSel.length >= maxToppings;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: toppings.length,
                              itemBuilder: (_, i) {
                                final opt = toppings[i];
                                final selected = toppingSel.contains(opt.id);
                                final disabled = !selected && atLimit;
                                return CheckboxListTile(
                                  value: selected,
                                  onChanged: disabled ? null : (val) {
                                    if (selected) toppingSel.remove(opt.id);
                                    else if (!atLimit) toppingSel.add(opt.id);
                                    setSB(() {});
                                  },
                                  title: Text(opt.label),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  dense: true,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],

                  // Extras con precio
                  if (extras.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _RoundedExpansion(
                      title: const Text('Ingredientes extra (con costo)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      children: [
                        StatefulBuilder(
                          builder: (context, setSB) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: extras.length,
                              itemBuilder: (_, i) {
                                final ex = extras[i];
                                final selected = extraSel.contains(ex.id);
                                return CheckboxListTile(
                                  value: selected,
                                  onChanged: (val) {
                                    if (selected) extraSel.remove(ex.id);
                                    else extraSel.add(ex.id);
                                    setSB(() {});
                                  },
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(ex.label, overflow: TextOverflow.ellipsis)),
                                      const SizedBox(width: 8),
                                      Text('\$${ex.price.toStringAsFixed(0)}'),
                                    ],
                                  ),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  dense: true,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],

                  // Salsas sin costo
                  if (sauces.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _RoundedExpansion(
                      title: const Text('Salsas (sin costo)',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      children: [
                        StatefulBuilder(
                          builder: (context, setSB) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: sauces.length,
                              itemBuilder: (_, i) {
                                final s = sauces[i];
                                final selected = sauceSel.contains(s.id);
                                return CheckboxListTile(
                                  value: selected,
                                  onChanged: (val) {
                                    if (selected) sauceSel.remove(s.id);
                                    else sauceSel.add(s.id);
                                    setSB(() {});
                                  },
                                  title: Text(s.label),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  dense: true,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ],

                  // “Con todo” (sin costo)
                  if (showConTodo) ...[
                    const SizedBox(height: 16),
                    StatefulBuilder(
                      builder: (context, setSB) {
                        return SwitchListTile(
                          value: conTodo,
                          onChanged: (v) => setSB(() => conTodo = v),
                          title: Text(conTodoText),
                          dense: true,
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                            side: BorderSide(color: Colors.red.shade200),
                          ),
                          onPressed: () => Navigator.pop(ctx, null),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF5A623),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            final selectedExtras = extras
                                .where((e) => extraSel.contains(e.id))
                                .toList();
                            Navigator.pop(
                              ctx,
                              ProductCustomization(
                                baseId: baseSel,
                                toppingIds: toppingSel.toList(),
                                extras: selectedExtras,
                                sauceIds: sauceSel.toList(),
                                conTodo: conTodo, // 👈 devolver
                              ),
                            );
                          },
                          label: const Text('Agregar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// ---- UI helpers ----
class _RoundedDropdown<T> extends StatefulWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _RoundedDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<_RoundedDropdown<T>> createState() => _RoundedDropdownState<T>();
}

class _RoundedDropdownState<T> extends State<_RoundedDropdown<T>> {
  late T? _value = widget.value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: _value,
          items: widget.items,
          onChanged: (v) {
            setState(() => _value = v);
            widget.onChanged(v);
          },
        ),
      ),
    );
  }
}

class _RoundedExpansion extends StatelessWidget {
  final Widget title;
  final List<Widget> children;
  const _RoundedExpansion({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          title: title,
          children: children,
        ),
      ),
    );
  }
}
