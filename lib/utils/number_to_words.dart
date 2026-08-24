class NumberToWords {
  static const List<String> ones = [
    '',
    'One',
    'Two',
    'Three',
    'Four',
    'Five',
    'Six',
    'Seven',
    'Eight',
    'Nine',
    'Ten',
    'Eleven',
    'Twelve',
    'Thirteen',
    'Fourteen',
    'Fifteen',
    'Sixteen',
    'Seventeen',
    'Eighteen',
    'Nineteen'
  ];

  static const List<String> tens = [
    '',
    '',
    'Twenty',
    'Thirty',
    'Forty',
    'Fifty',
    'Sixty',
    'Seventy',
    'Eighty',
    'Ninety'
  ];

  static String convert(double number) {
    if (number == 0) return 'Zero Rupees Only';

    int rupees = number.toInt();
    int paise = ((number - rupees) * 100).round();

    String result = '';

    if (rupees > 0) {
      result = _convertNumber(rupees) + ' Rupees';
    }

    if (paise > 0) {
      if (result.isNotEmpty) result += ' and ';
      result += _convertNumber(paise) + ' Paise';
    }

    return result + ' Only';
  }

  static String _convertNumber(int number) {
    if (number == 0) return '';

    if (number < 20) {
      return ones[number];
    }

    if (number < 100) {
      return tens[number ~/ 10] +
          (number % 10 != 0 ? ' ' + ones[number % 10] : '');
    }

    if (number < 1000) {
      return ones[number ~/ 100] +
          ' Hundred' +
          (number % 100 != 0 ? ' ' + _convertNumber(number % 100) : '');
    }

    if (number < 100000) {
      return _convertNumber(number ~/ 1000) +
          ' Thousand' +
          (number % 1000 != 0 ? ' ' + _convertNumber(number % 1000) : '');
    }

    if (number < 10000000) {
      return _convertNumber(number ~/ 100000) +
          ' Lakh' +
          (number % 100000 != 0 ? ' ' + _convertNumber(number % 100000) : '');
    }

    return _convertNumber(number ~/ 10000000) +
        ' Crore' +
        (number % 10000000 != 0 ? ' ' + _convertNumber(number % 10000000) : '');
  }
}
