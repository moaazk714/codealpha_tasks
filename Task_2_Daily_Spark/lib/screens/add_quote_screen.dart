import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/quote_provider.dart';
import '../theme/app_theme.dart';

class AddQuoteScreen extends StatefulWidget {
  const AddQuoteScreen({super.key});

  @override
  State<AddQuoteScreen> createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends State<AddQuoteScreen> {
  // Controllers for text fields
  final TextEditingController quoteController = TextEditingController();

  final TextEditingController authorController = TextEditingController();

  bool isSaving = false;

  @override
  void dispose() {
    quoteController.dispose();
    authorController.dispose();
    super.dispose();
  }

  // Save quote using QuoteProvider
  Future<void> saveQuote() async {
    final quote = quoteController.text.trim();
    final author = authorController.text.trim();

    // Check if quote is empty
    if (quote.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a quote.')));
      return;
    }

    // Prevent multiple button presses
    setState(() {
      isSaving = true;
    });

    try {
      // Add quote to Provider and SharedPreferences
      await context.read<QuoteProvider>().addCustomQuote(
        text: quote,
        author: author,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your quote has been saved successfully!'),
        ),
      );

      // Return to previous screen
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to save quote: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.warmCream,

      appBar: AppBar(
        backgroundColor: AppTheme.warmCream,
        foregroundColor: AppTheme.deepEmerald,
        elevation: 0,
        title: Text(
          'Create Your Quote',
          style: GoogleFonts.newsreader(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Heading
            Text(
              'Your Inspiration',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepEmerald,
              ),
            ),

            const SizedBox(height: 10),

            // Quote Text Field
            TextField(
              controller: quoteController,
              maxLines: 5,
              maxLength: 350,
              decoration: InputDecoration(
                hintText: 'Write your motivational quote...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Author Heading
            Text(
              'Author Name',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.deepEmerald,
              ),
            ),

            const SizedBox(height: 10),

            // Author Text Field
            TextField(
              controller: authorController,
              decoration: InputDecoration(
                hintText: 'Enter author name (optional)',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveQuote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.deepEmerald,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Save Quote',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
