import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/quotes_data.dart';
import '../models/quote.dart';

class QuoteProvider extends ChangeNotifier {
  // Storage keys
  static const String _favoritesStorageKey = 'quote_flow_saved_favorites_v1';

  static const String _firstLaunchKey = 'quote_flow_has_run_before';

  static const String _customQuotesKey = 'daily_spark_custom_quotes_v1';

  // All quotes
  final List<Quote> _quotes = List.from(initialQuotes);

  // Custom quotes only
  final List<Quote> _customQuotes = [];

  // Favorite quotes
  List<Quote> _favorites = [];

  Quote? _currentQuote;

  String _selectedCategory = 'All';

  int _tabIndex = 0;

  bool _isLoading = true;

  String? _initializationError;

  final Random _random = Random();

  final List<String> _recentHistory = [];

  QuoteProvider() {
    _initialization = _initialize();
  }

  late final Future<void> _initialization;

  Future<void> get initialized => _initialization;

  // ---------------- GETTERS ----------------

  Quote? get currentQuote => _currentQuote;

  List<Quote> get allQuotes => List.unmodifiable(_quotes);

  List<Quote> get customQuotes => List.unmodifiable(_customQuotes);

  List<Quote> get favorites => List.unmodifiable(_favorites);

  int get favoritesCount => _favorites.length;

  int get totalQuotesCount => _quotes.length;

  String get selectedCategory => _selectedCategory;

  int get tabIndex => _tabIndex;

  bool get isLoading => _isLoading;

  String? get initializationError => _initializationError;

  int get currentQuotePosition {
    if (_currentQuote == null) return 0;

    final index = _quotes.indexWhere((quote) => quote.id == _currentQuote!.id);

    return index == -1 ? 0 : index + 1;
  }

  // Filter favorites by category
  List<Quote> get filteredFavorites {
    if (_selectedCategory == 'All') {
      return List.unmodifiable(_favorites);
    }

    return _favorites.where((quote) {
      return quote.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();
  }

  // Available favorite categories
  List<String> get availableCategories {
    final categories = <String>{'All'};

    for (final quote in _favorites) {
      categories.add(quote.category);
    }

    return categories.toList();
  }

  // ---------------- INITIALIZATION ----------------

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load custom quotes
      final customJson = prefs.getString(_customQuotesKey);

      if (customJson != null && customJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(customJson);
        final uniqueCustomQuotes = <String, Quote>{};
        for (final item in decoded) {
          final quote = Quote.fromJson(item as Map<String, dynamic>);
          if (!quote.id.startsWith('custom_') ||
              quote.id.length == 'custom_'.length ||
              quote.text.trim().isEmpty) {
            throw const FormatException('Invalid saved custom quote.');
          }

          uniqueCustomQuotes.putIfAbsent(quote.id, () => quote);
        }

        _customQuotes.addAll(uniqueCustomQuotes.values);
        _quotes.addAll(_customQuotes);
      }

      // Load favorites
      final hasRunBefore = prefs.getBool(_firstLaunchKey) ?? false;

      if (!hasRunBefore) {
        _favorites = _quotes.take(4).toList();

        await _saveFavoritesToStorage();

        final savedFirstLaunchFlag = await prefs.setBool(_firstLaunchKey, true);
        if (!savedFirstLaunchFlag) {
          throw StateError('Unable to save first-launch state.');
        }
      } else {
        final savedJson = prefs.getString(_favoritesStorageKey);

        if (savedJson != null && savedJson.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(savedJson);
          final uniqueFavorites = <String, Quote>{};
          for (final item in decoded) {
            final quote = Quote.fromJson(item as Map<String, dynamic>);
            if (quote.id.isEmpty || quote.text.trim().isEmpty) {
              throw const FormatException('Invalid saved favorite.');
            }

            uniqueFavorites.putIfAbsent(quote.id, () => quote);
          }
          _favorites = uniqueFavorites.values.toList();
        }
      }
    } catch (error, stackTrace) {
      _initializationError = 'Saved quote data could not be loaded.';
      debugPrint('Initialization error: $error\n$stackTrace');
    }

    // Set first quote
    if (_quotes.isNotEmpty) {
      _currentQuote = _quotes[0];
      _recentHistory.add(_quotes[0].id);
    }

    _isLoading = false;
    notifyListeners();
  }

  // ---------------- SAVE CUSTOM QUOTES ----------------

  Future<void> _saveCustomQuotes() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      _customQuotes.map((quote) => quote.toJson()).toList(),
    );

    final saved = await prefs.setString(_customQuotesKey, encoded);
    if (!saved) {
      throw StateError('Unable to save custom quotes.');
    }
  }

  // Add a new custom quote
  Future<void> addCustomQuote({
    required String text,
    required String author,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) {
      throw ArgumentError.value(text, 'text', 'Quote text cannot be empty.');
    }

    final newQuote = Quote(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
      text: trimmedText,
      author: author.trim().isEmpty ? 'Unknown' : author.trim(),
      category: 'Custom',
      authorBio: '',
      quoteNumber: 0,
    );

    _customQuotes.add(newQuote);
    _quotes.add(newQuote);

    try {
      await _saveCustomQuotes();
    } catch (_) {
      _customQuotes.removeWhere((item) => item.id == newQuote.id);
      _quotes.removeWhere((item) => item.id == newQuote.id);
      rethrow;
    }

    _currentQuote = newQuote;
    _recentHistory
      ..clear()
      ..add(newQuote.id);

    notifyListeners();
  }

  // Delete a custom quote
  Future<void> deleteCustomQuote(Quote quote) async {
    if (!_customQuotes.any((item) => item.id == quote.id)) {
      throw ArgumentError.value(
        quote.id,
        'quote',
        'Only saved custom quotes can be deleted.',
      );
    }

    final previousCustomQuotes = List<Quote>.of(_customQuotes);
    final previousQuotes = List<Quote>.of(_quotes);
    final previousFavorites = List<Quote>.of(_favorites);
    final previousCurrentQuote = _currentQuote;
    final previousHistory = List<String>.of(_recentHistory);

    _customQuotes.removeWhere((item) => item.id == quote.id);

    _quotes.removeWhere((item) => item.id == quote.id);

    _favorites.removeWhere((item) => item.id == quote.id);

    _recentHistory.clear();

    if (_currentQuote?.id == quote.id) {
      _currentQuote = _quotes.isNotEmpty ? _quotes[0] : null;
      if (_currentQuote != null) {
        _recentHistory.add(_currentQuote!.id);
      }
    }

    try {
      await _saveCustomQuotes();
      await _saveFavoritesToStorage();
    } catch (_) {
      _customQuotes
        ..clear()
        ..addAll(previousCustomQuotes);
      _quotes
        ..clear()
        ..addAll(previousQuotes);
      _favorites = previousFavorites;
      _currentQuote = previousCurrentQuote;
      _recentHistory
        ..clear()
        ..addAll(previousHistory);
      notifyListeners();
      rethrow;
    }

    notifyListeners();
  }

  // ---------------- RANDOM QUOTES ----------------

  void nextRandomQuote() {
    if (_quotes.length <= 1) return;

    final alternatives = _quotes
        .where((quote) => quote.id != _currentQuote?.id)
        .toList();
    final notRecentlyShown = alternatives
        .where((quote) => !_recentHistory.contains(quote.id))
        .toList();
    final candidates = notRecentlyShown.isEmpty
        ? alternatives
        : notRecentlyShown;

    _currentQuote = candidates[_random.nextInt(candidates.length)];

    _recentHistory.add(_currentQuote!.id);

    if (_recentHistory.length > 5) {
      _recentHistory.removeAt(0);
    }

    notifyListeners();
  }

  // ---------------- FAVORITES ----------------

  bool isFavorite(Quote quote) {
    return _favorites.any((item) => item.id == quote.id);
  }

  Future<void> _saveFavoritesToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final encoded = jsonEncode(
      _favorites.map((quote) => quote.toJson()).toList(),
    );

    final saved = await prefs.setString(_favoritesStorageKey, encoded);
    if (!saved) {
      throw StateError('Unable to save favorites.');
    }
  }

  Future<bool> toggleFavorite(Quote quote) async {
    final previousFavorites = List<Quote>.of(_favorites);
    final index = _favorites.indexWhere((item) => item.id == quote.id);

    bool added;

    if (index >= 0) {
      _favorites.removeAt(index);
      added = false;
    } else {
      _favorites.add(quote);
      added = true;
    }

    try {
      await _saveFavoritesToStorage();
    } catch (_) {
      _favorites = previousFavorites;
      notifyListeners();
      rethrow;
    }

    notifyListeners();

    return added;
  }

  Future<void> removeFavorite(Quote quote) async {
    final previousFavorites = List<Quote>.of(_favorites);
    _favorites.removeWhere((item) => item.id == quote.id);

    try {
      await _saveFavoritesToStorage();
    } catch (_) {
      _favorites = previousFavorites;
      notifyListeners();
      rethrow;
    }

    notifyListeners();
  }

  // ---------------- CATEGORY ----------------

  void setSelectedCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }

  // ---------------- NAVIGATION ----------------

  void setTabIndex(int index) {
    if (_tabIndex != index) {
      _tabIndex = index;
      notifyListeners();
    }
  }

  void clearInitializationError() {
    if (_initializationError != null) {
      _initializationError = null;
      notifyListeners();
    }
  }
}
