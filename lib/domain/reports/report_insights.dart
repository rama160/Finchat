import 'daily_expenses.dart';
import 'report_models.dart';
import '../entities/transaction_entity.dart';

class ReportInsight {
  const ReportInsight(this.title, this.text);
  final String title;
  final String text;
}

String reportMoney(double amount) => 'Rp ${amount.round().toString().replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (_) => '.')}';
String _date(DateTime date) => '${date.day}/${date.month}/${date.year}';

String expenseComparison(double previous, double selected) {
  if (selected == previous) return 'Nominal sama dengan hari sebelumnya.';
  if (previous == 0) return 'Hari sebelumnya tidak memiliki pengeluaran tercatat.';
  final percent = ((selected - previous).abs() / previous * 100).toStringAsFixed(1);
  return '${selected > previous ? "Naik" : "Turun"} $percent% (${reportMoney((selected - previous).abs())}) dari hari sebelumnya.';
}

String categoryChartCaption(ReportSummary report) {
  final categories = report.expenseCategories;
  if (categories.isEmpty) return 'Tidak ada pengeluaran dalam periode ini.';
  final top = categories.reduce((a, b) => a.totalAmount >= b.totalAmount ? a : b);
  final share = report.expenseTotal == 0 ? '0.0' : (top.totalAmount / report.expenseTotal * 100).toStringAsFixed(1);
  return '${categories.length} kategori berjumlah ${reportMoney(report.expenseTotal)}. ${top.categoryName} menyumbang $share% (${reportMoney(top.totalAmount)}).';
}

String dailyChartCaption(ReportSummary report, List<DailyExpense> points) {
  final days = dailyExpenses(report);
  if (days.length == 1 && points.length == 2) {
    return '${_date(points.first.date)}: ${reportMoney(points.first.amount)}; ${_date(points.last.date)}: ${reportMoney(points.last.amount)}. ${expenseComparison(points.first.amount, points.last.amount)} Total periode terpilih: ${reportMoney(report.expenseTotal)}.';
  }
  final average = days.isEmpty ? 0.0 : report.expenseTotal / days.length;
  return '${_date(report.start)} – ${_date(DateTime(report.endExclusive.year, report.endExclusive.month, report.endExclusive.day - 1))}: ${reportMoney(report.expenseTotal)} selama ${days.length} hari, rata-rata ${reportMoney(average)} per hari.';
}

List<ReportInsight> reportInsights(ReportSummary report, List<DailyExpense> points) {
  final days = dailyExpenses(report);
  final insights = <ReportInsight>[];
  if (report.incomeTotal > 0) {
    final ratio = (report.expenseTotal / report.incomeTotal * 100).toStringAsFixed(1);
    insights.add(ReportInsight('Arus kas periode ini', 'Pengeluaran memakai $ratio% dari pemasukan tercatat. ${report.balance >= 0 ? "Sisa" : "Selisih pengeluaran melebihi pemasukan"}: ${reportMoney(report.balance.abs())}.'));
  } else {
    insights.add(ReportInsight('Arus kas periode ini', 'Belum ada pemasukan tercatat dalam periode ini; pengeluaran ${reportMoney(report.expenseTotal)}. Catatan ini belum menggambarkan seluruh pendapatan Anda.'));
  }
  if (days.isNotEmpty) {
    insights.add(ReportInsight('Ritme belanja', 'Rata-rata ${reportMoney(report.expenseTotal / days.length)} per hari selama ${days.length} hari, termasuk ${days.where((day) => day.amount == 0).length} hari tanpa pengeluaran tercatat.'));
    final peak = days.reduce((a, b) => a.amount >= b.amount ? a : b);
    if (peak.amount > 0) insights.add(ReportInsight('Puncak pengeluaran', '${_date(peak.date)} mencapai ${reportMoney(peak.amount)} (${(peak.amount / report.expenseTotal * 100).toStringAsFixed(1)}% dari total periode).'));
  }
  if (days.length == 1 && points.length == 2) {
    insights.add(ReportInsight('Perubahan harian', expenseComparison(points.first.amount, points.last.amount)));
  }
  final repeated = report.groups.where((group) => group.type == TransactionType.expense && group.transactionCount > 1).toList()
    ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  if (repeated.isNotEmpty) {
    final top = repeated.first;
    insights.add(ReportInsight('Belanja berulang', '${top.description} tercatat ${top.transactionCount} kali, berjumlah ${reportMoney(top.totalAmount)}. Rata-rata ${reportMoney(top.totalAmount / top.transactionCount)} per transaksi.'));
  } else if (report.expenseCount > 0) {
    insights.add(ReportInsight('Ukuran belanja', '${report.expenseCount} transaksi pengeluaran rata-rata ${reportMoney(report.expenseTotal / report.expenseCount)} per transaksi.'));
  }
  return insights;
}
