import 'local_transaction_parser.dart';

enum InputIntent { transaction, question }

InputIntent detectInputIntent(String input) {
  final text = input.toLowerCase().trim();
  // Questions may contain money, e.g. "Apakah anggaran 2 juta cukup?".
  if (text.endsWith('?') || RegExp(r'^(berapa|apa|apakah|bagaimana|kenapa|mengapa|kapan|siapa|tolong jelaskan|jelaskan|bandingkan|analisis)\b').hasMatch(text)) {
    return InputIntent.question;
  }
  if (LocalTransactionParser().parse(input).isNotEmpty) return InputIntent.transaction;
  return InputIntent.question;
}
