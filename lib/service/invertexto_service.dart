import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exceptions.dart';

class InvertextoApiService {
  static const String _baseUrl = 'api.invertexto.com';
  final String _token = '28487|1pabQpspgb54koHiubLxvk6mvtqU2KJL';
  static const Duration _timeout = Duration(seconds: 15);

  Future<Map<String, dynamic>> convertePorExtenso(String numero) {
    final uri = Uri.https(_baseUrl, '/v1/number-to-words', {
      'token': _token,
      'number': numero,
      'language': 'pt',
      'currency': 'BRL',
    });
    return _get(uri);
  }

  Future<Map<String, dynamic>> buscaCEP(String cep) {
    final numeros = cep.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.https(_baseUrl, '/v1/cep/$numeros', {'token': _token});
    return _get(uri);
  }

  Future<Map<String, dynamic>> validaDocumento(String valor) {
    final numeros = valor.replaceAll(RegExp(r'[^0-9]'), '');
    final tipo = numeros.length == 14 ? 'cnpj' : 'cpf';
    final uri = Uri.https(_baseUrl, '/v1/validator', {
      'token': _token,
      'value': numeros,
      'type': tipo,
    });
    return _get(uri);
  }

  Future<Map<String, dynamic>> consultaFeriados(String ano, {String? estado}) {
    final uri = Uri.https(_baseUrl, '/v1/holidays/$ano', {
      'token': _token,
      if (estado != null && estado.trim().isNotEmpty) 'state': estado.trim(),
    });
    return _get(uri);
  }

  Future<Map<String, dynamic>> validaEmail(String email) {
    final uri = Uri.https(_baseUrl, '/v1/email-validator/${email.trim()}', {
      'token': _token,
    });
    return _get(uri);
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    http.Response response;
    try {
      response = await http.get(uri).timeout(_timeout);
    } on SocketException {
      throw const ConnectionException();
    } on TimeoutException {
      throw const ConnectionException(
        'A consulta demorou demais para responder. Verifique sua conexão e tente novamente.',
      );
    } on HttpException {
      throw const ConnectionException();
    }

    switch (response.statusCode) {
      case 200:
        return _decodifica(response.body);
      case 400:
        throw const ApiException(
          'Requisição inválida. Confira os dados informados e tente novamente.',
          statusCode: 400,
        );
      case 401:
      case 403:
        throw ApiException(
          'Acesso negado pela API (token inválido ou sem permissão para essa consulta).',
          statusCode: response.statusCode,
        );
      case 404:
        throw const ApiException(
          'Nenhum resultado encontrado para essa consulta.',
          statusCode: 404,
        );
      case 429:
        throw const ApiException(
          'Limite de requisições da API atingido. Tente novamente mais tarde.',
          statusCode: 429,
        );
      default:
        if (response.statusCode >= 500) {
          throw ApiException(
            'O servidor da API está indisponível no momento (código ${response.statusCode}). Tente novamente mais tarde.',
            statusCode: response.statusCode,
          );
        }
        throw ApiException(
          'Erro ao consultar a API (código ${response.statusCode}).',
          statusCode: response.statusCode,
        );
    }
  }

  Map<String, dynamic> _decodifica(String corpo) {
    if (corpo.trim().isEmpty) {
      throw const ApiException('A API retornou uma resposta vazia.');
    }

    dynamic decodificado;
    try {
      decodificado = json.decode(corpo);
    } on FormatException {
      throw const ApiException('A API retornou dados em um formato inesperado.');
    }

    if (decodificado == null) {
      throw const ApiException('A API não retornou dados para essa consulta.');
    }
    if (decodificado is Map<String, dynamic>) {
      if (decodificado.isEmpty) {
        throw const ApiException('Nenhum dado encontrado para essa consulta.');
      }
      return decodificado;
    }
    if (decodificado is List) {
      if (decodificado.isEmpty) {
        throw const ApiException('Nenhum dado encontrado para essa consulta.');
      }
      // Algumas APIs (ex: feriados) retornam uma lista diretamente.
      // Padronizamos em um mapa para o restante do app tratar de forma única.
      return {
        'items': decodificado
            .whereType<Map<String, dynamic>>()
            .toList(growable: false),
      };
    }
    // Valor "solto" (string/num/bool) — também padronizamos em um mapa.
    return {'resultado': decodificado};
  }
}
