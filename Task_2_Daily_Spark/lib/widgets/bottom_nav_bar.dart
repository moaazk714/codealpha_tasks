import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/quote_provider.dart';
import '../theme/app_theme.dart';

class QuoteFlowBottomNavBar extends StatelessWidget {
  const QuoteFlowBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<QuoteProvider>(context);
    final selectedIndex = provider.tabIndex;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppTheme.cardWhite,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(color: const Color(0xFFEBE6DC), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.deepEmerald.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              // Home Tab
              Expanded(
                child: _NavBarItem(
                  icon: Icons.home_outlined,
                  label: 'Home',
                  isSelected: selectedIndex == 0,
                  onTap: () => provider.setTabIndex(0),
                ),
              ),

              // Favorites Tab
              Expanded(
                child: _NavBarItem(
                  icon: Icons.favorite_border_rounded,
                  label: 'Favorites',
                  isSelected: selectedIndex == 1,
                  onTap: () => provider.setTabIndex(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.softGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? AppTheme.deepEmerald
                      : const Color(0xFF6E7870),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppTheme.deepEmerald
                        : const Color(0xFF6E7870),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
