enum TransactionType { income, expense }

enum InputSource { text, voice, attachment, camera, manual }

enum ProcessedBy { localParser, aiFallback, manual }

class TransactionEntity {
  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.transactionDate,
    required this.inputSource,
    required this.processedBy,
    required this.confidence,
    required this.createdAt,
    required this.updatedAt,
    this.transactionTime,
    this.deletedAt,
    this.syncStatus = 'local',
  });

  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String description;
  final String categoryId;
  final DateTime transactionDate;
  final DateTime? transactionTime;
  final InputSource inputSource;
  final ProcessedBy processedBy;
  final double confidence;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String syncStatus;
}
