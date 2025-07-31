String numberToWords(double value) {
  final units = [
    'zero',
    'um',
    'dois',
    'três',
    'quatro',
    'cinco',
    'seis',
    'sete',
    'oito',
    'nove',
    'dez',
    'onze',
    'doze',
    'treze',
    'catorze',
    'quinze',
    'dezesseis',
    'dezessete',
    'dezoito',
    'dezenove',
  ];

  final tens = [
    '',
    '',
    'vinte',
    'trinta',
    'quarenta',
    'cinquenta',
    'sessenta',
    'setenta',
    'oitenta',
    'noventa',
  ];

  final hundreds = [
    '',
    'cem',
    'duzentos',
    'trezentos',
    'quatrocentos',
    'quinhentos',
    'seiscentos',
    'setecentos',
    'oitocentos',
    'novecentos',
  ];

  int real = value.toInt();
  int cents = ((value - real) * 100).round();

  String convert(int number) {
    if (number < 20) return units[number];

    if (number < 100) {
      return tens[number ~/ 10] +
          ((number % 10 != 0) ? ' e ${units[number % 10]}' : '');
    }

    if (number < 1000) {
      if (number == 100) return 'cem';
      return hundreds[number ~/ 100] +
          ((number % 100 != 0) ? ' e ${convert(number % 100)}' : '');
    }

    if (number < 1000000) {
      final thousand = convert(number ~/ 1000);
      final remainder = number % 1000;
      return '$thousand mil${remainder != 0 ? ' e ${convert(remainder)}' : ''}';
    }

    return 'valor muito alto';
  }

  String result = convert(real);

  // Ajustes gramaticais para PT-BR
  if (real == 1) {
    result += ' real';
  } else if (real > 1) {
    result += ' reais';
  }

  if (cents > 0) {
    result += ' e ${convert(cents)}';
    result += (cents == 1) ? ' centavo' : ' centavos';
  }

  // Capitaliza a primeira letra
  if (result.isNotEmpty) {
    result = result[0].toUpperCase() + result.substring(1);
  }

  return result;
}
