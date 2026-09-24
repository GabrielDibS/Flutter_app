import 'package:flutter/material.dart';

import '../service/api_exceptions.dart';
import '../service/invertexto_service.dart';
import '../utils/validators.dart';
import '../widgets/carregando_view.dart';
import '../widgets/invertexto_scaffold.dart';
import '../widgets/mensagem_erro.dart';
import '../widgets/resultado_card.dart';

class ValidaCpfPage extends StatefulWidget {
  const ValidaCpfPage({super.key});

  @override
  State<ValidaCpfPage> createState() => _ValidaCpfPageState();
}

class _ValidaCpfPageState extends State<ValidaCpfPage> {
  final _controller = TextEditingController();
  final _apiService = InvertextoApiService();

  String? _erroValidacao;
  String? _erroApi;
  Map<String, dynamic>? _resultado;
  bool _carregando = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool? _extraiValido(Map<String, dynamic> dado) {
    for (final chave in ['valid', 'is_valid', 'isValid', 'valido']) {
      final v = dado[chave];
      if (v is bool) return v;
      if (v is String) return v.toLowerCase() == 'true';
    }
    return null;
  }

  Future<void> _consultar() async {
    final erro = Validators.cpfOuCnpj(_controller.text);
    setState(() => _erroValidacao = erro);
    if (erro != null) return;

    setState(() {
      _carregando = true;
      _erroApi = null;
      _resultado = null;
    });

    try {
      final dado = await _apiService.validaDocumento(_controller.text.trim());
      setState(() => _resultado = dado);
    } on ConnectionException catch (e) {
      setState(() => _erroApi = e.toString());
    } on ApiException catch (e) {
      setState(() => _erroApi = e.toString());
    } catch (_) {
      setState(() => _erroApi = 'Ocorreu um erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final numeros = _controller.text.replaceAll(RegExp(r'[^0-9]'), '');
    final tipoDetectado = numeros.length == 14 ? 'CNPJ' : 'CPF';

    return InvertextoScaffold(
      titulo: 'Valida CPF/CNPJ',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Digite o CPF ou CNPJ',
              labelStyle: const TextStyle(color: Colors.white),
              border: const OutlineInputBorder(),
              errorText: _erroValidacao,
              helperText: 'Somente números (CPF: 11 dígitos · CNPJ: 14 dígitos)',
              helperStyle: const TextStyle(color: Colors.white38),
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            enabled: !_carregando,
            onSubmitted: (_) => _consultar(),
            onChanged: (_) => setState(() {
              if (_erroValidacao != null) _erroValidacao = null;
            }),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _carregando ? null : _consultar,
            child: Text(
              numeros.isEmpty ? 'Validar' : 'Validar $tipoDetectado',
            ),
          ),
          if (_carregando) const CarregandoView(mensagem: 'Validando documento...'),
          if (!_carregando && _erroApi != null) MensagemErro(mensagem: _erroApi!),
          if (!_carregando && _erroApi == null && _resultado != null) ...[
            Builder(builder: (context) {
              final valido = _extraiValido(_resultado!);
              if (valido == null) {
                return ResultadoCard(dados: _resultado);
              }
              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 16.0),
                padding: const EdgeInsets.all(14.0),
                decoration: BoxDecoration(
                  color: (valido ? Colors.green : Colors.redAccent)
                      .withValues(alpha: 0.15),
                  border: Border.all(
                    color: valido ? Colors.green : Colors.redAccent,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      valido ? Icons.check_circle : Icons.cancel,
                      color: valido ? Colors.green : Colors.redAccent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        valido
                            ? '$tipoDetectado válido.'
                            : '$tipoDetectado inválido.',
                        style: TextStyle(
                          color: valido ? Colors.green : Colors.redAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
