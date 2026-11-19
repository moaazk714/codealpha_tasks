import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/flashcard.dart';

class FlashcardCard extends StatefulWidget {
  final Flashcard card;
  final bool isAnswerVisible;
  final VoidCallback onShowAnswer;
  final VoidCallback onHideAnswer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final Future<void> Function(String rating)? onRate;

  const FlashcardCard({
    super.key,
    required this.card,
    required this.isAnswerVisible,
    required this.onShowAnswer,
    required this.onHideAnswer,
    required this.onEdit,
    required this.onDelete,
    this.onRate,
  });

  @override
  State<FlashcardCard> createState() => _FlashcardCardState();
}

class _FlashcardCardState extends State<FlashcardCard> {
  final FlutterTts flutterTts = FlutterTts();
  QuillController? _answerController;
  String _plainAnswer = '';

  @override
  void initState() {
    super.initState();
    _configureAnswer(widget.card.answer);
    setupTts();
  }

  @override
  void didUpdateWidget(covariant FlashcardCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.card.answer != widget.card.answer) {
      _configureAnswer(widget.card.answer);
    }
  }

  void _configureAnswer(String answer) {
    _answerController?.dispose();
    _answerController = null;
    _plainAnswer = answer;

    Object? decoded;
    try {
      decoded = jsonDecode(answer);
    } on FormatException {
      return;
    }

    if (decoded is! List || !_looksLikeDelta(decoded)) return;

    try {
      final document = Document.fromJson(decoded);
      _answerController = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
      _plainAnswer = _withoutTerminalNewline(document.toPlainText());
    } catch (error, stackTrace) {
      developer.log(
        'Unable to decode a flashcard answer Delta.',
        name: 'flashcard.answer',
        error: error,
        stackTrace: stackTrace,
      );
      _plainAnswer = _extractInsertedText(decoded);
    }
  }

  bool _looksLikeDelta(List<dynamic> data) {
    return data.isEmpty ||
        data.any(
          (operation) =>
              operation is Map &&
              (operation.containsKey('insert') ||
                  operation.containsKey('retain') ||
                  operation.containsKey('delete') ||
                  operation.containsKey('attributes')),
        );
  }

  String _extractInsertedText(List<dynamic> data) {
    final text = data
        .whereType<Map>()
        .map((operation) => operation['insert'])
        .whereType<String>()
        .join();
    return _withoutTerminalNewline(text);
  }

  String _withoutTerminalNewline(String text) {
    return text.endsWith('\n') ? text.substring(0, text.length - 1) : text;
  }

  Widget _buildAnswerContent() {
    final controller = _answerController;
    if (controller == null) {
      return Text(
        _plainAnswer,
        style: const TextStyle(
          fontSize: 14.5,
          height: 1.55,
          color: Color(0xFF1E293B),
        ),
      );
    }

    return QuillEditor.basic(
      controller: controller,
      config: const QuillEditorConfig(
        scrollable: false,
        padding: EdgeInsets.zero,
        showCursor: false,
        enableInteractiveSelection: false,
        customStyles: DefaultStyles(
          paragraph: DefaultTextBlockStyle(
            TextStyle(fontSize: 14.5, height: 1.55, color: Color(0xFF1E293B)),
            HorizontalSpacing(0, 0),
            VerticalSpacing.zero,
            VerticalSpacing.zero,
            null,
          ),
        ),
      ),
    );
  }

  Future<void> setupTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.45);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> speakAnswer() async {
    final answer = _plainAnswer.trim();

    if (answer.isEmpty) return;

    try {
      await flutterTts.stop();
      await flutterTts.speak(answer);
    } catch (e) {
      if (!mounted) return;
      showMessage('Unable to read the answer aloud.');
    }
  }

  @override
  void dispose() {
    _answerController?.dispose();
    flutterTts.stop();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.65,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: widget.isAnswerVisible
              ? _buildAnswerView()
              : _buildQuestionView(),
        ),
      ),
    );
  }

  // Question View
  Widget _buildQuestionView() {
    return Column(
      key: const ValueKey('question'),
      children: [
        _buildTopBar(),
        const SizedBox(height: 32),

        const CircleAvatar(
          radius: 32,
          backgroundColor: Color(0xFFEEF2FF),
          child: Icon(
            Icons.psychology_outlined,
            color: Color(0xFF4338CA),
            size: 32,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          widget.card.question,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Think about your answer, then reveal it.',
          style: TextStyle(color: Color(0xFF64748B)),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 36),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: widget.onShowAnswer,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Show Answer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B33D1),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Answer View
  Widget _buildAnswerView() {
    return Column(
      key: const ValueKey('answer'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTopBar(),
        const SizedBox(height: 14),

        Text(
          widget.card.question,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          widget.card.category,
          style: const TextStyle(color: Color(0xFF64748B)),
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBadge('ANSWER'),

                  Row(
                    children: [
                      IconButton(
                        onPressed: speakAnswer,
                        icon: const Icon(Icons.volume_up_outlined),
                        tooltip: 'Read Answer Aloud',
                      ),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _plainAnswer));
                          showMessage('Answer copied to clipboard!');
                        },
                        icon: const Icon(Icons.copy_rounded),
                        tooltip: 'Copy Answer',
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _buildAnswerContent(),

              if (widget.card.tags.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: widget.card.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor: const Color(0xFFEEF2FF),
                      labelStyle: const TextStyle(
                        color: Color(0xFF4338CA),
                        fontSize: 11,
                      ),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 18),

        const Center(
          child: Text(
            'Did you recall this correctly?',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            _ratingButton(
              'Hard',
              Icons.sentiment_dissatisfied_outlined,
              const Color(0xFFEF4444),
            ),
            const SizedBox(width: 8),
            _ratingButton(
              'Good',
              Icons.sentiment_neutral_outlined,
              const Color(0xFF3B82F6),
            ),
            const SizedBox(width: 8),
            _ratingButton(
              'Easy',
              Icons.sentiment_very_satisfied_outlined,
              const Color(0xFF8B5CF6),
            ),
          ],
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: widget.onHideAnswer,
            icon: const Icon(Icons.visibility_off_outlined),
            label: const Text('Hide Answer'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF3B33D1),
              backgroundColor: const Color(0xFFEEF2FF),
              side: const BorderSide(color: Color(0xFFC7D2FE)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Top Bar with Edit and Delete
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBadge('QUESTION'),
        Row(
          children: [
            IconButton(
              onPressed: widget.onEdit,
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Flashcard',
            ),
            IconButton(
              onPressed: widget.onDelete,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFDC2626),
              ),
              tooltip: 'Delete Flashcard',
            ),
          ],
        ),
      ],
    );
  }

  // Reusable Badge
  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4338CA),
        ),
      ),
    );
  }

  // Recall Rating Button
  Widget _ratingButton(String label, IconData icon, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () async {
          try {
            await widget.onRate?.call(label);
            if (mounted) {
              showMessage('Marked as $label!');
            }
          } catch (_) {
            if (mounted) {
              showMessage('Unable to save the recall rating.');
            }
          }
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
