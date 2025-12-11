import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/app_header.dart';
import '../widgets/mesh_scaffold.dart';
import '../utils/theme.dart';
import '../utils/fallback_values.dart';
import 'login_page.dart';
import 'home/plans_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    // Get component colors
    final screenBg = AppTheme.getComponentBackgroundColor(
      context,
      'home_scaffold_background',
      fallback: Color(int.parse(FallbackValues.appBackground.replaceFirst('#', '0xFF'))),
    );
    final titleColor = AppTheme.getComponentTextColor(
      context,
      'home_title_text',
      fallback: Color(int.parse(FallbackValues.appText.replaceFirst('#', '0xFF'))),
    );
    final bodyColor = AppTheme.getComponentTextColor(
      context,
      'home_description_text',
      fallback: Color(int.parse(FallbackValues.textSecondary.replaceFirst('#', '0xFF'))),
    );
    final buttonBg = AppTheme.getComponentBackgroundColor(
      context,
      'home_signOutButton_background',
      fallback: Color(int.parse(FallbackValues.redAccent.replaceFirst('#', '0xFF'))),
    );
    final buttonText = AppTheme.getComponentTextColor(
      context,
      'home_signOutButton_text',
      fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))),
    );
    final seePlansButtonBg = AppTheme.getComponentBackgroundColor(
      context,
      'home_seePlansButton_background',
      fallback: Color(int.parse(FallbackValues.mainBlue.replaceFirst('#', '0xFF'))),
    );
    final seePlansButtonText = AppTheme.getComponentTextColor(
      context,
      'home_seePlansButton_text',
      fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))),
    );

    return MeshScaffold(
      animated: true,
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        FallbackValues.messageWelcome,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (user != null) ...[
                        Text(
                          FallbackValues.replacePlaceholder(
                            FallbackValues.homeSignedInAs,
                            {'email': user.email ?? user.displayName ?? 'User'},
                          ),
                          style: TextStyle(
                            fontSize: 16,
                            color: bodyColor,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const PlansView(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: seePlansButtonBg,
                            foregroundColor: seePlansButtonText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            FallbackValues.buttonSeePlans,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            await FirebaseAuth.instance.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonBg,
                            foregroundColor: buttonText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            FallbackValues.buttonSignOut,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

