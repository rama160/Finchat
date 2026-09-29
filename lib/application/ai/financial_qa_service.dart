import '../../domain/ai/financial_ai_provider.dart';
import '../../domain/reports/report_models.dart';
import '../reports/report_service.dart';

class FinancialQaService {
  FinancialQaService({required this.reports, required this.provider});
  final ReportService reports;
  final FinancialAiProvider provider;

  Future<String> ask({required String userId, required String question, required DateTime start, required DateTime end}) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) return 'Pertanyaan masih kosong.';
    final report = await reports.forRange(userId: userId, start: start, end: end);
    final local = _answerLocally(trimmed, report);
    if (local != null) return local;
    final answer = await provider.answer(FinancialAiRequest(question: trimmed, start: report.start, endExclusive: report.endExclusive, transactions: report.transactions, incomeTotal: report.incomeTotal, expenseTotal: report.expenseTotal, balance: report.balance));
    return answer ?? 'Pertanyaan belum dapat dijawab secara lokal dan AI tidak tersedia. Coba pertanyaan seperti total pengeluaran, pemasukan, saldo, jumlah transaksi, atau kategori pengeluaran terbesar.';
  }

  String? _answerLocally(String question, ReportSummary report) {
    final q = question.toLowerCase();
    if (q.contains('saldo')) return 'Saldo pada periode ini adalah ${_money(report.balance)}.';
    if (q.contains('pemasukan') || q.contains('pendapatan')) return 'Total pemasukan pada periode ini adalah ${_money(report.incomeTotal)} dari ${report.incomeCount} transaksi.';
    if (q.contains('pengeluaran') && (q.contains('total') || q.contains('berapa'))) return 'Total pengeluaran pada periode ini adalah ${_money(report.expenseTotal)} dari ${report.expenseCount} transaksi.';
    if (q.contains('jumlah transaksi') || q.contains('berapa transaksi')) return 'Ada ${report.transactionCount} transaksi pada periode ini: ${report.incomeCount} pemasukan dan ${report.expenseCount} pengeluaran.';
    if ((q.contains('kategori') || q.contains('pengeluaran')) && q.contains('terbesar')) {
      final items = report.expenseCategories;
      if (items.isEmpty) return 'Belum ada pengeluaran pada periode ini.';
      final top = items.first;
      return 'Kategori pengeluaran terbesar adalah ${top.categoryName} sebesar ${_money(top.totalAmount)} dari ${top.transactionCount} transaksi.';
    }
    return null;
  }

  String _money(double value) {
    final digits = value.round().toString();
    return 'Rp ${digits.replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }
}
