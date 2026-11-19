import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/quote_provider.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style to complement the warm cream aesthetic
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppTheme.warmCream,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => QuoteProvider())],
      child: const QuoteFlowApp(),
    ),
  );
}

class QuoteFlowApp extends StatelessWidget {
  const QuoteFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Spark',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuoteProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      body: Column(
        children: [
          if (provider.initializationError case final error?)
            MaterialBanner(
              content: Text(error),
              actions: [
                TextButton(
                  onPressed: provider.clearInitializationError,
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          Expanded(
            child: IndexedStack(
              index: provider.tabIndex,
              children: const [HomeScreen(), FavoritesScreen()],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const QuoteFlowBottomNavBar(),
    );
  }
}
