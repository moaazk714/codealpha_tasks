import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Brand Name
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.softGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.deepEmerald.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.spa_rounded,
                      color: AppTheme.deepEmerald,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'Daily Spark',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.newsreader(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.deepEmerald,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // User Profile Avatar Button
        ],
      ),
    );
  }
}
