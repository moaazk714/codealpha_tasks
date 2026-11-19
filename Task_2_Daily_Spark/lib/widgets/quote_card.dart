import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote.dart';
import '../theme/app_theme.dart';

class MainQuoteCard extends StatelessWidget {
  final Quote quote;
  final int totalQuotes;
  final int currentPosition;

  const MainQuoteCard({
    super.key,
    required this.quote,
    required this.currentPosition,
    this.totalQuotes = 150,
  });
  @override
  Widget build(BuildContext context) {
    // Format category label nicely
    final categoryLabel = quote.category == 'Philosophy'
        ? 'Timeless Philosophy'
        : quote.category;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFEFEBE2), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF173F35).withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Category Pill & Index with soft Quote Mark
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              // Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.mutedGoldLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.mutedGoldBorder, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 12,
                      color: AppTheme.mutedGold,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      categoryLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFA67635),
                      ),
                    ),
                  ],
                ),
              ),

              // Quote Number + Watermark Quotation Mark
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Quote $currentPosition of $totalQuotes',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF7D837E),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '“',
                    style: GoogleFonts.newsreader(
                      fontSize: 34,
                      height: 0.6,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFE2D4BF),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Main Quote Content with smooth key animation
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.04),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              '“${quote.text}”',
              key: ValueKey(quote.id),
              textAlign: TextAlign.center,
              style: GoogleFonts.newsreader(
                fontSize: 23,
                fontWeight: FontWeight.w500,
                color: AppTheme.darkCharcoal,
                height: 1.45,
                letterSpacing: -0.2,
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Decorative Divider with Diamond
          SizedBox(
            width: 140,
            child: Row(
              children: [
                Expanded(
                  child: Container(height: 1, color: AppTheme.mutedGoldBorder),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Transform.rotate(
                    angle: pi / 4,
                    child: Container(
                      width: 6.5,
                      height: 6.5,
                      color: AppTheme.mutedGold,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(height: 1, color: AppTheme.mutedGoldBorder),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Author Name
          Text(
            '— ${quote.author.toUpperCase()}',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: AppTheme.darkCharcoal,
            ),
          ),

          if (quote.authorBio.isNotEmpty) ...[
            const SizedBox(height: 10),
            // Author Bio Sub-badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF2EE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                quote.authorBio,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF5A6B5E),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
