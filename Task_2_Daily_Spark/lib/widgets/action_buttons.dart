import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/quote.dart';
import '../providers/quote_provider.dart';
import '../theme/app_theme.dart';

class ActionButtonsRow extends StatelessWidget {
  final Quote? quote;

  const ActionButtonsRow({super.key, required this.quote});

  void _copyQuote(BuildContext context) {
    if (quote == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No quote available to copy.',
            style: GoogleFonts.poppins(color: Colors.white),
          ),
          backgroundColor: AppTheme.darkCharcoal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final formattedText = '“${quote!.text}”\n— ${quote!.author}';
    Clipboard.setData(ClipboardData(text: formattedText));

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
                fontSize: 13.5,
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

  void _toggleFavorite(BuildContext context) async {
    if (quote == null) return;

    final provider = Provider.of<QuoteProvider>(context, listen: false);
    late final bool wasAdded;
    try {
      wasAdded = await provider.toggleFavorite(quote!);
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
        content: Row(
          children: [
            Icon(
              wasAdded ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: wasAdded ? const Color(0xFFE26D5C) : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              wasAdded ? 'Added to your favorites!' : 'Removed from favorites.',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.white,
                fontSize: 13.5,
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuoteProvider>(context);
    final isFav = quote != null && provider.isFavorite(quote!);

    return Row(
      children: [
        // 1. "New Quote" Primary Button
        Expanded(
          flex: 5,
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepEmerald,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18),
              ),
              onPressed: () {
                provider.nextRandomQuote();
              },
              icon: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 15,
                  color: Colors.white,
                ),
              ),
              label: Text(
                'New Quote',
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // 2. "Copy" Secondary Button
        Expanded(
          flex: 4,
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.softGreen,
                foregroundColor: AppTheme.deepEmerald,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onPressed: () => _copyQuote(context),
              icon: const Icon(
                Icons.copy_rounded,
                size: 17,
                color: AppTheme.deepEmerald,
              ),
              label: Text(
                'Copy',
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.deepEmerald,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        // 3. Favorite Heart Button
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: isFav ? AppTheme.mutedGoldLight : AppTheme.softGreenLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: isFav
                  ? AppTheme.mutedGoldBorder
                  : AppTheme.softGreen.withValues(alpha: 0.6),
              width: 1.2,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _toggleFavorite(context),
              borderRadius: BorderRadius.circular(27),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    key: ValueKey(isFav),
                    color: isFav
                        ? const Color(0xFFC99B55)
                        : AppTheme.darkCharcoal,
                    size: 22,
                  ),
                ),
              ),
            ),
            
          ),
          
        ),
        
      ],
    );
  }
}
