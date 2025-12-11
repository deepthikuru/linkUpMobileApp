import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../../providers/navigation_state.dart';
import '../../providers/user_registration_view_model.dart';
import '../../utils/theme.dart';
import '../../utils/fallback_values.dart';
import '../../utils/text_helper.dart';
import '../../utils/constants.dart';
import '../home/address_info_sheet.dart';

// Body-only version for MainLayout
class SupportViewBody extends StatefulWidget {
  const SupportViewBody({super.key});

  @override
  State<SupportViewBody> createState() => _SupportViewBodyState();
}

class _SupportViewBodyState extends State<SupportViewBody> {
  int _selectedTab = 0; // 0: Contact, 1: Chat

  @override
  void initState() {
    super.initState();
    // Set footer tab to chat when this view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigationState = Provider.of<NavigationState>(context, listen: false);
      navigationState.setFooterTab(FooterTab.chat);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab selector
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.getComponentBackgroundColor(
              context,
              'screen-support',
              fallback: Color(int.parse(FallbackValues.disabledBackground.replaceFirst('#', '0xFF'))),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildTabButton(AppText.getString(context, 'tabContact'), 0),
              ),
              Expanded(
                child: _buildTabButton(AppText.getString(context, 'tabChat'), 1),
              ),
            ],
          ),
        ),
        // Content
        Expanded(
          child: _selectedTab == 0
              ? _buildContactTab(context)
              : _buildChatTab(),
        ),
      ],
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.accentGold
              : AppTheme.getComponentBackgroundColor(
                  context,
                  'screen-support',
                  fallback: Colors.transparent,
                ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(int.parse(FallbackValues.appText.replaceFirst('#', '0xFF'))),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildContactTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              AppText.getString(context, 'supportContactTitle'),
              textAlign: TextAlign.center,
              style: AppTheme.getDoubleBoldTextStyle(
                color: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))),
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              AppText.getString(context, 'supportContactSubtitle'),
              textAlign: TextAlign.center,
              style: AppTheme.getDoubleBoldTextStyle(
                fontSize: 16,
                color: AppTheme.accentGold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Phone
          _buildContactCard(
            context: context,
            icon: Icons.phone,
            title: AppText.getString(context, 'supportPhone'),
            subtitle: AppText.getString(context, 'supportPhoneNumber'),
            onTap: () => _launchPhone('9045960304'),
          ),
          const SizedBox(height: 16),
          // Email
          _buildContactCard(
            context: context,
            icon: Icons.email,
            title: AppText.getString(context, 'supportEmail'),
            subtitle: AppText.getString(context, 'supportEmailAddress'),
            onTap: () => _launchEmail('support@linkupmobile.com'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.mainBlueDynamic(context),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getComponentTextColor(
                          context,
                          'text-title',
                          fallback: Color(int.parse(FallbackValues.appText.replaceFirst('#', '0xFF'))),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.getComponentTextColor(
                          context,
                          'text-secondary',
                          fallback: Color(int.parse(FallbackValues.textSecondary.replaceFirst('#', '0xFF'))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.getComponentIconColor(
                  context,
                  'text-secondary',
                  fallback: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri('https://embed.reply.cx/7ZqxdodvfQJL201427298704riBAR5tP/bot/7a3njUx7evqU1909260166597qus75Wk?display=fullscreen'),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
          useHybridComposition: true,
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone app')),
        );
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email?subject=Support Request');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email app')),
        );
      }
    }
  }
}

class SupportView extends StatefulWidget {
  const SupportView({super.key});

  @override
  State<SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<SupportView> {
  int _selectedTab = 0; // 0: Contact, 1: Chat
  String _currentZipCode = '';

  @override
  void initState() {
    super.initState();
    _loadZipCode();
    // Set footer tab to chat when this view loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigationState = Provider.of<NavigationState>(context, listen: false);
      navigationState.setFooterTab(FooterTab.chat);
    });
  }

  Future<void> _loadZipCode() async {
    final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
    await viewModel.loadUserData();
    
    setState(() {
      _currentZipCode = viewModel.zip.isNotEmpty ? viewModel.zip : AppConstants.defaultZipCode;
    });
  }


  @override
  Widget build(BuildContext context) {
    final screenBg = AppTheme.getComponentBackgroundColor(
      context,
      'screen-support',
      fallback: Color(int.parse(FallbackValues.appBackground.replaceFirst('#', '0xFF'))),
    );
    final tabContainerBg = AppTheme.getComponentBackgroundColor(
      context,
      'screen-support',
      fallback: Color(int.parse(FallbackValues.disabledBackground.replaceFirst('#', '0xFF'))),
    );

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          // Tab selector
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tabContainerBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton('Contact', 0),
                  ),
                  Expanded(
                    child: _buildTabButton('Chat', 1),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _selectedTab == 0
                  ? _buildContactTab(context)
                  : _buildChatTab(),
            ),
          ],
        ),
      );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _selectedTab == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppTheme.accentGold
              : AppTheme.getComponentBackgroundColor(
                  context,
                  'screen-support',
                  fallback: Colors.transparent,
                ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(int.parse(FallbackValues.appText.replaceFirst('#', '0xFF'))),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildContactTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              FallbackValues.supportContactTitle,
              textAlign: TextAlign.center,
              style: AppTheme.getDoubleBoldTextStyle(
                color: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))),
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              FallbackValues.supportContactSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentGold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Phone
          _buildContactCard(
            context: context,
            icon: Icons.phone,
            title: FallbackValues.supportPhone,
            subtitle: FallbackValues.supportPhoneNumber,
            onTap: () => _launchPhone('9045960304'),
          ),
          const SizedBox(height: 16),
          // Email
          _buildContactCard(
            context: context,
            icon: Icons.email,
            title: FallbackValues.supportEmail,
            subtitle: FallbackValues.supportEmailAddress,
            onTap: () => _launchEmail('support@linkupmobile.com'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.mainBlueDynamic(context),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.getComponentTextColor(
                          context,
                          'text-title',
                          fallback: Color(int.parse(FallbackValues.appText.replaceFirst('#', '0xFF'))),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.getComponentTextColor(
                          context,
                          'text-secondary',
                          fallback: Color(int.parse(FallbackValues.textSecondary.replaceFirst('#', '0xFF'))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.getComponentIconColor(
                  context,
                  'text-secondary',
                  fallback: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri('https://embed.reply.cx/7ZqxdodvfQJL201427298704riBAR5tP/bot/7a3njUx7evqU1909260166597qus75Wk?display=fullscreen'),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          domStorageEnabled: true,
          useHybridComposition: true,
        ),
      ),
    );
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone app')),
        );
      }
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email?subject=Support Request');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email app')),
        );
      }
    }
  }
}

