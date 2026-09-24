import 'package:flutter/material.dart';
import '../utils/resultado_formatter.dart';

class ResultadoCard extends StatelessWidget {
  final Map<String, dynamic>? dados;
  final List<String> ignorar;
  final String mensagemVazio;

  const ResultadoCard({
    super.key,
    required this.dados,
    this.ignorar = const [],
    this.mensagemVazio = 'Nenhuma informação encontrada para essa consulta.',
  });

  @override
  Widget build(BuildContext context) {
    final dadosAtuais = dados;
    if (dadosAtuais == null || dadosAtuais.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Text(
          mensagemVazio,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
      );
    }

    final campos = extrairCampos(dadosAtuais, ignorar: ignorar);
    if (campos.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Text(
          mensagemVazio,
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
      );
    }

    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(top: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: campos
              .map(
                (campo) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      children: [
                        TextSpan(
                          text: '${campo.rotulo}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: campo.valor),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
