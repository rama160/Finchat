import '../parsing/money_amount_parser.dart';
import '../parsing/spoken_money_normalizer.dart';

/// Android may return cumulative hypotheses or only the latest phrase.
/// Keep completed phrases; replace revisions of the current phrase.
class TranscriptBuffer {
  String _completed = '';
  String _current = '';
  String get text => _join(_completed, _current);

  void clear() { _completed = ''; _current = ''; }

  void add(String value, {required bool isFinal}) {
    final next = value.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (next.isEmpty) return;
    if (_completed.isNotEmpty && next.toLowerCase().startsWith(_completed.toLowerCase())) {
      _current = next.substring(_completed.length).replaceFirst(RegExp(r'^[,;\s]+'), '').trim();
    } else {
      final previous = _current.toLowerCase();
      final incoming = next.toLowerCase();
      final samePhrase = previous.isEmpty || incoming.startsWith(previous) ||
          previous.startsWith(incoming) || previous.split(' ').first == incoming.split(' ').first;
      if (!samePhrase && MoneyAmountParser.findAll(normalizeVoiceTransactions(_current)).isNotEmpty) {
        _completed = _join(_completed, _current);
      }
      _current = next;
    }
    if (isFinal) { _completed = text; _current = ''; }
  }

  static String _join(String first, String second) {
    if (first.isEmpty) return second;
    if (second.isEmpty) return first;
    final a = first.toLowerCase(), b = second.toLowerCase();
    if (a == b || a.endsWith(' $b')) return first;
    if (b.startsWith(a)) return second;
    final left = first.split(' '), right = second.split(' ');
    for (var count = left.length < right.length ? left.length : right.length; count > 0; count--) {
      if (left.sublist(left.length - count).join(' ').toLowerCase() == right.take(count).join(' ').toLowerCase()) {
        return [...left, ...right.skip(count)].join(' ');
      }
    }
    return '$first, $second';
  }
}
