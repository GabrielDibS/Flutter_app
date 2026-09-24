import 'package:flutter/material.dart';

class CarregandoView extends StatelessWidget {
  final String mensagem;

  const CarregandoView({
    super.key,
    this.mensagem = 'Consultando, aguarde...',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 4.0,
          ),
          const SizedBox(height: 12),
          Text(
            mensagem,
            style: const TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
