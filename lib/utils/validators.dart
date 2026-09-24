class Validators {
  Validators._();

  static String? campoObrigatorio(
    String? valor, {
    String mensagem = 'Este campo é obrigatório.',
  }) {
    if (valor == null || valor.trim().isEmpty) {
      return mensagem;
    }
    return null;
  }

  static String _apenasNumeros(String valor) =>
      valor.replaceAll(RegExp(r'[^0-9]'), '');

  static String? cep(String? valor) {
    final obrigatorio = campoObrigatorio(valor, mensagem: 'Informe um CEP.');
    if (obrigatorio != null) return obrigatorio;

    final numeros = _apenasNumeros(valor!);
    if (numeros.length != 8) {
      return 'CEP inválido. Digite os 8 números do CEP (ex: 85040-080).';
    }
    return null;
  }

  static String? numero(String? valor) {
    final obrigatorio = campoObrigatorio(valor, mensagem: 'Informe um número.');
    if (obrigatorio != null) return obrigatorio;

    final normalizado = valor!.trim().replaceAll(',', '.');
    if (num.tryParse(normalizado) == null) {
      return 'Digite apenas números (ex: 1250 ou 1250,90).';
    }
    return null;
  }

  static String? cpfOuCnpj(String? valor) {
    final obrigatorio =
        campoObrigatorio(valor, mensagem: 'Informe um CPF ou CNPJ.');
    if (obrigatorio != null) return obrigatorio;

    final numeros = _apenasNumeros(valor!);
    if (numeros.length != 11 && numeros.length != 14) {
      return 'Digite um CPF (11 dígitos) ou um CNPJ (14 dígitos).';
    }
    return null;
  }

  static String? ano(String? valor) {
    final obrigatorio = campoObrigatorio(valor, mensagem: 'Informe um ano.');
    if (obrigatorio != null) return obrigatorio;

    final texto = valor!.trim();
    final numero = int.tryParse(texto);
    if (numero == null || texto.length != 4) {
      return 'Digite um ano válido com 4 dígitos (ex: 2026).';
    }
    if (numero < 1900 || numero > 2100) {
      return 'Digite um ano entre 1900 e 2100.';
    }
    return null;
  }

  static String? email(String? valor) {
    final obrigatorio = campoObrigatorio(valor, mensagem: 'Informe um e-mail.');
    if (obrigatorio != null) return obrigatorio;

    final texto = valor!.trim();
    final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(texto)) {
      return 'Digite um e-mail em um formato válido (ex: nome@dominio.com).';
    }
    return null;
  }
}
