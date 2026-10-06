import 'package:flutter/material.dart';
import '../../domain/reports/selected_period.dart';
import 'spenva_brand.dart';

class PeriodFilter extends StatelessWidget {
  const PeriodFilter({super.key, required this.period, required this.onChanged, this.allowAll = false});
  final SelectedPeriod period;
  final ValueChanged<SelectedPeriod> onChanged;
  final bool allowAll;

  bool _canShift(int direction) {
    if (period.kind == PeriodKind.all) return false;
    final shifted = period.shift(direction);
    return shifted.start!.year >= 2000 && shifted.end!.year <= 2100;
  }

  Future<void> _pick(BuildContext context) async {
    final value = await showDialog<SelectedPeriod>(
      context: context,
      builder: (_) => PeriodCalendarDialog(period: period, allowAll: allowAll),
    );
    if (value != null && context.mounted) onChanged(value);
  }

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 8), child: Material(color: spenvaPurple, borderRadius: BorderRadius.circular(22), child: Row(children: [
    IconButton(tooltip: 'Periode sebelumnya', color: Colors.white, onPressed: !_canShift(-1) ? null : () => onChanged(period.shift(-1)), icon: const Icon(Icons.chevron_left)),
    Expanded(child: TextButton(onPressed: () => _pick(context), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Flexible(child: Text(period.label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      const Icon(Icons.arrow_drop_down, color: Colors.white),
    ]))),
    IconButton(tooltip: 'Buka kalender', color: Colors.white, onPressed: () => _pick(context), icon: const Icon(Icons.calendar_month_outlined)),
    IconButton(tooltip: 'Periode berikutnya', color: Colors.white, onPressed: !_canShift(1) ? null : () => onChanged(period.shift(1)), icon: const Icon(Icons.chevron_right)),
  ])));
}

class PeriodCalendarDialog extends StatefulWidget {
  const PeriodCalendarDialog({super.key, required this.period, this.allowAll = false});
  final SelectedPeriod period;
  final bool allowAll;
  @override
  State<PeriodCalendarDialog> createState() => _PeriodCalendarDialogState();
}

class _PeriodCalendarDialogState extends State<PeriodCalendarDialog> {
  late DateTime _month;
  late DateTime _first;
  DateTime? _last;
  PeriodKind _mode = PeriodKind.day;
  bool _choosingEnd = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.period.start ?? DateTime.now();
    _first = DateTime(initial.year, initial.month, initial.day);
    _month = DateTime(_first.year, _first.month);
    _last = widget.period.end;
    if (widget.period.kind != PeriodKind.day && widget.period.kind != PeriodKind.all) {
      // Open on the calendar while retaining the existing month/year bounds.
      _mode = PeriodKind.range;
    }
  }

  void _chooseDay(DateTime date) => setState(() {
    if (!_choosingEnd) {
      _first = date;
      _last = null;
      _choosingEnd = true;
      _mode = PeriodKind.range;
    } else {
      if (date.isBefore(_first)) { _last = _first; _first = date; }
      else { _last = date; }
      _choosingEnd = false;
    }
  });

  SelectedPeriod get _selection => switch (_mode) {
    PeriodKind.year => SelectedPeriod.year(_month.year),
    PeriodKind.month => SelectedPeriod.month(_month.year, _month.month),
    PeriodKind.range => SelectedPeriod.range(_first, _last ?? _first),
    _ => SelectedPeriod.day(_first),
  };

  Widget _calendar() {
    final offset = DateTime(_month.year, _month.month).weekday % 7;
    final days = DateTime(_month.year, _month.month + 1, 0).day;
    final rows = ((offset + days) / 7).ceil();
    final now = DateTime.now();
    return Column(children: [
      Row(children: [for (final name in ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'])
        Expanded(child: Center(child: Text(name, style: TextStyle(color: name == 'Min' ? Colors.red : Colors.grey))))]),
      const SizedBox(height: 8),
      for (var row = 0; row < rows; row++)
        Row(children: [for (var column = 0; column < 7; column++)
          Expanded(child: _dayCell(row * 7 + column - offset + 1, days, now))]),
    ]);
  }

  Widget _dayCell(int day, int days, DateTime now) {
    if (day < 1 || day > days) return const SizedBox(height: 48);
    final date = DateTime(_month.year, _month.month, day);
    final selected = date == _first || date == _last;
    final between = _last != null && date.isAfter(_first) && date.isBefore(_last!);
    final today = date == DateTime(now.year, now.month, now.day);
    return Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Material(
      color: selected ? Colors.orange : between ? const Color(0xffffedcc) : Colors.transparent,
      borderRadius: BorderRadius.circular(selected ? 16 : 0),
      child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () => _chooseDay(date),
        child: SizedBox(height: MediaQuery.textScalerOf(context).scale(22) + 22, child: Center(child: Semantics(
          label: '${SelectedPeriod.formatDate(date)}${today ? ", hari ini" : ""}', selected: selected,
          child: Text('$day', key: ValueKey('calendar_${date.year}_${date.month}_$day'), style: TextStyle(
            color: selected ? Colors.white : today ? Colors.orange : date.weekday == DateTime.sunday ? Colors.red : null,
            fontWeight: selected || today ? FontWeight.bold : FontWeight.normal)),
        )))),
    ));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Pilih periode'),
    content: SizedBox(width: 360, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        IconButton(tooltip: 'Bulan sebelumnya', onPressed: _month == DateTime(2000) ? null : () => setState(() => _month = DateTime(_month.year, _month.month - 1)), icon: const Icon(Icons.chevron_left)),
        Expanded(child: Text('${SelectedPeriod.months[_month.month - 1]} ${_month.year}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold))),
        IconButton(tooltip: 'Bulan berikutnya', onPressed: _month == DateTime(2100, 12) ? null : () => setState(() => _month = DateTime(_month.year, _month.month + 1)), icon: const Icon(Icons.chevron_right)),
      ]),
      DropdownButton<int>(key: const ValueKey('calendar_month'), value: _month.month, isExpanded: true,
        items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(SelectedPeriod.months[i]))),
        onChanged: (month) { if (month != null) setState(() => _month = DateTime(_month.year, month)); }),
      DropdownButton<int>(key: const ValueKey('calendar_year'), value: _month.year, isExpanded: true,
        items: List.generate(101, (i) => DropdownMenuItem(value: 2000 + i, child: Text('${2000 + i}'))),
        onChanged: (year) { if (year != null) setState(() => _month = DateTime(year, _month.month)); }),
      _calendar(),
      Wrap(spacing: 6, children: [
        TextButton(key: const ValueKey('select_whole_month'), onPressed: () => setState(() {
          _mode = PeriodKind.month; _first = DateTime(_month.year, _month.month); _last = DateTime(_month.year, _month.month + 1, 0); _choosingEnd = false;
        }), child: const Text('Sebulan penuh')),
        TextButton(key: const ValueKey('select_whole_year'), onPressed: () => setState(() {
          _mode = PeriodKind.year; _first = DateTime(_month.year); _last = DateTime(_month.year, 12, 31); _choosingEnd = false;
        }), child: const Text('Setahun penuh')),
      ]),
      const SizedBox(height: 12),
      Text(_selection.label, textAlign: TextAlign.center),
      if (_mode == PeriodKind.range && _choosingEnd)
        const Text('Klik tanggal lain untuk memilih rentang', style: TextStyle(color: Colors.orange)),
      if (widget.allowAll) TextButton(onPressed: () => Navigator.pop(context, const SelectedPeriod.all()), child: const Text('Semua tanggal')),
    ]))),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
      FilledButton(onPressed: () => Navigator.pop(context, _selection), child: const Text('Pilih')),
    ],
  );
}
