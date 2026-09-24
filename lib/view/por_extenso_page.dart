import 'package:flutter/material.dart';

import '../service/api_exceptions.dart';
import '../service/invertexto_service.dart';
import '../utils/validators.dart';
import '../widgets/carregando_view.dart';
import '../widgets/invertexto_scaffold.dart';
import '../widgets/mensagem_erro.dart';

class PorExtensoPage extends StatefulWidget {
  const PorExtensoPage({super.key});

  @override
  State<PorExtensoPage> createState() => _PorExtensoPageState();
}

class _PorExtensoPageState extends State<PorExtensoPage> {
  final _controller = TextEditingController();
  final _apiService = InvertextoApiService();

  String? _erroValidacao;
  String? _erroApi;
  String? _resultado;
  bool _carregando = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _consultar() async {
    final erro = Validators.numero(_controller.text);
    setState(() => _erroValidacao = erro);
    if (erro != null) return;

    setState(() {
      _carregando = true;
      _erroApi = null;
      _resultado = null;
    });

    try {
      final dado = await _apiService.convertePorExtenso(_controller.text.trim());
      final texto = dado['text'];
      setState(() {
        _resultado = texto is String && texto.isNotEmpty
            ? texto
            : null;
        if (_resultado == null) {
          _erroApi = 'A API não retornou o texto por extenso para esse número.';
        }
      });
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
    return InvertextoScaffold(
      titulo: 'Número por Extenso',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Digite um número',
              labelStyle: const TextStyle(color: Colors.white),
              border: const OutlineInputBorder(),
              errorText: _erroValidacao,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 18),
            enabled: !_carregando,
            onSubmitted: (_) => _consultar(),
            onChanged: (_) {
              if (_erroValidacao != null) setState(() => _erroValidacao = null);
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _carregando ? null : _consultar,
            child: const Text('Converter'),
          ),
          if (_carregando) const CarregandoView(mensagem: 'Convertendo número...'),
          if (!_carregando && _erroApi != null) MensagemErro(mensagem: _erroApi!),
          if (!_carregando && _resultado != null)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(
                _resultado!,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                softWrap: true,
              ),
            ),
        ],
      ),
    );
  }
}
