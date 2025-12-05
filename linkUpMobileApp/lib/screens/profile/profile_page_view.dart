import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../providers/user_registration_view_model.dart';
import '../../providers/navigation_state.dart';
import '../../screens/login_page.dart';
import '../../utils/theme.dart';
import '../../widgets/app_header.dart';
import '../../widgets/mesh_background.dart';
import 'privacy_policy_view.dart';
import 'terms_and_conditions_view.dart';
import 'previous_orders_view.dart';
import 'profile_view.dart';
import 'international_long_distance_view.dart';

// Body-only version for MainLayout
class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key});

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {
  @override
  void initState() {
    super.initState();
    // Set footer tab to profile when this view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigationState = Provider.of<NavigationState>(context, listen: false);
      navigationState.setFooterTab(FooterTab.profile);
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    await FirebaseAuth.instance.signOut();
    viewModel.resetAllUserData();
    
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    Color? iconBackgroundColor,
    bool isLogout = false,
  }) {
    final effectiveIconColor = iconColor ?? AppTheme.secondBlue;
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveIconBg = iconBackgroundColor ?? 
      (isLogout 
        ? Colors.red.withOpacity(0.15) 
        : AppTheme.secondBlue.withOpacity(0.15));

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white.withOpacity(0.95), // Solid, almost opaque white
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon with colored background container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: effectiveIconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isLogout ? effectiveTextColor : Colors.black87,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isLogout 
                  ? effectiveTextColor.withOpacity(0.7)
                  : Colors.grey[600],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0, bottom: 24.0),
      children: [
        // Main menu items
        _buildMenuCard(
          context: context,
          icon: Icons.person,
          title: 'Profile',
          iconBackgroundColor: AppTheme.secondBlue.withOpacity(0.15),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ProfileView(),
              ),
            );
          },
        ),
        _buildMenuCard(
          context: context,
          icon: Icons.notifications,
          title: 'Notifications',
          iconBackgroundColor: AppTheme.accentGold.withOpacity(0.15),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ProfileView(),
              ),
            );
          },
        ),
        _buildMenuCard(
          context: context,
          icon: Icons.history,
          title: 'Previous Orders',
          iconBackgroundColor: AppTheme.mainBlue.withOpacity(0.15),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PreviousOrdersView(),
              ),
            );
          },
        ),
        _buildMenuCard(
          context: context,
          icon: Icons.language,
          title: 'International Long Distance',
          iconBackgroundColor: AppTheme.secondBlue.withOpacity(0.15),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const InternationalLongDistanceView(),
              ),
            );
          },
        ),
        
        const SizedBox(height: 8),
        
        // Legal/Policy items
        _buildMenuCard(
          context: context,
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          iconBackgroundColor: Colors.grey[200],
          iconColor: Colors.grey[700],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PrivacyPolicyView(),
              ),
            );
          },
        ),
        _buildMenuCard(
          context: context,
          icon: Icons.description,
          title: 'Terms and Conditions',
          iconBackgroundColor: Colors.grey[200],
          iconColor: Colors.grey[700],
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const TermsAndConditionsView(),
              ),
            );
          },
        ),
        
        const SizedBox(height: 8),
        
        // Logout button
        _buildMenuCard(
          context: context,
          icon: Icons.logout,
          title: 'Logout',
          isLogout: true,
          iconColor: AppTheme.getComponentIconColor(
            context,
            'hamburgerMenu_logoutIcon',
            fallback: Colors.red,
          ),
          textColor: AppTheme.getComponentTextColor(
            context,
            'hamburgerMenu_logoutText',
            fallback: Colors.red,
          ),
          iconBackgroundColor: Colors.red.withOpacity(0.15),
          onTap: () => _handleLogout(context),
        ),
      ],
    );
  }
}

// Standalone version (for backward compatibility if needed)
class ProfilePageView extends StatelessWidget {
  const ProfilePageView({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    await FirebaseAuth.instance.signOut();
    viewModel.resetAllUserData();
    
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
    Color? iconBackgroundColor,
    bool isLogout = false,
  }) {
    final effectiveIconColor = iconColor ?? AppTheme.secondBlue;
    final effectiveTextColor = textColor ?? Colors.white;
    final effectiveIconBg = iconBackgroundColor ?? 
      (isLogout 
        ? Colors.red.withOpacity(0.15) 
        : AppTheme.secondBlue.withOpacity(0.15));

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Colors.white.withOpacity(0.95), // Solid, almost opaque white
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon with colored background container
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: effectiveIconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isLogout ? effectiveTextColor : Colors.black87,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: isLogout 
                  ? effectiveTextColor.withOpacity(0.7)
                  : Colors.grey[600],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MeshBackground(
        animated: true,
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              AppHeader(
                showGradient: true,
                onBackTap: () {
                  Navigator.of(context).pop();
                },
                title: 'Profile',
              ),
              // Menu items
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    // Main menu items
                    _buildMenuCard(
                      context: context,
                      icon: Icons.person,
                      title: 'Profile',
                      iconBackgroundColor: AppTheme.secondBlue.withOpacity(0.15),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProfileView(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context: context,
                      icon: Icons.notifications,
                      title: 'Notifications',
                      iconBackgroundColor: AppTheme.accentGold.withOpacity(0.15),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProfileView(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context: context,
                      icon: Icons.history,
                      title: 'Previous Orders',
                      iconBackgroundColor: AppTheme.mainBlue.withOpacity(0.15),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PreviousOrdersView(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context: context,
                      icon: Icons.language,
                      title: 'International Long Distance',
                      iconBackgroundColor: AppTheme.secondBlue.withOpacity(0.15),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const InternationalLongDistanceView(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Legal/Policy items
                    _buildMenuCard(
                      context: context,
                      icon: Icons.privacy_tip,
                      title: 'Privacy Policy',
                      iconBackgroundColor: Colors.grey[200],
                      iconColor: Colors.grey[700],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PrivacyPolicyView(),
                          ),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context: context,
                      icon: Icons.description,
                      title: 'Terms and Conditions',
                      iconBackgroundColor: Colors.grey[200],
                      iconColor: Colors.grey[700],
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const TermsAndConditionsView(),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Logout button
                    _buildMenuCard(
                      context: context,
                      icon: Icons.logout,
                      title: 'Logout',
                      isLogout: true,
                      iconColor: AppTheme.getComponentIconColor(
                        context,
                        'hamburgerMenu_logoutIcon',
                        fallback: Colors.red,
                      ),
                      textColor: AppTheme.getComponentTextColor(
                        context,
                        'hamburgerMenu_logoutText',
                        fallback: Colors.red,
                      ),
                      iconBackgroundColor: Colors.red.withOpacity(0.15),
                      onTap: () => _handleLogout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

