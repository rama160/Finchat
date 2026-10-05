import 'package:flutter/material.dart';
import '../../domain/reports/selected_period.dart';

class PeriodFilter extends StatelessWidget {
  const PeriodFilter({super.key, required this.period, required this.onChanged, this.allowAll = false});
  final SelectedPeriod period;
  final ValueChanged<SelectedPeriod> onChanged;
  final bool allowAll;

  Future<void> _pick(BuildContext context) async {
    final choice = await showModalBottomSheet<PeriodKind>(
      context: context,
      builder: (context) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        for (final entry in {PeriodKind.day: 'Pilih tanggal', PeriodKind.range: 'Pilih rentang tanggal', PeriodKind.month: 'Pilih bulan dan tahun', if (allowAll) PeriodKind.all: 'Semua tanggal'}.entries)
          ListTile(title: Text(entry.value), onTap: () => Navigator.pop(context, entry.key)),
      ])),
    );
    if (choice == null || !context.mounted) return;
    final initial = period.start ?? DateTime.now();
    switch (choice) {
      case PeriodKind.all:
        onChanged(const SelectedPeriod.all());
      case PeriodKind.day:
        final value = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2000), lastDate: DateTime(2100, 12, 31));
        if (value != null && context.mounted) onChanged(SelectedPeriod.day(value));
      case PeriodKind.range:
        final value = await showDateRangePicker(context: context, firstDate: DateTime(2000), lastDate: DateTime(2100, 12, 31), initialDateRange: period.start == null ? null : DateTimeRange(start: period.start!, end: period.end!));
        if (value != null && context.mounted) onChanged(SelectedPeriod.range(value.start, value.end));
      case PeriodKind.month:
        final value = await showDialog<SelectedPeriod>(context: context, builder: (_) => _MonthDialog(initial: initial));
        if (value != null && context.mounted) onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) => Material(color: const Color(0xff009688), child: Row(children: [
    IconButton(tooltip: 'Periode sebelumnya', color: Colors.white, onPressed: period.kind == PeriodKind.all ? null : () => onChanged(period.shift(-1)), icon: const Icon(Icons.chevron_left)),
    Expanded(child: TextButton(onPressed: () => _pick(context), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Flexible(child: Text(period.label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
      const Icon(Icons.arrow_drop_down, color: Colors.white),
    ]))),
    IconButton(tooltip: 'Periode berikutnya', color: Colors.white, onPressed: period.kind == PeriodKind.all ? null : () => onChanged(period.shift(1)), icon: const Icon(Icons.chevron_right)),
  ]));
}

class _MonthDialog extends StatefulWidget {
  const _MonthDialog({required this.initial});
  final DateTime initial;
  @override
  State<_MonthDialog> createState() => _MonthDialogState();
}

class _MonthDialogState extends State<_MonthDialog> {
  late int _month;
  late int _year;
  @override
  void initState() { super.initState(); _month = widget.initial.month; _year = widget.initial.year; }
  @override
  Widget build(BuildContext context) => AlertDialog(title: const Text('Pilih bulan dan tahun'), content: Column(mainAxisSize: MainAxisSize.min, children: [
    DropdownButtonFormField<int>(initialValue: _month, decoration: const InputDecoration(labelText: 'Bulan'), items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text(SelectedPeriod.months[i]))), onChanged: (value) => setState(() => _month = value ?? _month)),
    DropdownButtonFormField<int>(initialValue: _year, decoration: const InputDecoration(labelText: 'Tahun'), items: List.generate(101, (i) => DropdownMenuItem(value: 2000 + i, child: Text('${2000 + i}'))), onChanged: (value) => setState(() => _year = value ?? _year)),
  ]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')), FilledButton(onPressed: () => Navigator.pop(context, SelectedPeriod.month(_year, _month)), child: const Text('Pilih'))]);
}
