import 'package:flutter/material.dart';
import '../config/app_colors.dart';

/// Bottom navigation bar kustom dengan 5 menu item.
/// Item tengah (index 2) adalah tombol FAB-style untuk membuat laporan baru.
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  final int unreadCount;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onIndexChanged,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.borderDefault, width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.article_outlined,
                activeIcon: Icons.article,
                label: 'Reports',
              ),
              _buildCenterButton(),
              _buildNavItem(
                index: 3,
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications,
                label: 'Inbox',
                badgeCount: unreadCount,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.person_outlined,
                activeIcon: Icons.person,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int badgeCount = 0,
  }) {
    final isActive = currentIndex == index;

    return GestureDetector(
      onTap: () => onIndexChanged(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? activeIcon : icon,
                  size: 24,
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                ),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 9 ? '9+' : badgeCount.toString(),
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => onIndexChanged(2),
      child: Transform.translate(
        offset: const Offset(0, -8),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.add,
            color: AppColors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
