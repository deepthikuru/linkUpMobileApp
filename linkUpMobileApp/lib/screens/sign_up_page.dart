import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:provider/provider.dart';
import '../widgets/mesh_background.dart';
import '../providers/user_registration_view_model.dart';
import '../services/firebase_order_manager.dart';
import '../services/notification_service.dart';
import '../utils/theme.dart';
import '../utils/fallback_values.dart';
import 'content_view.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Configure GoogleSignIn with required scopes to ensure idToken is available
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  bool _isLoading = false;
  bool _isLoadingEmail = false;
  bool _isLoadingGoogle = false;
  bool _isLoadingApple = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _navigateAfterSignUp(String userId) async {
    try {
      // Get the view model and set user data
      final viewModel = Provider.of<UserRegistrationViewModel>(context, listen: false);
      final user = FirebaseAuth.instance.currentUser;
      
      if (user != null) {
        viewModel.userId = user.uid;
        viewModel.email = user.email ?? '';
        
        // Initialize user registration data
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
        
        // New account always starts with isNewAccount = true
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

  Future<void> _signUpWithEmail() async {
    try {
      // Dismiss keyboard
      FocusScope.of(context).unfocus();
      
      setState(() {
        _isLoading = true;
        _isLoadingEmail = true;
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

      // Validate fields
      if (_emailController.text.isEmpty || 
          _passwordController.text.isEmpty || 
          _confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please fill in all fields'),
            backgroundColor: errorBg,
          ),
        );
        setState(() {
          _isLoading = false;
          _isLoadingEmail = false;
        });
        return;
      }

      // Validate password match
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Passwords do not match'),
            backgroundColor: errorBg,
          ),
        );
        setState(() {
          _isLoading = false;
          _isLoadingEmail = false;
        });
        return;
      }

      // Validate password length
      if (_passwordController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Password must be at least 6 characters'),
            backgroundColor: errorBg,
          ),
        );
        setState(() {
          _isLoading = false;
          _isLoadingEmail = false;
        });
        return;
      }

      // Create user account
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created successfully!'),
            backgroundColor: successBg,
          ),
        );

        // Navigate after sign up
        await _navigateAfterSignUp(userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      if (mounted) {
        final errorBg = AppTheme.getComponentBackgroundColor(
          context,
          'snackbar-error',
          fallback: Colors.red,
        );
        String errorMessage;
        
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password is too weak. Please use a stronger password.';
            break;
          case 'email-already-in-use':
            errorMessage = 'An account already exists with this email address.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address format.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email/password sign-up is not enabled. Please contact support.';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your connection and try again.';
            break;
          default:
            errorMessage = 'Sign-up failed: ${e.message ?? e.code}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: errorBg,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      // Handle other errors
      if (mounted) {
        final errorBg = AppTheme.getComponentBackgroundColor(
          context,
          'snackbar-error',
          fallback: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${FallbackValues.errorFailedToSave}: ${e.toString()}'),
            backgroundColor: errorBg,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingEmail = false;
        });
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
        _isLoadingGoogle = true;
      });

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        setState(() {
          _isLoading = false;
          _isLoadingGoogle = false;
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
      
      // Successfully signed up/in
      if (mounted) {
        final successBg = AppTheme.getComponentBackgroundColor(
          context,
          'snackbar-success',
          fallback: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created successfully!'),
            backgroundColor: successBg,
          ),
        );
        
        // Navigate after sign up
        await _navigateAfterSignUp(userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      if (mounted) {
        final errorBg = AppTheme.getComponentBackgroundColor(
          context,
          'snackbar-error',
          fallback: Colors.red,
        );
        String errorMessage;
        
        switch (e.code) {
          case 'invalid-credential':
            errorMessage = 'The authentication credential is invalid or has expired. Please try again.';
            break;
          case 'account-exists-with-different-credential':
            errorMessage = 'An account already exists with the same email but different sign-in method.';
            break;
          case 'invalid-verification-code':
            errorMessage = 'The verification code is invalid.';
            break;
          case 'invalid-verification-id':
            errorMessage = 'The verification ID is invalid.';
            break;
          default:
            errorMessage = 'Sign-up failed: ${e.message ?? e.code}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: errorBg,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final errorBg = AppTheme.getComponentBackgroundColor(
          context,
          'snackbar-error',
          fallback: Colors.red,
        );
        String errorMessage = 'Error signing up with Google';
        
        // Check for specific error codes
        if (e.toString().contains('ApiException: 10') || 
            e.toString().contains('DEVELOPER_ERROR') ||
            e.toString().contains('sign_in_failed')) {
          errorMessage = 'Google Sign-In configuration error. Please ensure:\n'
              '1. SHA-1 fingerprint is added to Firebase Console\n'
              '2. Google Sign-In is enabled in Firebase Authentication';
        } else {
          errorMessage = '${FallbackValues.errorFailedToSave}: ${e.toString()}';
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
          _isLoadingGoogle = false;
        });
      }
    }
  }

  Future<void> _signUpWithApple() async {
    try {
      print('🍎 [Apple Sign-Up] Starting Apple Sign-Up process...');
      
      // Check if Sign in with Apple is available
      final isAvailable = await SignInWithApple.isAvailable();
      print('🍎 [Apple Sign-Up] Sign in with Apple available: $isAvailable');
      
      if (!isAvailable) {
        throw Exception('Sign in with Apple is not available on this device');
      }
      
      setState(() {
        _isLoading = true;
        _isLoadingApple = true;
      });

      print('🍎 [Apple Sign-Up] Requesting Apple ID credential...');
      
      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print('🍎 [Apple Sign-Up] ✅ Successfully received Apple credential');

      if (appleCredential.identityToken == null) {
        print('🍎 [Apple Sign-Up] ❌ ERROR: identityToken is null!');
        throw Exception('Apple Sign-Up failed: identity token is null');
      }

      print('🍎 [Apple Sign-Up] Creating OAuth credential with Firebase...');
      // Create an `OAuthCredential` from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      print('🍎 [Apple Sign-Up] Signing in with Firebase...');
      // Sign in the user with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(oauthCredential);
      print('🍎 [Apple Sign-Up] ✅ Successfully signed up with Firebase');

      // Successfully signed up/in
      if (mounted) {
        final successBg = AppTheme.getComponentBackgroundColor(
          context,
          'snackbar-success',
          fallback: Colors.green,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Account created successfully!'),
            backgroundColor: successBg,
          ),
        );

        // If this is the first time signing in, update the user's display name
        if (appleCredential.givenName != null && appleCredential.familyName != null) {
          await userCredential.user?.updateDisplayName(
            '${appleCredential.givenName} ${appleCredential.familyName}',
          );
        }

        // Navigate after sign up
        await _navigateAfterSignUp(userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      print('🍎 [Apple Sign-Up] ❌ FirebaseAuthException occurred:');
      print('🍎 [Apple Sign-Up] Error code: ${e.code}');
      print('🍎 [Apple Sign-Up] Error message: ${e.message}');
      
      if (mounted) {
        final errorBg = AppTheme.getComponentBackgroundColor(
          context,
          'snackbar-error',
          fallback: Colors.red,
        );
        String errorMessage;
        
        switch (e.code) {
          case 'invalid-credential':
            errorMessage = 'The authentication credential is invalid or has expired. Please try again.';
            break;
          case 'account-exists-with-different-credential':
            errorMessage = 'An account already exists with the same email but different sign-in method.';
            break;
          case 'invalid-verification-code':
            errorMessage = 'The verification code is invalid.';
            break;
          case 'invalid-verification-id':
            errorMessage = 'The verification ID is invalid.';
            break;
          default:
            errorMessage = 'Sign-up failed: ${e.message ?? e.code}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: errorBg,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('🍎 [Apple Sign-Up] ❌ ERROR occurred:');
      print('🍎 [Apple Sign-Up] Error: $e');
      print('🍎 [Apple Sign-Up] Stack trace: $stackTrace');
      
      if (mounted) {
        final errorBg = AppTheme.getComponentBackgroundColor(
          context,
          'snackbar-error',
          fallback: Colors.red,
        );
        String errorMessage = 'Error signing up with Apple';
        
        // Check for specific error types
        if (e.toString().contains('SignInWithAppleAuthorizationException')) {
          if (e.toString().contains('canceled') || e.toString().contains('cancel')) {
            // User canceled, just reset loading state
            setState(() {
              _isLoading = false;
              _isLoadingApple = false;
            });
            return;
          }
          errorMessage = 'Apple Sign-In configuration error. Please check your setup.';
        } else if (e.toString().contains('AKAuthenticationError') || 
                   e.toString().contains('ASAuthorizationError')) {
          errorMessage = 'Apple authentication error. Check device/account settings.';
        } else {
          errorMessage = '${FallbackValues.errorFailedToSave}: ${e.toString()}';
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
          _isLoadingApple = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get component colors from Contentful (same as login page)
    final screenBg = AppTheme.getComponentBackgroundColor(
      context,
      'login_scaffold_background',
      fallback: Color(int.parse(FallbackValues.appBackground.replaceFirst('#', '0xFF'))),
    );
    final titleColor = AppTheme.getComponentTextColor(
      context,
      'login_title_text',
      fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))),
    );
    final hintColor = AppTheme.getComponentTextColor(
      context,
      'login_inputHint_text',
      fallback: Color(int.parse(FallbackValues.textSecondary.replaceFirst('#', '0xFF'))),
    );
    final inputBg = AppTheme.getComponentBackgroundColor(
      context,
      'login_input_background',
      fallback: Color(int.parse(FallbackValues.appBackground.replaceFirst('#', '0xFF'))),
    );
    final linkColor = AppTheme.getComponentTextColor(
      context,
      'link-primary',
      fallback: Color(int.parse(FallbackValues.yellowAccent.replaceFirst('#', '0xFF'))),
    );
    final primaryButtonBg = AppTheme.getComponentBackgroundColor(
      context,
      'login_signInButton_disabledBackground',
      fallback: Color(int.parse(FallbackValues.textSecondary.replaceFirst('#', '0xFF'))),
    );
    final primaryButtonText = AppTheme.getComponentTextColor(
      context,
      'login_signInButton_text',
      fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))),
    );
    final googleButtonBg = AppTheme.getComponentBackgroundColor(
      context,
      'login_googleButton_background',
      fallback: Color(int.parse(FallbackValues.redAccent.replaceFirst('#', '0xFF'))),
    );
    final googleButtonText = AppTheme.getComponentTextColor(
      context,
      'login_googleButton_text',
      fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))),
    );
    final googleButtonIcon = AppTheme.getComponentIconColor(
      context,
      'login_googleButton_icon',
      fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))),
    );
    final appleButtonBg = AppTheme.getComponentBackgroundColor(
      context,
      'login_appleButton_background',
      fallback: Color(int.parse(FallbackValues.appText.replaceFirst('#', '0xFF'))),
    );
    final appleButtonText = AppTheme.getComponentTextColor(
      context,
      'login_appleButton_text',
      fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))),
    );
    final appleButtonIcon = AppTheme.getComponentIconColor(
      context,
      'login_appleButton_icon',
      fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))),
    );
    final buttonText = AppTheme.getComponentTextColor(
      context,
      'button-text',
      fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))),
    );
    final bodyText = AppTheme.getComponentTextColor(
      context,
      'login_footerText_text',
      fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))),
    );
    final loadingIndicatorColor = AppTheme.getComponentIconColor(
      context,
      'login_loadingIndicator_color',
      fallback: Color(int.parse(FallbackValues.headerText.replaceFirst('#', '0xFF'))),
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: MeshBackground(
        animated: true,
        meshOpacity: 0.5,
        child: SafeArea(
          child: Column(
            children: [
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        // Sign Up Title - Centered
                        Center(
                          child: Text(
                            'Sign Up',
                            style: AppTheme.getDoubleBoldTextStyle(
                              color: titleColor,
                              fontSize: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Email Field
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: FallbackValues.labelEmail,
                            hintStyle: TextStyle(color: hintColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: inputBg,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
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
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        // Confirm Password Field
                        TextField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            hintStyle: TextStyle(color: hintColor),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: inputBg,
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) {
                            if (!_isLoading && 
                                _emailController.text.isNotEmpty && 
                                _passwordController.text.isNotEmpty &&
                                _confirmPasswordController.text.isNotEmpty) {
                              _signUpWithEmail();
                            }
                          },
                        ),
                        const SizedBox(height: 24),
                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signUpWithEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryButtonBg,
                              foregroundColor: primaryButtonText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoadingEmail
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(loadingIndicatorColor),
                                    ),
                                  )
                                : const Text(
                                    'Sign Up',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // OR Separator
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: linkColor,
                                thickness: 2.0,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: AppTheme.getDoubleBoldTextStyle(
                                  color: linkColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: linkColor,
                                thickness: 2.0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        // Sign up with Google Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _signUpWithGoogle,
                            icon: _isLoadingGoogle
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
                              _isLoadingGoogle ? 'Signing up...' : 'Sign up with Google',
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
                        // Sign up with Apple Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signUpWithApple,
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
                                _isLoadingApple
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(appleButtonText),
                                        ),
                                      )
                                    : Icon(Icons.apple, color: appleButtonIcon),
                                const SizedBox(width: 8),
                                Text(
                                  _isLoadingApple ? 'Signing up...' : 'Sign up with Apple',
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
                      ],
                    ),
                  ),
                ),
              ),
              // Footer at the bottom
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppTheme.getDoubleBoldTextStyle(
                          color: bodyText,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign In',
                          style: AppTheme.getDoubleBoldTextStyle(
                            color: linkColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

