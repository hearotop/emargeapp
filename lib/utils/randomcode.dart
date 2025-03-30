import 'dart:math';

class RandomCode {
  static String generate(int length) {
    const String chars = '0123456789';
    final Random random = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }
}
