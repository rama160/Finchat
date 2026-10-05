import '../../domain/ai/financial_ai_provider.dart';
import '../../domain/reports/report_models.dart';
import '../../domain/entities/transaction_entity.dart';
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
    if (answer == null && provider is FinancialAiAvailability) {
      final message = (provider as FinancialAiAvailability).failureMessage;
      if (message != null) return message;
    }
    return answer ?? 'Pertanyaan belum dapat dijawab secara lokal dan AI tidak tersedia. Coba pertanyaan seperti total pengeluaran, pemasukan, saldo, jumlah transaksi, atau kategori pengeluaran terbesar.';
  }

  String? _answerLocally(String question, ReportSummary report) {
    final q = question.toLowerCase();
    if (RegExp(r'\b(hemat|menabung)\b').hasMatch(q)) {
      final top = report.expenseCategories;
      final detail = top.isEmpty ? 'Belum ada pengeluaran untuk dianalisis.' : 'Pengeluaran terbesar pada periode ini adalah ${top.first.categoryName}: ${_money(top.first.totalAmount)}.';
      return '$detail Batasi belanja yang bisa ditunda, tentukan anggaran harian, dan sisihkan tabungan saat menerima pemasukan. Saran ini berdasarkan data lokal pada periode terpilih.';
    }
    if (RegExp(r'\b(bagaimana|mengapa|kenapa|saran|tips|strategi|cukup)\b').hasMatch(q)) return null;
    final keywordMatch = RegExp(r'(?:mengandung\s+kata|dengan\s+kata|mengandung|kata\s+kunci|berisi\s+kata|berisi|untuk)\s+["\x27]?(.*?)["\x27]?[?.!]*$', caseSensitive: false).firstMatch(q);
    if (keywordMatch != null) {
      final keyword = keywordMatch[1]!.split(RegExp(r'[,;]|\s+(?:buat|jadikan|tampilkan)\s', caseSensitive: false)).first.trim().replaceAll(RegExp(r'''["\x27]'''), '').replaceFirst(RegExp(r'\s+(?:hari ini|kemarin|bulan ini|bulan lalu|minggu ini)$'), '').trim();
      if (keyword.isEmpty) return 'Tuliskan kata yang ingin dicari pada deskripsi transaksi.';
      final income = q.contains('pemasukan') || q.contains('pendapatan');
      final type = income ? TransactionType.income : TransactionType.expense;
      final items = report.transactions.where((item) => item.type == type && item.description.toLowerCase().contains(keyword)).toList();
      final total = items.fold<double>(0, (sum, item) => sum + item.amount);
      final title = income ? 'pemasukan' : 'pengeluaran';
      if (items.isEmpty) return 'Tidak ada $title dengan deskripsi yang mengandung "$keyword" pada periode ini.';
      final rows = items.map((item) => '${item.transactionDate.day}/${item.transactionDate.month}/${item.transactionDate.year} • ${item.description}: ${_money(item.amount)}').join('\n');
      return 'Nota $title • "$keyword"\n$rows\nTotal: ${_money(total)} (${items.length} transaksi).';
    }
    // Do not silently discard unsupported constraints and answer a global total.
    if (RegExp(r'\b(kategori|nota|kecuali|selain|dibanding|perbandingan|lebih dari|kurang dari|terakhir)\b').hasMatch(q) && !q.contains('terbesar')) return null;
    if ((q.contains('pemasukan') || q.contains('pendapatan')) && q.contains('pengeluaran')) {
      return 'Pemasukan ${_money(report.incomeTotal)}, pengeluaran ${_money(report.expenseTotal)}, saldo ${_money(report.balance)} pada periode ini.';
    }
    if ((q.contains('kategori') || q.contains('pengeluaran')) && q.contains('terbesar')) {
      final items = report.expenseCategories;
      if (items.isEmpty) return 'Belum ada pengeluaran pada periode ini.';
      final top = items.first;
      return 'Kategori pengeluaran terbesar adalah ${top.categoryName} sebesar ${_money(top.totalAmount)} dari ${top.transactionCount} transaksi.';
    }
    if (q.contains('saldo')) return 'Saldo pada periode ini adalah ${_money(report.balance)}.';
    if (q.contains('pemasukan') || q.contains('pendapatan')) return 'Total pemasukan pada periode ini adalah ${_money(report.incomeTotal)} dari ${report.incomeCount} transaksi.';
    if (q.contains('pengeluaran') && (q.contains('total') || q.contains('berapa'))) return 'Total pengeluaran pada periode ini adalah ${_money(report.expenseTotal)} dari ${report.expenseCount} transaksi.';
    if (q.contains('jumlah transaksi') || q.contains('berapa transaksi')) return 'Ada ${report.transactionCount} transaksi pada periode ini: ${report.incomeCount} pemasukan dan ${report.expenseCount} pengeluaran.';
    if (q.split(RegExp(r'\s+')).length <= 2 && !q.endsWith('?')) return 'Untuk mencatat transaksi, sertakan nominal. Contoh: nasi 10 ribu. Untuk bertanya, tuliskan pertanyaan lengkap.';
    return null;
  }

  String _money(double value) {
    final digits = value.round().toString();
    return 'Rp ${digits.replaceAllMapped(RegExp(r'(?=(\d{3})+(?!\d))'), (match) => '.')}';
  }
}
