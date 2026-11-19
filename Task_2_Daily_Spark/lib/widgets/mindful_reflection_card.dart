import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/quote.dart';
import '../theme/app_theme.dart';

class MindfulReflectionCard extends StatelessWidget {
  final Quote quote;

  const MindfulReflectionCard({super.key, required this.quote});

  void _openMindfulBreathingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MindfulBreathingSheet(quote: quote),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.softGreenLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.softGreen.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Mindful Icon in Circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.cardWhite,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.deepEmerald.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.psychology_outlined,
                color: AppTheme.deepEmerald,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mindful Reflection',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkCharcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Take 30 seconds to breathe with this thought.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF637066),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Audio / Breathe Action Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _openMindfulBreathingSheet(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFE7E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_up_outlined,
                  color: AppTheme.deepEmerald,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MindfulBreathingSheet extends StatefulWidget {
  final Quote quote;

  const _MindfulBreathingSheet({required this.quote});

  @override
  State<_MindfulBreathingSheet> createState() => _MindfulBreathingSheetState();
}

class _MindfulBreathingSheetState extends State<_MindfulBreathingSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _scaleAnimation;
  Timer? _countdownTimer;
  int _secondsLeft = 30;
  String _breatheStatus = 'Breathe in slowly...';

  @override
  void initState() {
    super.initState();
    _breathingController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                _breatheStatus = 'Breathe out gently...';
              });
              _breathingController.reverse();
            } else if (status == AnimationStatus.dismissed) {
              setState(() {
                _breatheStatus = 'Breathe in slowly...';
              });
              _breathingController.forward();
            }
          });

    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.18).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    _breathingController.forward();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _secondsLeft = 0;
            _breatheStatus = 'Peaceful & Centered.';
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.warmCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Mindful Reflection',
            style: GoogleFonts.newsreader(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.deepEmerald,
            ),
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '“${widget.quote.text}”',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.newsreader(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: AppTheme.darkCharcoal,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Animated Breathing Orb
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.deepEmerald,
                        AppTheme.deepEmerald.withValues(alpha: 0.7),
                        AppTheme.softGreen,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.deepEmerald.withValues(alpha: 0.25),
                        blurRadius: 28,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$_secondsLeft s',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          Text(
            _breatheStatus,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.deepEmerald,
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.deepEmerald,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Complete Pause',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
