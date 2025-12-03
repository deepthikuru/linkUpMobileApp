import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../widgets/app_header.dart';
import '../providers/user_registration_view_model.dart';
import '../services/firebase_order_manager.dart';
import '../services/notification_service.dart';
import '../utils/theme.dart';
import 'content_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Configure GoogleSignIn with required scopes to ensure idToken is available
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  bool _isLoading = false;

  Future<void> _handleForgotPassword() async {
    final errorBg = AppTheme.getComponentBackgroundColor(
      context,
      'login_errorSnackbar_background',
      fallback: Colors.red,
    );
    final successBg = AppTheme.getComponentBackgroundColor(
      context,
      'login_successSnackbar_background',
      fallback: Colors.green,
    );

    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your email address'),
          backgroundColor: errorBg,
        ),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password reset email sent. Please check your inbox.'),
            backgroundColor: successBg,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: errorBg,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterLogin(String userId) async {
    try {
      // Get the view model and set user data
      final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        viewModel.userId = user.uid;
        viewModel.email = user.email ?? '';
        
        // Load user data
        await viewModel.loadUserData();
        
        // Check if FCM token exists in Firestore
        final notificationService = NotificationService();
        final hasToken = await notificationService.hasTokenInFirestore();
        
        // If no token, request native OS permission prompt (will show system dialog)
        if (!hasToken) {
          final permissionGranted = await notificationService.requestNotificationPermissions();
          if (permissionGranted) {
            // If permission granted, save the token
            await notificationService.saveFCMToken();
          }
        }
        
        // Check if new or existing user based on orders
        final orders = await FirebaseOrderManager().fetchUserOrders(userId);
        final isNewAccount = orders.isEmpty;
        
        // Check for incomplete orders
        final incompleteOrder = await FirebaseOrderManager().fetchLatestIncompleteOrder(userId);
        int? initialOrderStep;
        if (incompleteOrder != null) {
          initialOrderStep = int.tryParse(incompleteOrder['currentStep'] ?? '1');
        }
        
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => ContentView(
                isNewAccount: isNewAccount,
                initialOrderStep: initialOrderStep ?? 0,
              ),
            ),
          );
        }
      }
    } catch (e) {
      // If there's an error, fallback to ContentView with isNewAccount = true
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ContentView(
              isNewAccount: true,
              initialOrderStep: 0,
            ),
          ),
        );
      }
    }
  }


  Future<void> _signInWithEmail() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final errorBg = AppTheme.getComponentBackgroundColor(
        context,
        'login_errorSnackbar_background',
        fallback: Colors.red,
      );
      final successBg = AppTheme.getComponentBackgroundColor(
        context,
        'login_successSnackbar_background',
        fallback: Colors.green,
      );

      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter email and password'),
            backgroundColor: errorBg,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        final successBg = AppTheme.getComponentBackgroundColor(
          context,
          'snackbar-success',
          fallback: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Successfully signed in!'),
            backgroundColor: successBg,
          ),
        );

        // Load user data and determine if new or existing user
        await _navigateAfterLogin(userCredential.user!.uid);
      }
    } catch (e) {
      if (mounted) {
        final errorBg = AppTheme.getComponentBackgroundColor(
          context,
          'snackbar-error',
          fallback: Colors.red,
        );
        String errorMessage = 'Error signing in';
        
        if (e.toString().contains('user-not-found')) {
          errorMessage = 'No account found with this email';
        } else if (e.toString().contains('wrong-password')) {
          errorMessage = 'Incorrect password';
        } else if (e.toString().contains('invalid-email')) {
          errorMessage = 'Invalid email address';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: errorBg,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Check if idToken is null - this prevents errors when creating Firebase credential
      if (googleAuth.idToken == null) {
        throw Exception('Failed to get ID token from Google Sign-In. Please try again.');
      }

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Successfully signed in
      if (mounted) {
        final successBg = AppTheme.getComponentBackgroundColor(
          context,
          'snackbar-success',
          fallback: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Successfully signed in with Google!'),
            backgroundColor: successBg,
          ),
        );
        
        // Load user data and determine if new or existing user
        await _navigateAfterLogin(userCredential.user!.uid);
      }
    } catch (e) {
      if (mounted) {
        final errorBg = AppTheme.getComponentBackgroundColor(
          context,
          'snackbar-error',
          fallback: Colors.red,
        );
        String errorMessage = 'Error signing in with Google';
        
        // Check for specific error codes
        if (e.toString().contains('ApiException: 10') || 
            e.toString().contains('DEVELOPER_ERROR') ||
            e.toString().contains('sign_in_failed')) {
          errorMessage = 'Google Sign-In configuration error. Please ensure:\n'
              '1. SHA-1 fingerprint is added to Firebase Console\n'
              '2. Google Sign-In is enabled in Firebase Authentication';
        } else {
          errorMessage = 'Error: ${e.toString()}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: errorBg,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get component colors from Contentful
    final screenBg = AppTheme.getComponentBackgroundColor(
      context,
      'login_scaffold_background',
      fallback: Colors.white,
    );
    final titleColor = AppTheme.getComponentTextColor(
      context,
      'login_title_text',
      fallback: Colors.black,
    );
    final hintColor = AppTheme.getComponentTextColor(
      context,
      'login_inputHint_text',
      fallback: Colors.grey,
    );
    final inputBg = AppTheme.getComponentBackgroundColor(
      context,
      'login_input_background',
      fallback: Colors.white,
    );
    final linkColor = AppTheme.getComponentTextColor(
      context,
      'link-primary',
      fallback: AppTheme.mainBlue,
    );
    final primaryButtonBg = AppTheme.getComponentBackgroundColor(
      context,
      'login_signInButton_disabledBackground',
      fallback: Colors.grey,
    );
    final primaryButtonText = AppTheme.getComponentTextColor(
      context,
      'login_signInButton_text',
      fallback: Colors.white,
    );
    final googleButtonBg = AppTheme.getComponentBackgroundColor(
      context,
      'login_googleButton_background',
      fallback: Colors.red,
    );
    final googleButtonText = AppTheme.getComponentTextColor(
      context,
      'login_googleButton_text',
      fallback: Colors.white,
    );
    final googleButtonIcon = AppTheme.getComponentIconColor(
      context,
      'login_googleButton_icon',
      fallback: Colors.white,
    );
    final appleButtonBg = AppTheme.getComponentBackgroundColor(
      context,
      'login_appleButton_background',
      fallback: Colors.black,
    );
    final appleButtonText = AppTheme.getComponentTextColor(
      context,
      'login_appleButton_text',
      fallback: Colors.white,
    );
    final appleButtonIcon = AppTheme.getComponentIconColor(
      context,
      'login_appleButton_icon',
      fallback: Colors.white,
    );
    final buttonText = AppTheme.getComponentTextColor(
      context,
      'button-text',
      fallback: Colors.white,
    );
    final bodyText = AppTheme.getComponentTextColor(
      context,
      'login_footerText_text',
      fallback: Colors.black,
    );
    final dividerColor = AppTheme.getComponentTextColor(
      context,
      'login_separator_text',
      fallback: Colors.grey[600]!,
    );
    final loadingIndicatorColor = AppTheme.getComponentIconColor(
      context,
      'login_loadingIndicator_color',
      fallback: Colors.white,
    );

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header Component fixed at top
            const AppHeader(),
            // Scrollable content below header
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      // Sign In Title - Centered
                      Center(
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Email Field
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email address',
                          hintStyle: TextStyle(color: hintColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: inputBg,
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      // Password Field
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(color: hintColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: inputBg,
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 8),
                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(color: linkColor),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Sign In Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signInWithEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryButtonBg,
                            foregroundColor: primaryButtonText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(loadingIndicatorColor),
                                  ),
                                )
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // OR Separator
                      Row(
                        children: [
                          Expanded(child: Divider(color: dividerColor)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: dividerColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: dividerColor)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Sign in with Google Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _signInWithGoogle,
                          icon: _isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(googleButtonText),
                                  ),
                                )
                              : Icon(Icons.language, color: googleButtonIcon),
                          label: Text(
                            _isLoading ? 'Signing in...' : 'Sign in with Google',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: googleButtonText,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: googleButtonBg,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Sign in with Apple Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle Apple sign in
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appleButtonBg,
                            foregroundColor: buttonText,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.apple, color: appleButtonIcon),
                              const SizedBox(width: 8),
                              Text(
                                'Sign in with Apple',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: appleButtonText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // New User Link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'New to Telgoo5 Mobile?',
                              style: TextStyle(color: bodyText),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to create account - can be implemented later
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Create account feature coming soon'),
                                  ),
                                );
                              },
                              child: Text(
                                'Create an account',
                                style: TextStyle(color: linkColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
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

