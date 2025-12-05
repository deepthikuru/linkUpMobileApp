import 'dart:ui';
import 'package:flutter/material.dart';
import '../providers/navigation_state.dart';
import 'package:provider/provider.dart';
import '../utils/theme.dart';

class AppFooter extends StatelessWidget {
  final FooterTab currentTab;
  final Function(FooterTab)? onTabChanged;

  const AppFooter({
    super.key,
    this.currentTab = FooterTab.home,
    this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final mainBlue = AppTheme.mainBlueDynamic(context);
    
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(22),
        topRight: Radius.circular(22),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            color: mainBlue.withOpacity(0.9),
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                offset: const Offset(0, -4),
                color: Colors.black.withOpacity(0.15),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                // Plans first
                _buildTabItem(
                  context,
                  icon: Icons.assignment,
                  iconOutlined: Icons.list_alt,
                  label: 'Plans',
                  tab: FooterTab.plans,
                  isSelected: currentTab == FooterTab.plans,
                ),
                // Home in the middle
                _buildTabItem(
                  context,
                  icon: Icons.home_rounded,
                  iconOutlined: Icons.home_outlined,
                  label: 'Home',
                  tab: FooterTab.home,
                  isSelected: currentTab == FooterTab.home,
                ),
                // Chat
                _buildTabItem(
                  context,
                  icon: Icons.chat_bubble,
                  iconOutlined: Icons.chat_bubble_outline,
                  label: 'Chat',
                  tab: FooterTab.chat,
                  isSelected: currentTab == FooterTab.chat,
                ),
                // Profile last
                _buildTabItem(
                  context,
                  icon: Icons.person,
                  iconOutlined: Icons.person_outline,
                  label: 'Profile',
                  tab: FooterTab.profile,
                  isSelected: currentTab == FooterTab.profile,
                ),
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context, {
    required IconData icon,
    required IconData iconOutlined,
    required String label,
    required FooterTab tab,
    required bool isSelected,
  }) {
    final accentGold = AppTheme.accentGold;
    
    return InkWell(
      onTap: () {
        if (onTabChanged != null) {
          onTabChanged!(tab);
        } else {
          _handleTabNavigation(context, tab);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? icon : iconOutlined,
            size: 26,
            color: isSelected
                ? accentGold // Yellow accent
                : Colors.white,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected
                  ? accentGold
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _handleTabNavigation(BuildContext context, FooterTab tab) {
    final navigationState = Provider.of<NavigationState>(context, listen: false);
    
    // Only update the footer tab - the MainLayout will handle the body switch
    navigationState.setFooterTab(tab);
    
    // If navigating to home, also update the destination
    if (tab == FooterTab.home) {
      navigationState.navigateTo(Destination.startNewOrder);
    }
  }
}
