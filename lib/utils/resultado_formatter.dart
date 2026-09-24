class CampoResultado {
  final String rotulo;
  final String valor;
  const CampoResultado(this.rotulo, this.valor);
}

String _formatarRotulo(String chave) {
  final comEspacos = chave.replaceAll('_', ' ');
  if (comEspacos.isEmpty) return comEspacos;
  return comEspacos[0].toUpperCase() + comEspacos.substring(1);
}

String _formatarValor(dynamic valor) {
  if (valor is bool) return valor ? 'Sim' : 'Não';
  return valor.toString();
}

List<CampoResultado> extrairCampos(
  Map<String, dynamic> dado, {
  List<String> ignorar = const [],
}) {
  final campos = <CampoResultado>[];
  dado.forEach((chave, valor) {
    if (ignorar.contains(chave)) return;
    if (valor == null) return;
    if (valor is Map || valor is List) return;
    campos.add(CampoResultado(_formatarRotulo(chave), _formatarValor(valor)));
  });
  return campos;
}
