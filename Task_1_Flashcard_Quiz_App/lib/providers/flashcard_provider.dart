import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/flashcard.dart';

/// Provider to manage the state of flashcards, current card index,
/// and answer visibility.
class FlashcardProvider extends ChangeNotifier {
  /// Internal list of flashcards.
  static const String _storageKey = 'flashcards';

  static const List<Flashcard> _defaultFlashcards = [
    Flashcard(
      id: '1',
      question: 'What is Flutter?',
      answer:
          "Flutter is Google's UI toolkit for building applications from a single codebase across mobile, web, and desktop.",
      category: 'Core Frameworks & Architecture',
      tags: ['Dart Language', 'Hot Reload', 'Skia Engine'],
      confidence: 'Mastered',
    ),
    Flashcard(
      id: '2',
      question: 'What is the purpose of StatefulWidget in Flutter?',
      answer:
          'A StatefulWidget has mutable state that can change over time. Calling setState() schedules a rebuild of the widget to reflect the new state.',
      category: 'Widget Tree & Lifecycle',
      tags: ['State Management', 'setState', 'Rebuilds'],
      confidence: 'Review',
    ),
    Flashcard(
      id: '3',
      question: 'What is the role of BuildContext?',
      answer:
          'BuildContext is a handle to the location of a widget in the widget tree. It is used to look up inherited widgets, themes, and media queries.',
      category: 'Core Frameworks & Architecture',
      tags: ['BuildContext', 'InheritedWidget', 'Theme'],
      confidence: 'Review',
    ),
    Flashcard(
      id: '4',
      question: 'How does Provider manage state in Flutter apps?',
      answer:
          'Provider uses InheritedWidget under the hood to efficiently inject state and notify listening widgets whenever notifyListeners() is called.',
      category: 'State Management',
      tags: ['Provider', 'ChangeNotifier', 'Reactive UI'],
      confidence: 'New',
    ),
    Flashcard(
      id: '5',
      question: 'What is the difference between Hot Reload and Hot Restart?',
      answer:
          'Hot Reload injects updated code into the running Dart VM while preserving the current app state. Hot Restart resets the app state and restarts the app from scratch.',
      category: 'Developer Tooling',
      tags: ['Hot Reload', 'Hot Restart', 'Dart VM'],
      confidence: 'Mastered',
    ),
    Flashcard(
      id: '6',
      question: 'What is an InheritedWidget?',
      answer:
          'An InheritedWidget is a base class that efficiently propagates information down the widget tree without having to pass parameters through constructors.',
      category: 'Architecture Patterns',
      tags: ['InheritedWidget', 'Optimization', 'Tree Lookup'],
      confidence: 'Review',
    ),
    Flashcard(
      id: '7',
      question: 'What is the purpose of pubspec.yaml?',
      answer:
          'pubspec.yaml is the metadata and dependency configuration file for a Dart/Flutter project, specifying SDK versions, third-party packages, fonts, and assets.',
      category: 'Flutter Fundamentals',
      tags: ['pubspec', 'Dependencies', 'Assets'],
      confidence: 'Mastered',
    ),
  ];

  final List<Flashcard> _flashcards = List.of(_defaultFlashcards);

  /// Current active flashcard index (0-indexed).
  int _currentIndex = 0;

  /// Whether the answer of the current card is revealed.
  bool _isAnswerVisible = false;

  /// User's study streak in days.
  final int _streakDays = 3;

  bool _isLoading = true;
  late final Future<void> _initialization;
  Future<void> _pendingSave = Future<void>.value();

  FlashcardProvider() {
    _initialization = _loadFlashcards();
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  /// Whether saved flashcards are still being loaded.
  bool get isLoading => _isLoading;

  /// Completes when saved flashcards have finished loading.
  Future<void> get initialized => _initialization;

  /// Read-only view of the flashcards.
  List<Flashcard> get flashcards => List.unmodifiable(_flashcards);

  /// Current flashcard index.
  int get currentIndex => _currentIndex;

  /// Whether the answer is currently visible.
  bool get isAnswerVisible => _isAnswerVisible;

  /// Current flashcard or null if the list is empty.
  Flashcard? get currentCard {
    if (_flashcards.isEmpty || _currentIndex >= _flashcards.length) {
      return null;
    }
    return _flashcards[_currentIndex];
  }

  /// Total number of flashcards.
  int get totalCards => _flashcards.length;

  /// Whether there are any flashcards.
  bool get hasCards => _flashcards.isNotEmpty;

  /// Whether navigation to a previous card is available.
  bool get hasPrevious => _currentIndex > 0;

  /// Whether navigation to a next card is available.
  bool get hasNext => _currentIndex < _flashcards.length - 1;

  /// Progress fraction (0.0 to 1.0) of study progress.
  double get progress {
    if (_flashcards.isEmpty) return 0.0;
    return (_currentIndex + 1) / _flashcards.length;
  }

  /// Completion percentage formatted as integer (e.g. 12% or 50%).
  int get completionPercentage {
    if (_flashcards.isEmpty) return 0;
    return ((progress) * 100).round();
  }

  /// Remaining cards after the current one.
  int get remainingCards {
    if (_flashcards.isEmpty) return 0;
    return _flashcards.length - (_currentIndex + 1);
  }

  /// Current study streak.
  int get streakDays => _streakDays;

  Future<void> _loadFlashcards() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedFlashcards = preferences.getString(_storageKey);

      if (savedFlashcards != null) {
        final decoded = jsonDecode(savedFlashcards);
        if (decoded is! List) {
          throw const FormatException('Saved flashcards must be a list.');
        }

        final loadedFlashcards = decoded.map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Saved flashcard must be an object.');
          }
          return Flashcard.fromJson(item);
        }).toList();

        _flashcards
          ..clear()
          ..addAll(loadedFlashcards);
        _currentIndex = 0;
        _isAnswerVisible = false;
      }
    } on FormatException catch (error, stackTrace) {
      developer.log(
        'Ignoring corrupted saved flashcards; using the default deck.',
        name: 'flashcard.storage',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      developer.log(
        'Failed to load saved flashcards; using the default deck.',
        name: 'flashcard.storage',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistFlashcards() {
    final encodedFlashcards = jsonEncode(
      _flashcards.map((flashcard) => flashcard.toJson()).toList(),
    );

    final save = _pendingSave.then((_) async {
      final preferences = await SharedPreferences.getInstance();
      final saved = await preferences.setString(_storageKey, encodedFlashcards);
      if (!saved) {
        throw StateError('SharedPreferences rejected the flashcard update.');
      }
    });

    _pendingSave = save.catchError((Object error, StackTrace stackTrace) {
      developer.log(
        'Failed to save flashcards to SharedPreferences.',
        name: 'flashcard.storage',
        error: error,
        stackTrace: stackTrace,
      );
    });
    return save;
  }

  // ---------------------------------------------------------------------------
  // Card Actions & Navigation
  // ---------------------------------------------------------------------------

  /// Shows the answer for the current card.
  void showAnswer() {
    if (!_isAnswerVisible) {
      _isAnswerVisible = true;
      notifyListeners();
    }
  }

  /// Hides the answer for the current card.
  void hideAnswer() {
    if (_isAnswerVisible) {
      _isAnswerVisible = false;
      notifyListeners();
    }
  }

  /// Toggles the answer visibility.
  void toggleAnswer() {
    _isAnswerVisible = !_isAnswerVisible;
    notifyListeners();
  }

  /// Moves to the next flashcard, if available.
  void nextCard() {
    if (hasNext) {
      _currentIndex++;
      _isAnswerVisible = false;
      notifyListeners();
    }
  }

  /// Moves to the previous flashcard, if available.
  void previousCard() {
    if (hasPrevious) {
      _currentIndex--;
      _isAnswerVisible = false;
      notifyListeners();
    }
  }

  /// Adds a new flashcard to the deck.
  Future<void> addFlashcard(Flashcard newCard) async {
    await initialized;
    _flashcards.add(newCard);
    // If it was empty before, point to index 0
    if (_flashcards.length == 1) {
      _currentIndex = 0;
      _isAnswerVisible = false;
    }
    notifyListeners();
    await _persistFlashcards();
  }

  /// Updates an existing flashcard at the given [index].
  Future<void> editFlashcard(int index, Flashcard updatedCard) async {
    await initialized;
    if (index >= 0 && index < _flashcards.length) {
      _flashcards[index] = updatedCard;
      notifyListeners();
      await _persistFlashcards();
    }
  }

  /// Deletes the flashcard at the given [index] safely.
  Future<void> deleteFlashcard(int index) async {
    await initialized;
    if (index < 0 || index >= _flashcards.length) return;

    _flashcards.removeAt(index);

    // If deck is empty, reset index and answer visibility
    if (_flashcards.isEmpty) {
      _currentIndex = 0;
      _isAnswerVisible = false;
    } else if (_currentIndex >= _flashcards.length) {
      // If deleted card was the last card, adjust index to new last card
      _currentIndex = _flashcards.length - 1;
      _isAnswerVisible = false;
    } else {
      // Still within range; reset answer visibility for the newly surfaced card
      _isAnswerVisible = false;
    }

    notifyListeners();
    await _persistFlashcards();
  }

  /// Updates confidence/mastery rating for current card.
  Future<void> rateRecall(String rating) async {
    await initialized;
    if (currentCard == null) return;
    final updated = currentCard!.copyWith(confidence: rating);
    _flashcards[_currentIndex] = updated;
    notifyListeners();
    await _persistFlashcards();
  }

  /// Resets session back to the first card.
  void resetSession() {
    _currentIndex = 0;
    _isAnswerVisible = false;
    notifyListeners();
  }
}
