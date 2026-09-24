library;

class ConnectionException implements Exception {
  final String message;
  const ConnectionException([
    this.message = 'Sem conexão com a internet. Verifique sua rede e tente novamente.',
  ]);

  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
