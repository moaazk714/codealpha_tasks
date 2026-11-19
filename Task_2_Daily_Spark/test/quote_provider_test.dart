import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:random_quote_generator/models/quote.dart';
import 'package:random_quote_generator/providers/quote_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('random quotes keep their associated author and category', () async {
    final provider = QuoteProvider();
    await provider.initialized;

    for (var i = 0; i < 20; i++) {
      final previousQuote = provider.currentQuote;
      provider.nextRandomQuote();

      expect(provider.currentQuote, isNotNull);
      expect(provider.currentQuote!.id, isNot(previousQuote!.id));
      expect(provider.allQuotes, contains(provider.currentQuote));
      expect(provider.currentQuotePosition, inInclusiveRange(1, 36));
    }
  });

  test(
    'favorites and custom quotes persist and custom quotes can be deleted',
    () async {
      final provider = QuoteProvider();
      await provider.initialized;

      final addedFavorite = await provider.toggleFavorite(
        provider.allQuotes[4],
      );
      expect(addedFavorite, isTrue);
      expect(provider.favoritesCount, 5);

      await provider.addCustomQuote(text: '  Keep going.  ', author: '  Sam  ');
      final customQuote = provider.currentQuote!;
      expect(customQuote.text, 'Keep going.');
      expect(customQuote.author, 'Sam');
      expect(provider.customQuotes, contains(customQuote));

      await provider.toggleFavorite(customQuote);

      final restoredProvider = QuoteProvider();
      await restoredProvider.initialized;
      expect(restoredProvider.favoritesCount, 6);
      expect(restoredProvider.isFavorite(customQuote), isTrue);
      expect(restoredProvider.customQuotes, contains(customQuote));

      await expectLater(
        restoredProvider.deleteCustomQuote(restoredProvider.allQuotes.first),
        throwsArgumentError,
      );
      expect(restoredProvider.allQuotes.first.id, 'quote_1');

      await restoredProvider.deleteCustomQuote(customQuote);
      expect(restoredProvider.customQuotes, isEmpty);
      expect(restoredProvider.isFavorite(customQuote), isFalse);

      final afterDeleteProvider = QuoteProvider();
      await afterDeleteProvider.initialized;
      expect(afterDeleteProvider.customQuotes, isEmpty);
      expect(afterDeleteProvider.isFavorite(customQuote), isFalse);
      expect(afterDeleteProvider.favoritesCount, 5);
    },
  );

  test('custom quote text is required', () async {
    final provider = QuoteProvider();
    await provider.initialized;

    await expectLater(
      provider.addCustomQuote(text: ' \n ', author: 'Sam'),
      throwsArgumentError,
    );
    expect(provider.customQuotes, isEmpty);
  });

  test('favorite category filters return only matching quotes', () async {
    final provider = QuoteProvider();
    await provider.initialized;

    provider.setSelectedCategory('Motivation');

    expect(provider.filteredFavorites, hasLength(1));
    expect(provider.filteredFavorites.single.category, 'Motivation');
    expect(provider.availableCategories, contains('Motivation'));
  });

  test('all favorites cannot be mutated through the filtered getter', () async {
    final provider = QuoteProvider();
    await provider.initialized;

    expect(
      () => provider.filteredFavorites.add(provider.allQuotes[4]),
      throwsUnsupportedError,
    );
    expect(provider.favoritesCount, 4);
  });

  test('duplicate saved quotes are loaded only once', () async {
    final customQuote = Quote(
      id: 'custom_saved',
      text: 'A saved thought.',
      author: 'Sam',
      category: 'Custom',
      authorBio: '',
      quoteNumber: 0,
    );
    final favorite = Quote(
      id: 'quote_1',
      text: 'The future depends on what you do today.',
      author: 'MAHATMA GANDHI',
      category: 'Motivation',
      authorBio: 'Visionary & Leader • 1869 – 1948',
      quoteNumber: 42,
    );
    SharedPreferences.setMockInitialValues({
      'daily_spark_custom_quotes_v1': jsonEncode([
        customQuote.toJson(),
        customQuote.toJson(),
      ]),
      'quote_flow_has_run_before': true,
      'quote_flow_saved_favorites_v1': jsonEncode([
        favorite.toJson(),
        favorite.toJson(),
      ]),
    });

    final provider = QuoteProvider();
    await provider.initialized;

    expect(provider.customQuotes, hasLength(1));
    expect(provider.allQuotes, hasLength(37));
    expect(provider.favorites, hasLength(1));
  });

  test('invalid custom storage does not partially load quotes', () async {
    final customQuote = Quote(
      id: 'custom_saved',
      text: 'A saved thought.',
      author: 'Sam',
      category: 'Custom',
      authorBio: '',
      quoteNumber: 0,
    );
    SharedPreferences.setMockInitialValues({
      'daily_spark_custom_quotes_v1': jsonEncode([
        customQuote.toJson(),
        'invalid quote data',
      ]),
    });

    final provider = QuoteProvider();
    await provider.initialized;

    expect(provider.initializationError, isNotNull);
    expect(provider.customQuotes, isEmpty);
    expect(provider.allQuotes, hasLength(36));
  });

  test('initialization failures are exposed instead of hidden', () async {
    SharedPreferences.setMockInitialValues({
      'daily_spark_custom_quotes_v1': 'invalid json',
    });

    final provider = QuoteProvider();
    await provider.initialized;

    expect(provider.isLoading, isFalse);
    expect(provider.initializationError, isNotNull);
    expect(provider.currentQuote, isNotNull);

    provider.clearInitializationError();
    expect(provider.initializationError, isNull);
  });
}
