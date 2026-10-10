import '../../core/formatting/rupiah.dart';
import 'daily_expenses.dart';
import 'report_models.dart';
import 'selected_period.dart';
import '../entities/transaction_entity.dart';

class ReportInsight {
  const ReportInsight(this.title, this.text);
  final String title;
  final String text;
}

String reportMoney(double amount) => formatRupiah(amount);
String _date(DateTime date) => '${date.day} ${SelectedPeriod.months[date.month - 1]} ${date.year}';
String _percent(double amount) => amount.toStringAsFixed(1).replaceFirst(RegExp(r'\.0$'), '').replaceAll('.', ',');

String expenseComparison(double previous, double selected) {
  if (selected == previous) return 'Pengeluaranmu sama dengan hari sebelumnya.';
  if (previous == 0) return 'Hari sebelumnya tidak ada pengeluaran tercatat; pada hari yang dipilih kamu mengeluarkan ${reportMoney(selected)}.';
  final percent = _percent((selected - previous).abs() / previous * 100);
  return 'Pengeluaranmu ${selected > previous ? "naik" : "turun"} $percent%, atau ${reportMoney((selected - previous).abs())}, dibanding hari sebelumnya.';
}

String categoryChartCaption(ReportSummary report) {
  final categories = report.expenseCategories;
  if (categories.isEmpty) return 'Belum ada pengeluaran yang tercatat pada periode ini.';
  final top = categories.reduce((a, b) => a.totalAmount >= b.totalAmount ? a : b);
  if (categories.length == 1) return 'Seluruh pengeluaranmu, ${reportMoney(report.expenseTotal)}, tercatat di kategori ${top.categoryName}.';
  final share = report.expenseTotal == 0 ? '0' : _percent(top.totalAmount / report.expenseTotal * 100);
  return 'Dari total ${reportMoney(report.expenseTotal)}, ${reportMoney(top.totalAmount)} ($share%) digunakan untuk ${top.categoryName}. Sisanya tersebar di ${categories.length - 1} kategori lain.';
}

String dailyChartCaption(ReportSummary report, List<DailyExpense> points) {
  final days = dailyExpenses(report);
  if (days.length == 1 && points.length == 2) {
    return 'Pada ${_date(points.last.date)}, kamu mengeluarkan ${reportMoney(points.last.amount)}. Sehari sebelumnya tercatat ${reportMoney(points.first.amount)}. ${expenseComparison(points.first.amount, points.last.amount)}';
  }
  if (report.expenseTotal == 0) return 'Belum ada pengeluaran tercatat dari ${_date(report.start)} sampai ${_date(report.endExclusive.subtract(const Duration(days: 1)))}.';
  final average = days.isEmpty ? 0.0 : report.expenseTotal / days.length;
  return 'Selama ${days.length} hari yang dipilih, pengeluaranmu mencapai ${reportMoney(report.expenseTotal)}. Jika dibagi merata, sekitar ${reportMoney(average)} per hari.';
}

List<ReportInsight> reportInsights(ReportSummary report, List<DailyExpense> points) {
  final days = dailyExpenses(report);
  final insights = <ReportInsight>[];
  if (report.incomeTotal > 0) {
    insights.add(ReportInsight('Arus kas periode ini', report.balance >= 0
      ? 'Dari pemasukan ${reportMoney(report.incomeTotal)}, masih tersisa ${reportMoney(report.balance)} setelah pengeluaran. ${report.balance > 0 ? "Kamu bisa menyisihkan sebagian untuk tabungan." : "Pemasukan dan pengeluaranmu seimbang."}'
      : 'Pengeluaranmu melebihi pemasukan sebesar ${reportMoney(report.balance.abs())}. Coba cek belanja yang bisa ditunda agar selisihnya tidak bertambah.'));
  } else {
    insights.add(ReportInsight('Arus kas periode ini', 'Belum ada pemasukan tercatat pada periode ini. ${report.expenseTotal > 0 ? "Pengeluaranmu sudah ${reportMoney(report.expenseTotal)}; catat pemasukan juga agar gambaran keuanganmu lebih lengkap." : "Mulai catat pemasukan dan pengeluaran untuk melihat ceritanya di sini."}'));
  }
  if (days.length > 1 && report.expenseTotal > 0) {
    final zeroDays = days.where((day) => day.amount == 0).length;
    insights.add(ReportInsight('Ritme belanja', 'Rata-rata pengeluaranmu ${reportMoney(report.expenseTotal / days.length)} per hari. ${zeroDays > 0 ? "Ada $zeroDays hari tanpa pengeluaran tercatat dalam periode ini." : "Pengeluaran tercatat setiap hari pada periode ini."}'));
    final peak = days.reduce((a, b) => a.amount >= b.amount ? a : b);
    insights.add(ReportInsight('Puncak pengeluaran', 'Belanja paling banyak terjadi pada ${_date(peak.date)}, sebesar ${reportMoney(peak.amount)}. Cek transaksi hari itu jika ingin mencari ruang untuk berhemat.'));
  }
  if (days.length == 1 && points.length == 2) insights.add(ReportInsight('Perubahan harian', expenseComparison(points.first.amount, points.last.amount)));
  final repeated = report.groups.where((group) => group.type == TransactionType.expense && group.transactionCount > 1).toList()
    ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
  if (repeated.isNotEmpty) {
    final top = repeated.first;
    insights.add(ReportInsight('Belanja berulang', '${top.description} tercatat ${top.transactionCount} kali dengan total ${reportMoney(top.totalAmount)}. Jika belanja ini rutin, anggaran kecil khusus bisa membantumu mengendalikannya.'));
  } else if (report.expenseCount > 1) {
    insights.add(ReportInsight('Ukuran belanja', 'Kamu mencatat ${report.expenseCount} pengeluaran, rata-rata ${reportMoney(report.expenseTotal / report.expenseCount)} sekali belanja. Cek pembelian yang bisa digabung atau ditunda.'));
  }
  return insights;
}
