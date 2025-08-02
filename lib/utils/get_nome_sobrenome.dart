/// Extrai apenas os dois primeiros nomes do membro
String getNomeSobrenome(String nomeCompleto) {
  final nomes = nomeCompleto.trim().split(' ');
  if (nomes.length <= 2) {
    return nomeCompleto;
  }
  return '${nomes[0]} ${nomes[1]}';
}
