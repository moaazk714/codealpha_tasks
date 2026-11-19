import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:random_quote_generator/screens/add_quote_screen.dart';
import 'package:random_quote_generator/screens/all_quotes_screen.dart';
import '../providers/quote_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/action_buttons.dart';
import '../widgets/app_header.dart';
import '../widgets/mindful_reflection_card.dart';
import '../widgets/quote_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuoteProvider>(context);
    final currentQuote = provider.currentQuote;

    if (provider.isLoading || currentQuote == null) {
      return const Scaffold(
        backgroundColor: AppTheme.warmCream,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.deepEmerald),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top App Bar
            const AppHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Badge: ✨ MOTIVATIONAL • DAILY SPARK
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5EDE6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFD6E3D8),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 15,
                            color: AppTheme.deepEmerald,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'MOTIVATIONAL • DAILY SPARK',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.1,
                                color: AppTheme.deepEmerald,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Title: A Little Inspiration for Today
                    Text(
                      'A Little Inspiration for Today',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.newsreader(
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.deepEmerald,
                        letterSpacing: -0.3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Subtitle: Discover words that inspire you.
                    Text(
                      'Discover words that inspire you.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        color: const Color(0xFF6B756D),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Main Quote Card
                    MainQuoteCard(
                      quote: currentQuote,
                      currentPosition: provider.currentQuotePosition,
                      totalQuotes: provider.totalQuotesCount,
                    ),

                    const SizedBox(height: 14),

                    // Mindful Reflection Card
                    MindfulReflectionCard(quote: currentQuote),

                    const SizedBox(height: 18),

                    // Action Buttons Row (New Quote, Copy, Favorite)
                    ActionButtonsRow(quote: currentQuote),

                    const SizedBox(height: 18),

                    // Create Your Own Quote Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddQuoteScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: Text(
                          'Create Your Own Quote',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.deepEmerald,
                          side: const BorderSide(color: AppTheme.deepEmerald),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllQuotesScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shadowColor: Colors.black,
                        elevation: 8,
                      ),
                      label: const Text('Explore all quotes'),
                    ), // Footer Hint
                    SizedBox(height: 15),
                    Text(
                      'Find inspiration in every moment.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF7E887F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 36,
                      height: 3,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE4DFD6),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
