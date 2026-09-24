import 'package:flutter/material.dart';

import '../service/api_exceptions.dart';
import '../service/invertexto_service.dart';
import '../utils/validators.dart';
import '../widgets/carregando_view.dart';
import '../widgets/invertexto_scaffold.dart';
import '../widgets/mensagem_erro.dart';
import '../widgets/resultado_card.dart';

class BuscaCepPage extends StatefulWidget {
  const BuscaCepPage({super.key});

  @override
  State<BuscaCepPage> createState() => _BuscaCepPageState();
}

class _BuscaCepPageState extends State<BuscaCepPage> {
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

  Future<void> _consultar() async {
    final erro = Validators.cep(_controller.text);
    setState(() => _erroValidacao = erro);
    if (erro != null) return;

    setState(() {
      _carregando = true;
      _erroApi = null;
      _resultado = null;
    });

    try {
      final dado = await _apiService.buscaCEP(_controller.text.trim());
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
    return InvertextoScaffold(
      titulo: 'Busca CEP',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Digite o CEP',
              labelStyle: const TextStyle(color: Colors.white),
              border: const OutlineInputBorder(),
              errorText: _erroValidacao,
              hintText: '85040-080',
              hintStyle: const TextStyle(color: Colors.white38),
            ),
            keyboardType: TextInputType.number,
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
            child: const Text('Buscar'),
          ),
          if (_carregando) const CarregandoView(mensagem: 'Buscando endereço...'),
          if (!_carregando && _erroApi != null) MensagemErro(mensagem: _erroApi!),
          if (!_carregando && _erroApi == null)
            ResultadoCard(
              dados: _resultado,
              ignorar: const ['token', 'ibge', 'gia', 'ddd', 'siafi'],
              mensagemVazio: 'Digite um CEP e toque em "Buscar".',
            ),
        ],
      ),
    );
  }
}
