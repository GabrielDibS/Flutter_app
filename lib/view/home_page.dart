import 'package:flutter/material.dart';

import 'busca_cep_page.dart';
import 'feriados_page.dart';
import 'por_extenso_page.dart';
import 'valida_cpf_page.dart';
import 'valida_email_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/imgs/logo.png',
              fit: BoxFit.contain,
              height: 40,
            ),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            _ItemMenu(
              icone: Icons.edit,
              titulo: 'Por Extenso',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PorExtensoPage()),
              ),
            ),
            _ItemMenu(
              icone: Icons.markunread_mailbox,
              titulo: 'Busca CEP',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuscaCepPage()),
              ),
            ),
            _ItemMenu(
              icone: Icons.badge,
              titulo: 'Valida CPF/CNPJ',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ValidaCpfPage()),
              ),
            ),
            _ItemMenu(
              icone: Icons.event,
              titulo: 'Feriados',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeriadosPage()),
              ),
            ),
            _ItemMenu(
              icone: Icons.alternate_email,
              titulo: 'Valida E-mail',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ValidaEmailPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemMenu extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final VoidCallback onTap;

  const _ItemMenu({
    required this.icone,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icone, color: Colors.white, size: 50.0),
            const SizedBox(width: 30),
            Text(
              titulo,
              style: const TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}
