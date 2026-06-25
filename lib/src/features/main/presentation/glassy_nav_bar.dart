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
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      height: 64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark 
                ? CupertinoColors.systemGrey6.withValues(alpha: 0.7) 
                : CupertinoColors.white.withValues(alpha: 0.7)),
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
              items: items,
            ),
          ),
        ),
      ),
    );
  }
}
