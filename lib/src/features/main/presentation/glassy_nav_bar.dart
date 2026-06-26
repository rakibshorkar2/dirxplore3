import 'dart:ui';
import 'package:flutter/cupertino.dart';

class GlassyNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const GlassyNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    
    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(28, 0, 24, 38), // Optimized for iPhone 15 Pro curve
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(31),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: isDark ? 0.4 : 0.1),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              decoration: BoxDecoration(
                color: (isDark 
                  ? CupertinoColors.black.withValues(alpha: 0.6) 
                  : CupertinoColors.white.withValues(alpha: 0.7)),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: (isDark 
                    ? CupertinoColors.white.withValues(alpha: 0.15) 
                    : CupertinoColors.black.withValues(alpha: 0.1)),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.only(top: 8, bottom: 4),
                child: CupertinoTabBar(
                  currentIndex: currentIndex,
                  onTap: onTap,
                  backgroundColor: CupertinoColors.transparent,
                  activeColor: CupertinoColors.activeBlue,
                  inactiveColor: isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey2,
                  border: null,
                  iconSize: 30,
                  items: items,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
