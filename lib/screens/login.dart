// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'start_order_page.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginGreenPage(),
    ),
  );
}

class LoginGreenPage extends StatefulWidget {
  const LoginGreenPage({super.key});

  @override
  State<LoginGreenPage> createState() => _LoginGreenPageState();
}

class _LoginGreenPageState extends State<LoginGreenPage> {
  int currentTab = 0; // 0 = Existing, 1 = New
  bool obscure = true;

  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // Paleta verde
  final Color green = const Color(0xFF1ABC9C);
  final Color greenDark = const Color(0xFF0F9D85);
  final Color greenDeep = const Color(0xFF0B7C69);

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int dir = currentTab == 1 ? 1 : -1;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [green, greenDark, greenDeep],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Ícono/ilustración superior (opcional)
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white, //fondo blanco
                      border: Border.all(
                        color:
                            Colors
                                .white, //marco blanco (puedes cambiar color)
                        width: 6, // grosor del marco
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/logomix.png',
                        width: 100,
                        height: 100,
                        fit:
                            BoxFit
                                .contain, // mantiene proporciones sin recortar
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tabs Existing / New
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.25),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: Row(
                      children: [
                        _Segment(
                          label: 'Login',
                          selected: currentTab == 0,
                          onTap: () => setState(() => currentTab = 0),
                        ),
                        _Segment(
                          label: 'Register',
                          selected: currentTab == 1,
                          onTap: () => setState(() => currentTab = 1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Tarjeta blanca (fija)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(.08),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Contenido con barrido
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) {
                            // Barrido + desvanecido
                            final slide = Tween<Offset>(
                              begin: Offset(
                                dir.toDouble(),
                                0,
                              ), // 1 → entra desde derecha, -1 → desde izquierda
                              end: Offset.zero,
                            ).animate(animation);

                            return ClipRect(
                              child: FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: slide,
                                  child: child,
                                ),
                              ),
                            );
                          },
                          // Cambiamos la key para que AnimatedSwitcher sepa que es "otra vista"
                          child: _FormContent(
                            key: ValueKey(currentTab),
                            isNew: currentTab == 1,
                            nameCtrl: nameCtrl,
                            emailCtrl: emailCtrl,
                            passCtrl: passCtrl,
                            obscure: obscure,
                            onToggleObscure:
                                () => setState(() => obscure = !obscure),
                            green: green,
                            greenDark: greenDark,
                            onSubmit: () {
                              if (currentTab == 0) {
                              } else {}
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormContent extends StatelessWidget {
  final bool isNew;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final Color green;
  final Color greenDark;
  final VoidCallback onSubmit;

  const _FormContent({
    super.key,
    required this.isNew,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.green,
    required this.greenDark,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      children: [
        if (isNew) ...[
          _InputField(
            label: 'Name',
            icon: Icons.person_outline,
            controller: nameCtrl,
          ),
          const SizedBox(height: 14),
        ],

        _InputField(
          label: 'Email Address',
          icon: Icons.mail_outline,
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),

        _InputField(
          label: 'Password',
          icon: Icons.lock_outline,
          controller: passCtrl,
          obscure: obscure,
          trailing: IconButton(
            onPressed: onToggleObscure,
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
          ),
        ),

        const SizedBox(height: 18),

        // Botón principal
        SizedBox(
          width: double.infinity,
          height: 52,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [green, greenDark],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),

            child: ElevatedButton(
              onPressed: () {
                if (!isNew) {
                  // Solo si es LOGIN
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StartOrderPage()),
                  );
                } else {
                  // Aquí puedes poner tu lógica de registro
                  debugPrint(
                    "Crear cuenta con ${nameCtrl.text}, ${emailCtrl.text}",
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                isNew ? 'CREATE ACCOUNT' : 'LOGIN',
                style: const TextStyle(
                  letterSpacing: 1,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Forgot
        GestureDetector(
          onTap: () {},
          child: Text(
            'Forgot Password?',
            style: TextStyle(
              color: const Color(0xFF0B7C69),
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 18),

        // Divider "Or"
        Row(
          children: [
            Expanded(child: Divider(color: Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text('Or', style: TextStyle(color: Colors.grey.shade600)),
            ),
            Expanded(child: Divider(color: Colors.grey.shade300)),
          ],
        ),

        const SizedBox(height: 14),

        // Social
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialCircle(
              child: const Icon(Icons.facebook, size: 26, color: Colors.blue),
              onTap: () {
              },
            ),
            const SizedBox(width: 16),
            _SocialCircle(
              child: const Icon(
                Icons.g_mobiledata,
                size: 30,
                color: Colors.red,
              ),
              onTap: () {
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    // ignore: unused_element_parameter
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black87 : Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? trailing;

  const _InputField({
    // ignore: unused_element_parameter
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.keyboardType,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: trailing,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _SocialCircle extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  // ignore: unused_element_parameter
  const _SocialCircle({required this.child, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
