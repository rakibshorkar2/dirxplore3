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
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 34),
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: (isDark 
                  ? CupertinoColors.systemGrey6.withValues(alpha: 0.8) 
                  : CupertinoColors.white.withValues(alpha: 0.8)),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: (isDark 
                    ? CupertinoColors.white.withValues(alpha: 0.1) 
                    : CupertinoColors.black.withValues(alpha: 0.05)),
                ),
              ),
              child: CupertinoTabBar(
                currentIndex: currentIndex,
                onTap: onTap,
                backgroundColor: CupertinoColors.transparent,
                activeColor: CupertinoColors.activeBlue,
                inactiveColor: CupertinoColors.systemGrey,
                border: null,
                iconSize: 28,
                items: items,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
