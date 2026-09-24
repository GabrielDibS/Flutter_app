import 'package:flutter/material.dart';

import '../service/api_exceptions.dart';
import '../service/invertexto_service.dart';
import '../utils/resultado_formatter.dart';
import '../utils/validators.dart';
import '../widgets/carregando_view.dart';
import '../widgets/invertexto_scaffold.dart';
import '../widgets/mensagem_erro.dart';

const List<Map<String, String>> _estados = [
  {'sigla': '', 'nome': 'Todos (somente feriados nacionais)'},
  {'sigla': 'AC', 'nome': 'Acre'},
  {'sigla': 'AL', 'nome': 'Alagoas'},
  {'sigla': 'AP', 'nome': 'Amapá'},
  {'sigla': 'AM', 'nome': 'Amazonas'},
  {'sigla': 'BA', 'nome': 'Bahia'},
  {'sigla': 'CE', 'nome': 'Ceará'},
  {'sigla': 'DF', 'nome': 'Distrito Federal'},
  {'sigla': 'ES', 'nome': 'Espírito Santo'},
  {'sigla': 'GO', 'nome': 'Goiás'},
  {'sigla': 'MA', 'nome': 'Maranhão'},
  {'sigla': 'MT', 'nome': 'Mato Grosso'},
  {'sigla': 'MS', 'nome': 'Mato Grosso do Sul'},
  {'sigla': 'MG', 'nome': 'Minas Gerais'},
  {'sigla': 'PA', 'nome': 'Pará'},
  {'sigla': 'PB', 'nome': 'Paraíba'},
  {'sigla': 'PR', 'nome': 'Paraná'},
  {'sigla': 'PE', 'nome': 'Pernambuco'},
  {'sigla': 'PI', 'nome': 'Piauí'},
  {'sigla': 'RJ', 'nome': 'Rio de Janeiro'},
  {'sigla': 'RN', 'nome': 'Rio Grande do Norte'},
  {'sigla': 'RS', 'nome': 'Rio Grande do Sul'},
  {'sigla': 'RO', 'nome': 'Rondônia'},
  {'sigla': 'RR', 'nome': 'Roraima'},
  {'sigla': 'SC', 'nome': 'Santa Catarina'},
  {'sigla': 'SP', 'nome': 'São Paulo'},
  {'sigla': 'SE', 'nome': 'Sergipe'},
  {'sigla': 'TO', 'nome': 'Tocantins'},
];

class FeriadosPage extends StatefulWidget {
  const FeriadosPage({super.key});

  @override
  State<FeriadosPage> createState() => _FeriadosPageState();
}

class _FeriadosPageState extends State<FeriadosPage> {
  final _controller = TextEditingController(text: DateTime.now().year.toString());
  final _apiService = InvertextoApiService();
  String _estadoSelecionado = '';

  String? _erroValidacao;
  String? _erroApi;
  List<Map<String, dynamic>>? _feriados;
  bool _carregando = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _consultar() async {
    final erro = Validators.ano(_controller.text);
    setState(() => _erroValidacao = erro);
    if (erro != null) return;

    setState(() {
      _carregando = true;
      _erroApi = null;
      _feriados = null;
    });

    try {
      final dado = await _apiService.consultaFeriados(
        _controller.text.trim(),
        estado: _estadoSelecionado.isEmpty ? null : _estadoSelecionado,
      );
      final items = dado['items'];
      if (items is List && items.isNotEmpty) {
        setState(() {
          _feriados = items.cast<Map<String, dynamic>>();
        });
      } else {
        setState(() {
          _feriados = [];
          _erroApi = 'Nenhum feriado encontrado para esse ano/estado.';
        });
      }
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
      titulo: 'Feriados',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Ano (ex: 2026)',
              labelStyle: const TextStyle(color: Colors.white),
              border: const OutlineInputBorder(),
              errorText: _erroValidacao,
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
          DropdownButtonFormField<String>(
            initialValue: _estadoSelecionado,
            decoration: const InputDecoration(
              labelText: 'Estado (opcional)',
              labelStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(),
            ),
            dropdownColor: const Color(0xFF1A1A1A),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            items: _estados
                .map(
                  (e) => DropdownMenuItem(
                    value: e['sigla'],
                    child: Text(e['nome']!),
                  ),
                )
                .toList(),
            onChanged: _carregando
                ? null
                : (valor) => setState(() => _estadoSelecionado = valor ?? ''),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _carregando ? null : _consultar,
            child: const Text('Consultar feriados'),
          ),
          if (_carregando) const CarregandoView(mensagem: 'Consultando feriados...'),
          if (!_carregando && _erroApi != null) MensagemErro(mensagem: _erroApi!),
          if (!_carregando && _feriados != null && _feriados!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _feriados!.map((feriado) {
                  final campos = extrairCampos(feriado);
                  return Card(
                    color: const Color(0xFF1A1A1A),
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: campos
                            .map(
                              (c) => Text(
                                '${c.rotulo}: ${c.valor}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
