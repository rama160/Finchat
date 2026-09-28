import 'package:flutter_test/flutter_test.dart';
import 'package:finchat/core/validation/transaction_validator.dart';
import 'package:finchat/domain/entities/transaction_entity.dart';

void main() {
  TransactionEntity valid({double amount = 25000, double confidence = .9}) {
    final now = DateTime(2026, 9, 28);
    return TransactionEntity(id: 'tx-1', userId: 'u1', type: TransactionType.expense, amount: amount, description: 'Nasi', categoryId: 'makanan', transactionDate: now, inputSource: InputSource.text, processedBy: ProcessedBy.localParser, confidence: confidence, createdAt: now, updatedAt: now);
  }
  test('rejects empty and oversized input', () {
    expect(() => TransactionValidator.validateInput('   '), throwsA(isA<FormatException>()));
    expect(() => TransactionValidator.validateInput('x' * 2001), throwsA(isA<FormatException>()));
  });
  test('rejects invalid amount and confidence', () {
    expect(() => TransactionValidator.validate(valid(amount: 0)), throwsA(isA<FormatException>()));
    expect(() => TransactionValidator.validate(valid(confidence: 1.1)), throwsA(isA<FormatException>()));
  });
}
