import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/report_card.dart';
import '../auth/login_screen.dart';
import '../notification/notification_screen.dart';
import '../profile/profile_screen.dart';
import '../report/create_report_screen.dart';
import '../report/my_reports_screen.dart';
import '../report/report_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load reports on first launch
    Future.microtask(() {
      if (mounted) {
        context.read<ReportProvider>().loadReports(refresh: true);
        final token = context.read<AuthProvider>().token;
        if (token != null) {
          context.read<NotificationProvider>().loadNotifications(token);
        }
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<ReportProvider>().setSearch(query);
      }
    });
  }

  void _onNavIndexChanged(int index) {
    if (index == 2) {
      // Center button → Create Report (check login first)
      final authProvider = context.read<AuthProvider>();
      if (!authProvider.isLoggedIn) {
        _showLoginRequiredDialog();
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateReportScreen()),
      );
      return;
    }

    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Login Required'),
        content: const Text('You must sign in first to create a report.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral,
      body: SafeArea(
        child: IndexedStack(
          index: _currentNavIndex > 2 ? _currentNavIndex - 1 : _currentNavIndex,
          children: [
            // Index 0 — Home feed
            _HomeFeedBody(
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
            ),
            // Index 1 — My Reports
            const MyReportsScreen(),
            // Index 3 → mapped to 2 — Notifications
            const NotificationScreen(),
            // Index 4 → mapped to 3 — Profile
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          return CustomBottomNavBar(
            currentIndex: _currentNavIndex,
            onIndexChanged: _onNavIndexChanged,
            unreadCount: notificationProvider.unreadCount,
          );
        },
      ),
    );
  }
}

/// Extracted home feed body (the original home content).
class _HomeFeedBody extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const _HomeFeedBody({
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(context),
        _buildSectionHeader(context),
        Expanded(child: _buildReportList(context)),
      ],
    );
  }

  /// Header: "FoundIt!" branding + search icon
  Widget _buildHeader() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Campus Lost & Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: AppColors.secondary),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Search bar with debounce
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
      child: TextFormField(
        controller: searchController,
        onChanged: onSearchChanged,
        style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
          hintText: 'Search for items...',
          hintStyle: const TextStyle(color: AppColors.textMuted),
          filled: true,
          fillColor: AppColors.neutral,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  /// Section header "Recent Reports" + dropdown filter
  Widget _buildSectionHeader(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Reports',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              // Dropdown filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: provider.activeTab,
                    isDense: true,
                    icon: const Icon(Icons.tune, size: 16, color: AppColors.textMuted),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textDark,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('All')),
                      DropdownMenuItem(value: 'lost', child: Text('Lost')),
                      DropdownMenuItem(value: 'found', child: Text('Found')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        provider.setTab(value);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Report list with pull-to-refresh and infinite scroll
  Widget _buildReportList(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, provider, _) {
        // Initial loading state (no data yet)
        if (provider.isLoading && provider.reports.isEmpty) {
          return _buildLoadingShimmer();
        }

        // Error state (no data yet)
        if (provider.errorMessage != null && provider.reports.isEmpty) {
          return _buildErrorState(context, provider.errorMessage!);
        }

        // Empty state
        if (!provider.isLoading && provider.reports.isEmpty) {
          return _buildEmptyState();
        }

        // Report list
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            // Infinite scroll: load more when scrolled 80% down
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent * 0.8) {
              provider.loadMore();
            }
            return false;
          },
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => provider.loadReports(refresh: true),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: provider.reports.length + (provider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Loading indicator at end of list
                if (index == provider.reports.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }

                final report = provider.reports[index];
                return ReportCard(
                  report: report,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportDetailScreen(
                          reportId: report.id,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Shimmer loading placeholder
  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.neutral,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.neutral,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 150,
                      decoration: BoxDecoration(
                        color: AppColors.neutral,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppColors.neutral,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No reports found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try changing your filter or search query',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// Error state with retry button
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: AppColors.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ReportProvider>().loadReports(refresh: true);
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
