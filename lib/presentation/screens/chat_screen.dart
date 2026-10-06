import '../../core/formatting/rupiah.dart';
import '../widgets/spenva_brand.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../../application/backup/automatic_backup_service.dart';
import '../../application/ocr/receipt_ocr_service.dart';
import '../../core/validation/transaction_validator.dart';
import '../../core/errors/input_failure_message.dart';
import '../../application/ocr/receipt_transaction_parser.dart';
import '../../application/transactions/transaction_intelligence_service.dart';
import '../../application/transactions/local_transaction_parser.dart';
import '../../application/transactions/input_intent.dart';
import '../../application/ai/financial_qa_service.dart';
import '../../application/reports/report_service.dart';
import '../../domain/reports/selected_period.dart';
import '../../application/ai/question_period.dart';
import '../../domain/parsing/voice_transaction_normalizer.dart';
import '../../data/local/finchat_database.dart';
import '../../data/ocr/image_receipt_preprocessor.dart';
import '../../data/ocr/mlkit_receipt_ocr_provider.dart';
import '../../data/repositories/sqlite_category_repository.dart';
import '../../data/repositories/sqlite_transaction_repository.dart';
import '../../application/speech/voice_input_service.dart';
import '../../data/speech/speech_to_text_provider.dart';
import '../../domain/speech/speech_recognition.dart';
import '../../domain/ai/ai_category_fallback.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/services/category_learning_service.dart';
import '../../data/ai/openai_compatible_ai_provider.dart';
import '../../main.dart';
import 'receipt_review_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.now});

  final DateTime Function()? now;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final _inputController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  late final FinChatDatabase _database;
  late final SqliteTransactionRepository _transactions;
  late final SqliteCategoryRepository _categories;
  late final CategoryLearningService _learning;
  late final TransactionIntelligenceService _intelligence;
  late final VoiceInputService _voice;
  late final AutomaticBackupService _automaticBackup;

  List<TransactionEntity> _items = const [];
  Map<String, String> _categoryNames = const {};
  final _inputFocus = FocusNode();
  final _chatScroll = ScrollController();
  MlKitReceiptOcrProvider? _ocrProvider;
  late DateTime _viewDay;
  DateTime _now() => widget.now?.call() ?? DateTime.now();
  Timer? _dayTimer;
  Timer? _statusTimer;
  String? _saveStatus;
  int _selectedTab = 0;
  final List<({int id, DateTime at, String question, String? answer})> _answers = [];
  int _questionId = 0;
  bool _backupRunning = false;
  bool _backupPending = false;
  bool _picking = false;
  bool _processing = false;
  bool _voiceConsumePending = false;
  bool _initialLoadStarted = false;

  @override
  void initState() {
    super.initState();
    _viewDay = _now();
    WidgetsBinding.instance.addObserver(this);
    _scheduleDayRollover();
    _database = FinChatDatabase();
    _transactions = SqliteTransactionRepository(_database);
    _categories = SqliteCategoryRepository(_database);
    _learning = CategoryLearningService(_categories);
    _intelligence = TransactionIntelligenceService(
      categoryLearning: _learning,
      aiFallback: AiCategoryFallback(
        provider: OpenAiCompatibleAiProvider(),
        categoryExists: (id) => _categories.getById(id).then((value) => value != null),
      ),
    );
    _automaticBackup = AutomaticBackupService(_database);
    _voice = VoiceInputService(
      SpeechToTextProvider(),
      onChanged: () {
        if (!mounted) return;
        setState(() {});
        if (_voice.status == SpeechSessionStatus.stopped &&
            _voice.hasFinalResult &&
            _voice.transcript.trim().isNotEmpty &&
            !_voiceConsumePending) {
          _voiceConsumePending = true;
          Future<void>.microtask(_consumeVoiceTranscript);
        }
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialLoadStarted) return;
    _initialLoadStarted = true;
    _loadTransactions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dayTimer?.cancel();
    _statusTimer?.cancel();
    _inputController.dispose();
    _inputFocus.dispose();
    _chatScroll.dispose();
    unawaited(_ocrProvider?.close().catchError((Object _) {}) ?? Future<void>.value());
    unawaited(_voice.cancel().catchError((Object _) {}));
    _database.close();
    super.dispose();
  }

  void _scheduleDayRollover() {
    _dayTimer?.cancel();
    final now = _now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    _dayTimer = Timer(midnight.difference(now), _checkDayRollover);
  }

  void _checkDayRollover() {
    if (!mounted) return;
    final now = _now();
    if (_viewDay.year != now.year || _viewDay.month != now.month || _viewDay.day != now.day) {
      setState(() {
        _viewDay = now;
        _answers.clear();
      });
      unawaited(_loadTransactions());
    }
    _scheduleDayRollover();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkDayRollover();
  }

  Future<void> _loadTransactions() async {
    final session = SessionScope.of(context).session;
    if (session == null) return;
    try {
      await _database.ensureUser(userId: session.userId, email: session.email);
      final items = await _transactions.getByUser(session.userId);
      final categories = await _categories.getCategories();
      if (mounted) setState(() { _items = items; _categoryNames = {for (final category in categories) category.id: category.name}; });
      unawaited(_runAutomaticBackupSilently());
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(inputFailureMessage(error, 'Transaksi belum berhasil dimuat. Coba buka kembali halaman Input.'))));
    }
  }


  Future<void> _runAutomaticBackupSilently() async {
    if (_backupRunning) { _backupPending = true; return; }
    _backupRunning = true;
    try {
      do {
        _backupPending = false;
        final uploaded = await _automaticBackup.runIfEnabled();
        if (uploaded && mounted) {
          final session = SessionScope.of(context).session;
          if (session != null) {
            final items = await _transactions.getByUser(session.userId);
            final categories = await _categories.getCategories();
      if (mounted) setState(() { _items = items; _categoryNames = {for (final category in categories) category.id: category.name}; });
          }
        }
      } while (_backupPending && mounted);
    } catch (_) {
      // Drive failures do not interrupt local input. Pending rows keep one tick.
    } finally { _backupRunning = false; }
  }

  bool _looksLikeFinancialQuestion(String input) => detectInputIntent(input) == InputIntent.question;

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _selectedTab == 0 && _chatScroll.hasClients) {
        unawaited(_chatScroll.animateTo(0, duration: const Duration(milliseconds: 180), curve: Curves.easeOut));
      }
    });
  }

  Future<void> _askInChat(String input) async {
    final session = SessionScope.of(context).session;
    if (session == null || _processing) return;
    final id = ++_questionId;
    final at = _now();
    setState(() {
      _processing = true;
      _answers.add((id: id, at: at, question: input, answer: null));
    });
    _scrollToLatest();
    String answer;
    try {
      final period = questionPeriod(input, at);
      final service = FinancialQaService(reports: ReportService(transactions: _transactions, categories: _categories), provider: OpenAiCompatibleAiProvider());
      final result = await service.ask(userId: session.userId, question: input,
        start: period.start ?? DateTime(2000), end: period.end ?? DateTime(2100, 12, 31));
      answer = '${period.label}\n$result';
    } on FormatException catch (error) {
      answer = error.message;
    } catch (_) {
      answer = 'Pertanyaan belum berhasil diproses. Silakan coba lagi.';
    }
    if (!mounted) return;
    setState(() {
      final index = _answers.indexWhere((message) => message.id == id);
      if (index >= 0) _answers[index] = (id: id, at: at, question: input, answer: answer);
      _processing = false;
    });
    _scrollToLatest();
  }

  Future<void> _saveIntelligentResults({
    required String input,
    required InputSource source,
    required String successMessage,
  }) async {
    final session = SessionScope.of(context).session;
    if (session == null) return;
    TransactionValidator.validateInput(input);

    await _database.ensureUser(userId: session.userId, email: session.email);
    final results = await _intelligence.process(userId: session.userId, input: input, allowAi: false);
    if (results.isEmpty) {
      throw StateError('Transaksi belum dikenali.');
    }

    final now = _now();
    final transactions = <TransactionEntity>[];
    for (var index = 0; index < results.length; index++) {
      final item = results[index];
      transactions.add(TransactionEntity(
        id: '${session.userId}_${now.microsecondsSinceEpoch}_${source.name}_$index',
        userId: session.userId,
        type: item.type == ParsedTransactionType.income ? TransactionType.income : TransactionType.expense,
        amount: item.amount,
        description: item.description,
        categoryId: item.categoryId,
        transactionDate: DateTime(now.year, now.month, now.day),
        inputSource: source,
        processedBy: item.processedBy,
        confidence: item.confidence,
        createdAt: now,
        updatedAt: now,
      ));
    }
    await _transactions.saveAll(transactions);
    await _loadTransactions();
    if (mounted) {
      _showSaved(successMessage.replaceFirst('{count}', '${results.length}'));
      _scrollToLatest();
    }
  }

  Future<void> _consumeVoiceTranscript() async {
    final input = normalizeVoiceTransactions(_voice.transcript.trim());
    if (input.isEmpty || !mounted) {
      _voiceConsumePending = false;
      return;
    }

    final session = SessionScope.of(context).session;
    if (session != null && _looksLikeFinancialQuestion(input)) {
      try {
        await _voice.cancel();
        if (mounted) await _askInChat(input);
      } finally { _voiceConsumePending = false; }
      return;
    }

    setState(() => _processing = true);
    try {
      await _saveIntelligentResults(
        input: input,
        source: InputSource.voice,
        successMessage: '{count} transaksi dari suara tersimpan.',
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(inputFailureMessage(error, 'Suara belum berhasil diproses. Coba ulangi dengan menyebutkan nominal transaksi.'))),
        );
      }
    } finally {
      await _voice.cancel();
      _voiceConsumePending = false;
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _toggleVoice() async {
    if (_processing || _picking || _voiceConsumePending) return;
    if (_voice.isListening) {
      await _voice.stopListening();
      return;
    }

    try {
      if (_voice.status != SpeechSessionStatus.ready &&
          _voice.status != SpeechSessionStatus.stopped) {
        final available = await _voice.initialize();
        if (!available) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pengenalan suara tidak tersedia atau izin mikrofon belum diberikan.')),
            );
          }
          return;
        }
      }
      await _voice.startListening(
        localeId: 'id_ID',
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 5),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(inputFailureMessage(error, 'Mikrofon belum dapat digunakan. Periksa izin mikrofon dan coba lagi.'))),
        );
      }
    }
  }

  Future<void> _processAndSave() async {
    final input = _inputController.text.trim();
    if (input.isEmpty || _processing || _picking || _voice.isListening) return;

    final session = SessionScope.of(context).session;
    if (session != null && _looksLikeFinancialQuestion(input)) {
      _inputController.clear();
      await _askInChat(input);
      return;
    }

    _inputController.clear();
    setState(() => _processing = true);
    try {
      await _saveIntelligentResults(
        input: input,
        source: InputSource.text,
        successMessage: '{count} transaksi langsung tersimpan.',
      );
    } catch (error) {
      if (!mounted) return;
      if (_inputController.text.isEmpty) _inputController.text = input;
      final message = error is StateError && error.message == 'Transaksi belum dikenali.'
          ? 'Transaksi belum dikenali. Contoh: nasi 25rb dan bensin 50k.'
          : inputFailureMessage(error, 'Transaksi belum berhasil disimpan. Coba lagi.');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _scanReceipt(ImageSource source) async {
    if (_processing || _picking || _voice.isListening) return;
    setState(() => _picking = true);
    try {
    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 95,
      maxWidth: 1800,
    );
    if (picked == null) return;
    await _processReceiptBytes(
      bytes: await picked.readAsBytes(),
      source: source == ImageSource.camera ? InputSource.camera : InputSource.attachment,
    );
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(inputFailureMessage(error, 'Kamera/galeri belum dapat dibuka. Periksa izin aplikasi dan coba lagi.'))));
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _scanReceiptFile() async {
    if (_processing || _picking || _voice.isListening) return;
    setState(() => _picking = true);
    try {
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (picked.isEmpty) return;
    final file = picked.single;
    Uint8List? bytes;
    try {
      bytes = await file.readAsBytes();
    } catch (_) {
      if (file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }
    }
    if (bytes == null || bytes.isEmpty) {
      throw StateError('File struk tidak dapat dibaca.');
    }
    await _processReceiptBytes(bytes: bytes, source: InputSource.attachment);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(inputFailureMessage(error, 'Lampiran belum dapat dibuka. Coba pilih gambar JPG atau PNG lainnya.'))));
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _processReceiptBytes({required Uint8List bytes, required InputSource source}) async {
    if (!mounted) return;
    final session = SessionScope.of(context).session;
    if (session == null || _processing) return;

    setState(() => _processing = true);
    try {
      await _database.ensureUser(userId: session.userId, email: session.email);
      final provider = _ocrProvider ??= MlKitReceiptOcrProvider();
      final ocr = ReceiptOcrService(
        preprocessor: const ImageReceiptPreprocessor(),
        provider: provider,
      );
      final result = await ocr.processImageBytes(
        imageBytes: bytes,
        workingImagePath: '${Directory.systemTemp.path}/finchat_receipt_${DateTime.now().microsecondsSinceEpoch}.jpg',
      );

      if (!result.hasText) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Teks struk tidak terbaca. Coba foto/file yang lebih jelas.')));
        }
        return;
      }

      final parsed = const ReceiptTransactionParser().parse(result.rawText, lines: result.lines);
      if (parsed.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Belum ada item transaksi yang dapat dikenali dari struk.')));
        }
        return;
      }

      final intelligent = await _intelligence.processParsed(userId: session.userId, localResults: parsed);
      final reviewItems = intelligent.map((resolved) => ReceiptReviewItem(
        description: resolved.description,
        amount: resolved.amount,
        type: resolved.type == ParsedTransactionType.income ? TransactionType.income : TransactionType.expense,
        categoryId: resolved.categoryId,
        processedBy: resolved.processedBy,
        confidence: resolved.confidence,
      )).toList();

      if (reviewItems.isEmpty) throw StateError('Item struk tidak dapat diubah menjadi transaksi.');
      if (!mounted) return;
      final categories = await _categories.getCategories();
      if (!mounted) return;
      final reviewed = await Navigator.of(context).push<List<ReceiptReviewItem>>(
        MaterialPageRoute(
          builder: (_) => ReceiptReviewScreen(items: reviewItems, categories: categories),
        ),
      );
      if (reviewed == null || reviewed.isEmpty) return;

      final now = _now();
      final transactions = <TransactionEntity>[];
      for (var index = 0; index < reviewed.length; index++) {
        final item = reviewed[index];
        transactions.add(TransactionEntity(
          id: '${session.userId}_${now.microsecondsSinceEpoch}_ocr_$index',
          userId: session.userId,
          type: item.type,
          amount: item.amount,
          description: item.description,
          categoryId: item.categoryId,
          transactionDate: DateTime(now.year, now.month, now.day),
          inputSource: source,
          processedBy: item.processedBy,
          confidence: item.confidence,
          createdAt: now,
          updatedAt: now,
        ));
      }
      await _transactions.saveAll(transactions);

      for (var index = 0; index < reviewed.length && index < reviewItems.length; index++) {
        final original = reviewItems[index];
        final item = reviewed[index];
        if (original.categoryId != item.categoryId) {
          await _learning.recordCorrection(
            userId: session.userId,
            text: item.description,
            categoryId: item.categoryId,
          );
        }
      }
      await _loadTransactions();
      if (mounted) {
        _showSaved('${reviewed.length} transaksi dari struk tersimpan.');
        _scrollToLatest();
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Struk belum berhasil dibaca. Coba foto yang lebih jelas atau masukkan transaksi lewat teks.'), duration: Duration(seconds: 4)));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  Future<void> _chooseReceiptSource() async {
    if (_processing) return;
    final action = await showModalBottomSheet<_ReceiptSourceAction>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Foto struk dengan kamera'),
              onTap: () => Navigator.pop(context, _ReceiptSourceAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih gambar dari galeri'),
              onTap: () => Navigator.pop(context, _ReceiptSourceAction.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: const Text('Pilih file struk'),
              subtitle: const Text('JPG, JPEG, PNG, atau WEBP'),
              onTap: () => Navigator.pop(context, _ReceiptSourceAction.file),
            ),
          ],
        ),
      ),
    );
    switch (action) {
      case _ReceiptSourceAction.camera:
        await _scanReceipt(ImageSource.camera);
      case _ReceiptSourceAction.gallery:
        await _scanReceipt(ImageSource.gallery);
      case _ReceiptSourceAction.file:
        await _scanReceiptFile();
      case null:
        return;
    }
  }

  Future<void> _editTransaction(TransactionEntity transaction) async {
    try {
      final categories = await _categories.getCategories();
      if (!mounted) return;
      final result = await showDialog<TransactionEntity>(
        context: context,
        builder: (_) => _EditTransactionDialog(transaction: transaction, categories: categories, repository: _categories),
      );
      if (result == null) return;

      await _transactions.update(result);
      if (result.categoryId != transaction.categoryId) {
        await _learning.recordCorrection(
          userId: transaction.userId,
          text: result.description,
          categoryId: result.categoryId,
        );
      }
      await _loadTransactions();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(inputFailureMessage(error, 'Transaksi belum berhasil diubah. Coba lagi.'))));
    }
  }

  void _showSaved(String message) {
    _statusTimer?.cancel();
    if (!mounted) return;
    setState(() => _saveStatus = message);
    _statusTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _saveStatus = null);
    });
  }

  Future<void> _deleteTransaction(TransactionEntity transaction) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Hapus transaksi?'),
      content: Text('${transaction.description} • ${_money(transaction.amount)}\nTransaksi ini akan dihapus dari catatan Anda.'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus'))],
    ));
    if (confirmed != true || !mounted) return;
    try {
      await _transactions.delete(transaction.id);
      await _loadTransactions();
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(inputFailureMessage(error, 'Transaksi belum berhasil dihapus. Coba lagi.'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context).session;
    final today = SelectedPeriod.day(_viewDay);
    final visibleItems = _items.where((item) => today.contains(item.transactionDate)).toList();
    final timeline = <({DateTime at, int order, TransactionEntity? transaction, int? answerIndex})>[
      for (var i = 0; i < visibleItems.length; i++)
        (at: visibleItems[i].createdAt, order: i, transaction: visibleItems[i], answerIndex: null),
      for (var i = 0; i < _answers.length; i++)
        (at: _answers[i].at, order: visibleItems.length + _answers[i].id, transaction: null, answerIndex: i),
    ]..sort((a, b) {
      final time = a.at.compareTo(b.at);
      return time == 0 ? a.order.compareTo(b.order) : time;
    });
    return PopScope(
      canPop: _selectedTab == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _selectedTab != 0) setState(() => _selectedTab = 0);
      },
      child: Scaffold(
      appBar: _selectedTab == 0 ? AppBar(
        title: const SizedBox(width: 145, height: 38, child: SpenvaLogo()),
        bottom: MediaQuery.viewInsetsOf(context).bottom > 0 ? null : PreferredSize(
          preferredSize: Size.fromHeight(MediaQuery.textScalerOf(context).scale(48) + 10),
          child: SpenvaGreeting(displayName: session?.displayName)),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
              if (mounted) await _loadTransactions();
            },
            tooltip: 'Pengaturan', icon: const Icon(Icons.settings_outlined)),
          IconButton(onPressed: SessionScope.of(context).logout, tooltip: 'Keluar', icon: const Icon(Icons.logout)),
        ],
      ) : null,
      bottomNavigationBar: NavigationBar(selectedIndex: _selectedTab,
        onDestinationSelected: (index) async {
          if (_selectedTab == index) return;
          if (_voice.isListening) await _voice.cancel();
          if (!mounted) return;
          setState(() => _selectedTab = index);
          if (index == 0) await _loadTransactions();
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Input', tooltip: 'Input'),
          NavigationDestination(icon: Icon(Icons.analytics_outlined), label: 'Laporan', tooltip: 'Laporan'),
        ]),
      body: _selectedTab == 1 && session != null ? ReportScreen(userId: session.userId) : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: visibleItems.isEmpty && _answers.isEmpty
                  ? _EmptyChat(email: session?.email ?? '')
                  : ListView.builder(
                      key: const PageStorageKey('chat_timeline'),
                      controller: _chatScroll,
                      reverse: true,
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                      itemCount: timeline.length,
                      itemBuilder: (context, index) {
                        final entry = timeline[timeline.length - 1 - index];
                        if (entry.answerIndex != null) {
                          final message = _answers[entry.answerIndex!];
                          return Column(key: ValueKey('question_${message.id}'), crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                            Align(alignment: Alignment.centerRight, child: Container(
                              constraints: const BoxConstraints(maxWidth: 340),
                              margin: const EdgeInsets.only(left: 40, bottom: 6), padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(18)),
                              child: Text(message.question),
                            )),
                            Align(alignment: Alignment.centerLeft, child: Card(
                              margin: const EdgeInsets.only(right: 24, bottom: 14),
                              child: Padding(padding: const EdgeInsets.all(14), child: message.answer == null ? const Text('Sedang menyiapkan jawaban…') : SelectableText(message.answer!)),
                            )),
                          ]);
                        }
                        final transaction = entry.transaction!;
                        return Dismissible(
                          key: ValueKey(transaction.id),
                          direction: DismissDirection.horizontal,
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            margin: const EdgeInsets.only(bottom: 8),
                            color: Colors.blue,
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            margin: const EdgeInsets.only(bottom: 8),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              await _editTransaction(transaction);
                              return false;
                            }
                            await _deleteTransaction(transaction);
                            // The repository reload removes the item from the list. Returning
                            // false prevents Dismissible from also removing the same widget.
                            return false;
                          },
                          child: _TransactionCard(
                            transaction: transaction,
                            categoryName: _categoryNames[transaction.categoryId] ?? transaction.categoryId,
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(height: 28, child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Semantics(liveRegion: true, child: Text(
                _voice.isListening || _voiceConsumePending
                    ? (_voice.transcript.isEmpty ? 'Mendengarkan…' : _voice.transcript)
                    : _saveStatus ?? (_processing || _picking ? 'Sedang memproses…' : ''),
                maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12),
              )),
            )),
            _Composer(
              controller: _inputController,
              focusNode: _inputFocus,
              busy: _processing || _picking,
              listening: _voice.isListening,
              onSubmit: _processAndSave,
              onReceipt: _chooseReceiptSource,
              onVoice: _toggleVoice,
              onCamera: () => _scanReceipt(ImageSource.camera),
            ),
          ],
        ),
      ),
    ));
  }
}

enum _ReceiptSourceAction { camera, gallery, file }

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction, required this.categoryName});
  final String categoryName;
  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final income = transaction.type == TransactionType.income;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(child: Icon(income ? Icons.arrow_downward : Icons.arrow_upward)),
        title: Text(transaction.description),
        subtitle: Text('${_date(transaction.transactionDate)} • $categoryName'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_money(transaction.amount)),
            const SizedBox(width: 8),
            Tooltip(message: transaction.syncStatus == 'backed_up' ? 'Tersimpan di SQLite dan backup Google Drive' : 'Tersimpan di SQLite; belum dikonfirmasi ke Google Drive',
              child: Icon(transaction.syncStatus == 'backed_up' ? Icons.done_all : Icons.check, color: transaction.syncStatus == 'backed_up' ? Colors.blue : Colors.green, size: 20)),
          ],
        ),
      ),
    );
  }
}

class _EditTransactionDialog extends StatefulWidget {
  const _EditTransactionDialog({required this.transaction, required this.categories, required this.repository});
  final TransactionEntity transaction;
  final List<CategoryEntity> categories;
  final SqliteCategoryRepository repository;

  @override
  State<_EditTransactionDialog> createState() => _EditTransactionDialogState();
}

class _EditTransactionDialogState extends State<_EditTransactionDialog> {
  late final TextEditingController _description;
  late final TextEditingController _amount;
  late TransactionType _type;
  late final TextEditingController _categoryName;
  bool _saving = false;
  String? _categoryError;
  late DateTime _date;

  @override
  void initState() {
    super.initState();

    _description = TextEditingController(text: widget.transaction.description);
    _amount = TextEditingController(text: widget.transaction.amount.toStringAsFixed(0));
    _type = widget.transaction.type;
    final matching = widget.categories.where((c) => c.id == widget.transaction.categoryId);
    _categoryName = TextEditingController(text: matching.isEmpty ? widget.transaction.categoryId : matching.first.name);
    _date = widget.transaction.transactionDate;
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    _categoryName.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _save() async {
    if (_saving) return;
    final amount = double.tryParse(_amount.text.replaceAll('.', '').replaceAll(',', '.'));
    if (amount == null || amount <= 0 || _description.text.trim().isEmpty) return;
    if (_categoryName.text.trim().isEmpty || _categoryName.text.trim().length > 50) {
      setState(() => _categoryError = 'Ketik kategori sepanjang 1–50 karakter.');
      return;
    }
    setState(() { _saving = true; _categoryError = null; });
    late final CategoryEntity category;
    try {
      category = await widget.repository.ensureCategory(_categoryName.text, _type.name);
    } catch (_) {
      if (mounted) setState(() { _saving = false; _categoryError = 'Kategori belum berhasil disimpan. Coba lagi.'; });
      return;
    }
    if (!mounted) return;
    final now = DateTime.now();
    Navigator.of(context).pop(TransactionEntity(
      id: widget.transaction.id,
      userId: widget.transaction.userId,
      type: _type,
      amount: amount,
      description: _description.text.trim(),
      categoryId: category.id,
      transactionDate: _date,
      transactionTime: widget.transaction.transactionTime,
      inputSource: widget.transaction.inputSource,
      processedBy: ProcessedBy.manual,
      confidence: widget.transaction.confidence,
      createdAt: widget.transaction.createdAt,
      updatedAt: now,
      syncStatus: 'local',
    ));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Edit transaksi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _description, decoration: const InputDecoration(labelText: 'Keterangan')),
              TextField(controller: _amount, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Nominal', prefixText: 'Rp ')),
              const SizedBox(height: 12),
              DropdownButtonFormField<TransactionType>(
                initialValue: _type,
                decoration: const InputDecoration(labelText: 'Jenis'),
                items: const [
                  DropdownMenuItem(value: TransactionType.expense, child: Text('Pengeluaran')),
                  DropdownMenuItem(value: TransactionType.income, child: Text('Pemasukan')),
                ],
                onChanged: (value) => setState(() => _type = value ?? _type),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _categoryName,
                maxLength: 50,
                decoration: InputDecoration(labelText: 'Kategori', errorText: _categoryError,
                  helperText: 'Ketik kategori sendiri atau pilih kategori',
                  suffixIcon: PopupMenuButton<CategoryEntity>(tooltip: 'Pilih kategori',
                    icon: const Icon(Icons.arrow_drop_down),
                    itemBuilder: (_) => widget.categories.where((c) => c.type == _type.name).map((c) => PopupMenuItem(value: c, child: Text(c.name))).toList(),
                    onSelected: (category) => setState(() => _categoryName.text = category.name),
                  ),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Tanggal: ${_formatDate(_date)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final value = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (value != null) setState(() => _date = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
          FilledButton(onPressed: _saving ? null : _save, child: const Text('Simpan')),
        ],
      );
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat({required this.email});
  final String email;

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 64),
              const SizedBox(height: 16),
              Text('Halo ${email.isEmpty ? '' : email}'),
              const SizedBox(height: 8),
              const Text(
                'Ketik transaksi dengan bahasa sehari-hari. Spenva akan memisahkan beberapa transaksi dan langsung menyimpannya. Anda dapat edit atau hapus setelah tersimpan.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text('Contoh: Beli nasi 25rb dan bensin 50k'),
            ],
          ),
        )),
      );
}

class _Composer extends StatelessWidget {
  const _Composer({required this.controller, required this.focusNode, required this.busy, required this.listening, required this.onSubmit, required this.onReceipt, required this.onVoice, required this.onCamera});
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool busy;
  final bool listening;
  final VoidCallback onSubmit, onReceipt, onVoice, onCamera;

  Future<void> _emoji(BuildContext context) async {
    final emoji = await showModalBottomSheet<String>(context: context, builder: (context) => SafeArea(child: Wrap(children: [
      for (final value in ['😊', '🍚', '☕', '🛒', '⛽', '💰', '🏠', '📚'])
        TextButton(onPressed: () => Navigator.pop(context, value), child: Text(value, style: const TextStyle(fontSize: 28))),
    ])));
    if (emoji == null || !context.mounted) return;
    final selection = controller.selection;
    final start = selection.isValid ? selection.start : controller.text.length;
    final end = selection.isValid ? selection.end : start;
    controller.value = TextEditingValue(text: controller.text.replaceRange(start, end, emoji), selection: TextSelection.collapsed(offset: start + emoji.length));
  }

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(8, 8, 8, 12), child: DecoratedBox(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
    child: ValueListenableBuilder<TextEditingValue>(valueListenable: controller, builder: (context, value, _) => Row(children: [
      IconButton(onPressed: busy || listening ? null : () => _emoji(context), icon: const Icon(Icons.sentiment_satisfied_alt), tooltip: 'Emoji'),
      Expanded(child: TextField(key: const ValueKey('chat_input'), controller: controller, focusNode: focusNode, readOnly: listening, minLines: 1, maxLines: 1, textInputAction: TextInputAction.send,
        onEditingComplete: () {},
        decoration: const InputDecoration(hintText: 'Pesan', border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)), onSubmitted: (_) => onSubmit())),
      IconButton(onPressed: busy || listening ? null : onReceipt, icon: const Icon(Icons.attach_file), tooltip: 'Tambah struk'),
      IconButton(onPressed: busy || listening ? null : onCamera, icon: const Icon(Icons.camera_alt_outlined), tooltip: 'Kamera'),
      IconButton.filled(style: IconButton.styleFrom(backgroundColor: const Color(0xff1da1e8), foregroundColor: Colors.white),
        onPressed: busy ? null : listening || value.text.trim().isEmpty ? onVoice : onSubmit,
        icon: busy ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Icon(listening ? Icons.stop : value.text.trim().isEmpty ? Icons.mic : Icons.send),
        tooltip: listening ? 'Hentikan suara' : value.text.trim().isEmpty ? 'Input suara' : 'Proses transaksi'),
    ])),
  ));
}


String _money(double value) => formatRupiah(value);
