import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:random_quote_generator/screens/add_quote_screen.dart';

import '../models/quote.dart';
import '../providers/quote_provider.dart';
import '../theme/app_theme.dart';

class AllQuotesScreen extends StatefulWidget {
  const AllQuotesScreen({super.key});

  @override
  State<AllQuotesScreen> createState() => _AllQuotesScreenState();
}

class _AllQuotesScreenState extends State<AllQuotesScreen> {
  final TextEditingController searchController = TextEditingController();

  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> deleteQuote(BuildContext context, Quote quote) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Quote?'),
          content: const Text(
            'Are you sure you want to delete this custom quote?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      try {
        await context.read<QuoteProvider>().deleteCustomQuote(quote);
      } catch (error) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to delete quote: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 5,
        backgroundColor: AppTheme.deepEmerald,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddQuoteScreen()),
          );
        },
      ),
      backgroundColor: AppTheme.warmCream,
      appBar: AppBar(
        backgroundColor: AppTheme.warmCream,
        foregroundColor: AppTheme.deepEmerald,
        elevation: 0,
        title: Text(
          'All Quotes',
          style: GoogleFonts.newsreader(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Consumer<QuoteProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.deepEmerald),
            );
          }

          // Get all predefined and custom quotes.
          final allQuotes = provider.allQuotes;

          // Search quotes by text or author.
          final filteredQuotes = allQuotes.where((quote) {
            final text = quote.text.toLowerCase();
            final author = quote.author.toLowerCase();

            return text.contains(searchQuery.toLowerCase()) ||
                author.contains(searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search quotes or authors...',
                    hintStyle: GoogleFonts.poppins(fontSize: 13),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.deepEmerald,
                    ),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              setState(() {
                                searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.close),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Quote Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      '${filteredQuotes.length} Quotes',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.deepEmerald,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${provider.favoritesCount} Favorites',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // All Quotes List
              Expanded(
                child: filteredQuotes.isEmpty
                    ? Center(
                        child: Text(
                          'No quotes found.',
                          style: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
                        itemCount: filteredQuotes.length,
                        itemBuilder: (context, index) {
                          final quote = filteredQuotes[index];

                          final isFavorite = provider.isFavorite(quote);

                          // Identify custom quotes.
                          final isCustom = quote.id.startsWith('custom_');

                          return _buildQuoteCard(
                            context,
                            provider,
                            quote,
                            isFavorite,
                            isCustom,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuoteCard(
    BuildContext context,
    QuoteProvider provider,
    Quote quote,
    bool isFavorite,
    bool isCustom,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EDE6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row
          Row(
            children: [
              const Icon(
                Icons.format_quote_rounded,
                color: AppTheme.deepEmerald,
                size: 27,
              ),

              const Spacer(),

              if (isCustom)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EDE6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'MY QUOTE',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.deepEmerald,
                    ),
                  ),
                )
              else
                Text(
                  quote.category,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Quote Text
          Text(
            '“${quote.text}”',
            style: GoogleFonts.newsreader(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: AppTheme.deepEmerald,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 12),

          // Author
          Text(
            '— ${quote.author}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),

          const SizedBox(height: 12),

          const Divider(color: Color(0xFFE5EDE6)),

          // Bottom Actions
          Row(
            children: [
              // Favorite Button
              IconButton(
                onPressed: () async {
                  try {
                    await provider.toggleFavorite(quote);
                  } catch (error) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Unable to update favorites: $error'),
                      ),
                    );
                  }
                },
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite
                      ? const Color(0xFFE26D5C)
                      : AppTheme.deepEmerald,
                ),
                tooltip: 'Favorite',
              ),

              // Copy Button
              IconButton(
                onPressed: () {
                  final text = '“${quote.text}”\n— ${quote.author}';

                  Clipboard.setData(ClipboardData(text: text));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Quote copied!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.copy_rounded,
                  color: AppTheme.deepEmerald,
                  size: 20,
                ),
                tooltip: 'Copy quote',
              ),

              const Spacer(),

              // Delete Button (Custom Quotes Only)
              if (isCustom)
                IconButton(
                  onPressed: () {
                    deleteQuote(context, quote);
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'Delete custom quote',
                ),
            ],
          ),
        ],
      ),
    );
  }
}
