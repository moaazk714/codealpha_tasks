import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:random_quote_generator/main.dart';
import 'package:random_quote_generator/models/quote.dart';
import 'package:random_quote_generator/providers/quote_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Scenario 1: App launches and displays a valid random quote', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => QuoteProvider())],
        child: const QuoteFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header branding
    expect(find.text('Daily Spark'), findsWidgets);

    // Verify quote badge and inspiration heading
    expect(find.text('MOTIVATIONAL • DAILY SPARK'), findsOneWidget);
    expect(find.text('A Little Inspiration for Today'), findsOneWidget);

    // Verify New Quote and Copy buttons exist
    expect(find.text('New Quote'), findsOneWidget);
    expect(find.text('Copy'), findsOneWidget);
  });

  testWidgets('Scenario 2: Tapping "New Quote" changes quote and author', (
    WidgetTester tester,
  ) async {
    final provider = QuoteProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const QuoteFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    final initialQuote = provider.currentQuote;
    expect(initialQuote, isNotNull);

    // Tap New Quote button
    await tester.ensureVisible(find.text('New Quote'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Quote'));
    await tester.pumpAndSettle();

    final updatedQuote = provider.currentQuote;
    expect(updatedQuote, isNotNull);
    // Verifies consecutive quotes do not match
    expect(updatedQuote!.id, isNot(equals(initialQuote!.id)));
  });

  testWidgets('Scenario 3: Copy Quote copies text and shows SnackBar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => QuoteProvider())],
        child: const QuoteFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Copy'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy'));
    await tester.pump(); // Start SnackBar animation
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Quote copied successfully!'), findsOneWidget);
  });

  testWidgets(
    'Scenario 4: Favorites screen lists saved quotes and handles removal',
    (WidgetTester tester) async {
      final provider = QuoteProvider();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const QuoteFlowApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Favorites tab
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();

      expect(find.text('Your Favorite Quotes'), findsOneWidget);

      // Verify pre-populated 4 items exist
      expect(provider.favoritesCount, equals(4));

      await tester.scrollUntilVisible(
        find.text('POETRY & INK ARCHIVE'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('POETRY & INK ARCHIVE'), findsOneWidget);

      await tester.scrollUntilVisible(
        find.text("Keeper's Note"),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text("Keeper's Note"), findsOneWidget);

      // Remove one item using provider
      final firstFav = provider.favorites.first;
      await provider.removeFavorite(firstFav);
      await tester.pumpAndSettle();

      expect(provider.favoritesCount, equals(3));
    },
  );

  testWidgets(
    'Scenario 5: Empty state renders when all favorites are removed',
    (WidgetTester tester) async {
      final provider = QuoteProvider();
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const QuoteFlowApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Clear all favorites
      for (final quote in List<Quote>.from(provider.favorites)) {
        await provider.removeFavorite(quote);
      }

      // Switch to Favorites tab
      await tester.tap(find.text('Favorites'));
      await tester.pumpAndSettle();

      // Empty state should now appear
      expect(find.text('No Favorites Yet'), findsOneWidget);
      expect(find.text('Explore Daily Quotes'), findsOneWidget);

      // Tap Explore Quotes button to return to Home
      await tester.ensureVisible(find.text('Explore Daily Quotes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Explore Daily Quotes'));
      await tester.pumpAndSettle();

      expect(provider.tabIndex, equals(0));
      expect(find.text('A Little Inspiration for Today'), findsOneWidget);
    },
  );

  testWidgets('All Quotes can be searched by author and quote text', (
    WidgetTester tester,
  ) async {
    final provider = QuoteProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const QuoteFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Explore all quotes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore all quotes'));
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'Mahatma Gandhi');
    await tester.pumpAndSettle();
    expect(find.text('3 Quotes'), findsOneWidget);

    await tester.enterText(searchField, 'difficulty lies opportunity');
    await tester.pumpAndSettle();
    expect(find.text('1 Quotes'), findsOneWidget);
  });

  testWidgets('Custom quote deletion is available only for custom quotes', (
    WidgetTester tester,
  ) async {
    final provider = QuoteProvider();
    await provider.initialized;
    await provider.addCustomQuote(text: 'A custom thought.', author: 'Me');

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const QuoteFlowApp(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Explore all quotes'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore all quotes'));
    await tester.pumpAndSettle();

    final searchField = find.byType(TextField);
    await tester.enterText(searchField, 'A custom thought');
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete custom quote'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete custom quote'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(provider.customQuotes, isEmpty);
    expect(find.byTooltip('Delete custom quote'), findsNothing);

    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();
    expect(find.byTooltip('Delete custom quote'), findsNothing);
  });

  testWidgets('Narrow screens render and the custom quote form can scroll', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = QuoteProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const QuoteFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Create Your Own Quote'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Your Own Quote'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Save Quote'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Quote'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a quote.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Long custom authors do not overflow favorite cards', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final provider = QuoteProvider();
    await provider.initialized;
    await provider.addCustomQuote(
      text: 'A thought worth keeping.',
      author:
          'An exceptionally long custom author name that wraps on small screens',
    );
    await provider.toggleFavorite(provider.currentQuote!);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const QuoteFlowApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    final layoutException = tester.takeException();
    expect(layoutException, isNull);
    await tester.scrollUntilVisible(
      find.textContaining('EXCEPTIONALLY LONG CUSTOM AUTHOR'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
      find.textContaining('EXCEPTIONALLY LONG CUSTOM AUTHOR'),
      findsOneWidget,
    );
  });
}
