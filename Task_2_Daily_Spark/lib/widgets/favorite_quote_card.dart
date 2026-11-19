import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/quote.dart';
import '../providers/quote_provider.dart';
import '../theme/app_theme.dart';

class FavoriteQuoteCard extends StatelessWidget {
  final Quote quote;
  final int archiveIndex;

  const FavoriteQuoteCard({
    super.key,
    required this.quote,
    required this.archiveIndex,
  });

  void _copyQuote(BuildContext context) {
    final textToCopy = '“${quote.text}”\n— ${quote.author}';
    Clipboard.setData(ClipboardData(text: textToCopy));

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppTheme.softGreen,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'Quote copied successfully!',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.deepEmerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _removeFavorite(BuildContext context) async {
    final provider = Provider.of<QuoteProvider>(context, listen: false);
    final removedQuote = quote;
    try {
      await provider.removeFavorite(quote);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update favorites: $error')),
      );
      return;
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Removed from favorites.',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: AppTheme.mutedGold,
          onPressed: () async {
            try {
              await provider.toggleFavorite(removedQuote);
            } catch (error) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Unable to restore favorite: $error')),
              );
            }
          },
        ),
        backgroundColor: AppTheme.deepEmerald,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cardWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEFEBE2), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.deepEmerald.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category tag and Action Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category Tag
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4EE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.mutedGold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          quote.category.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: const Color(0xFF536256),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons: Copy and Remove Favorite
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Copy Icon
                  InkWell(
                    onTap: () => _copyQuote(context),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.copy_rounded,
                        size: 16,
                        color: Color(0xFF768077),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Heart Icon (Remove Favorite)
                  InkWell(
                    onTap: () => _removeFavorite(context),
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF4EA),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.mutedGoldBorder.withValues(
                            alpha: 0.5,
                          ),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        size: 16,
                        color: AppTheme.mutedGold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Quote Text
          Text(
            '“${quote.text}”',
            style: GoogleFonts.newsreader(
              fontSize: 18.5,
              fontWeight: FontWeight.w500,
              color: AppTheme.darkCharcoal,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          // Bottom Row: Author and Archive Number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '— ${quote.author.toUpperCase()}',
                  softWrap: true,
                  style: GoogleFonts.poppins(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: AppTheme.darkCharcoal,
                  ),
                ),
              ),
              Text(
                'Archived #$archiveIndex',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF869087),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
