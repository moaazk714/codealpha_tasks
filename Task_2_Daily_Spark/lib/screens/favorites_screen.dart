import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/quote_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/favorite_quote_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuoteProvider>(context);
    final favorites = provider.favorites;
    final filteredFavorites = provider.filteredFavorites;
    final availableCategories = provider.availableCategories;
    final selectedCategory = provider.selectedCategory;

    return Scaffold(
      backgroundColor: AppTheme.warmCream,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // App Header
            const AppHeader(),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                physics: const BouncingScrollPhysics(),
                children: [
                  // Subtitle & Item Count Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              size: 14,
                              color: AppTheme.mutedGold,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'PERSONAL ANTHOLOGY',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.1,
                                  color: const Color(0xFF8C713B),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.softGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${favorites.length} items',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.deepEmerald,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Title: Your Favorite Quotes
                  Text(
                    'Your Favorite Quotes',
                    style: GoogleFonts.newsreader(
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.deepEmerald,
                      letterSpacing: -0.3,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    '${favorites.length} inspiring quotes saved locally for mindful pause.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFF6B756D),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Hero Featured Banner: POETRY & INK ARCHIVE
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF5B7164),
                          Color(0xFF8B9E90),
                          Color(0xFFAEBDB2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.deepEmerald.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Subtle wave pattern overlay
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: CustomPaint(painter: _BannerWavePainter()),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 22,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'POETRY & INK ARCHIVE',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: const Color(0xFFFFE8B8),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '"Words belong to each person who can use them to feel less alone."',
                                style: GoogleFonts.newsreader(
                                  fontSize: 18,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Category Filter Pills
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: availableCategories.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final cat = availableCategories[index];
                        final isSelected =
                            selectedCategory.toLowerCase() == cat.toLowerCase();
                        final count = cat == 'All'
                            ? favorites.length
                            : favorites
                                  .where(
                                    (q) =>
                                        q.category.toLowerCase() ==
                                        cat.toLowerCase(),
                                  )
                                  .length;

                        final label = cat == 'All' ? 'All ($count)' : cat;

                        return ChoiceChip(
                          label: Text(label),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? AppTheme.deepEmerald
                                : const Color(0xFF556057),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              provider.setSelectedCategory(cat);
                            }
                          },
                          backgroundColor: AppTheme.cardWhite,
                          selectedColor: AppTheme.softGreen,
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.deepEmerald.withValues(alpha: 0.2)
                                : const Color(0xFFE5E0D5),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(19),
                          ),
                          showCheckmark: false,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 0,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Favorites List or Empty State
                  if (favorites.isEmpty) ...[
                    // Empty state
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFEFEBE2)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppTheme.softGreenLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.favorite_border_rounded,
                              size: 30,
                              color: AppTheme.mutedGold,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'No Favorites Yet',
                            style: GoogleFonts.newsreader(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.deepEmerald,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the heart icon on any quote on the Home screen to curate your personal anthology.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF737D75),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 22),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              shadowColor: Colors.black,
                              elevation: 5,
                              backgroundColor: AppTheme.deepEmerald,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () => provider.setTabIndex(0),
                            icon: const Icon(
                              Icons.auto_stories_rounded,
                              size: 18,
                            ),
                            label: Text(
                              'Explore Daily Quotes',
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (filteredFavorites.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.cardWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFEFEBE2)),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.filter_list_off_rounded,
                            size: 36,
                            color: AppTheme.mutedGold,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No quotes under "$selectedCategory"',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.darkCharcoal,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextButton(
                            onPressed: () =>
                                provider.setSelectedCategory('All'),
                            child: Text(
                              'Show all favorites',
                              style: GoogleFonts.poppins(
                                color: AppTheme.deepEmerald,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // List of Cards
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredFavorites.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final quote = filteredFavorites[index];
                        return FavoriteQuoteCard(
                          quote: quote,
                          archiveIndex: index + 1,
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Keeper's Note Card (matching Image 1)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.softGreenLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.softGreen.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bulb / Pin Icon in circle
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.cardWhite,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.deepEmerald.withValues(
                                  alpha: 0.05,
                                ),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.lightbulb_outline_rounded,
                              color: AppTheme.deepEmerald,
                              size: 19,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Keeper's Note",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.darkCharcoal,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Tap the heart on any daily quote to keep it in your personal collection, or tap copy icon to instantly send words of insight to a friend.',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF5A665C),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.4,
      size.width * 0.65,
      size.height * 0.75,
    );
    path.quadraticBezierTo(
      size.width * 0.85,
      size.height * 0.95,
      size.width,
      size.height * 0.6,
    );

    canvas.drawPath(path, paint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);
    path2.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.6,
      size.width * 0.75,
      size.height * 0.9,
    );
    path2.quadraticBezierTo(
      size.width * 0.9,
      size.height * 1.0,
      size.width,
      size.height * 0.8,
    );
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
