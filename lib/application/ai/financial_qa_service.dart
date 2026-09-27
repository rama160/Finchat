import '../../domain/ai/financial_ai_provider.dart';
import '../reports/report_service.dart';

class FinancialQaService {
  FinancialQaService({required this.reports, required this.provider});
  final ReportService reports;
  final FinancialAiProvider provider;

  Future<String> ask({required String userId, required String question, required DateTime start, required DateTime end}) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) return 'Pertanyaan masih kosong.';
    final report = await reports.forRange(userId: userId, start: start, end: end);
    final answer = await provider.answer(FinancialAiRequest(question: trimmed, start: report.start, endExclusive: report.endExclusive, transactions: report.transactions, incomeTotal: report.incomeTotal, expenseTotal: report.expenseTotal, balance: report.balance));
    return answer ?? 'AI tidak tersedia. Pastikan AI diaktifkan, API key dan endpoint sudah benar, atau gunakan laporan lokal FinChat.';
  }
}
