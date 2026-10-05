import '../../domain/parsing/money_amount_parser.dart';
import '../../domain/parsing/spoken_money_normalizer.dart';

enum InputIntent { transaction, question }

InputIntent detectInputIntent(String input) {
  final text = input.toLowerCase().trim();
  // Questions may contain money, e.g. "Apakah anggaran 2 juta cukup?".
  if (text.endsWith('?') || RegExp(r'^(berapa|apa|apakah|bagaimana|kenapa|mengapa|kapan|siapa|tolong jelaskan|jelaskan|bandingkan|analisis)\b').hasMatch(text)) {
    return InputIntent.question;
  }
  if (MoneyAmountParser.findAll(normalizeSpokenMoney(input)).isNotEmpty) return InputIntent.transaction;
  return InputIntent.question;
}
