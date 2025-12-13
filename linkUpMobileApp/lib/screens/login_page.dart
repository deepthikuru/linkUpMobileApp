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
import 'sign_up_page.dart';

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
  bool _isLoadingEmail = false;
  bool _isLoadingGoogle = false;
  bool _isLoadingApple = false;
  bool _isButtonEnabled = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    // Add listeners to text fields to enable/disable button
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    final isEnabled = _emailController.text.trim().isNotEmpty && 
                      _passwordController.text.isNotEmpty;
    if (_isButtonEnabled != isEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
        // Clear error messages when user starts typing
        if (_errorMessage != null) {
          _errorMessage = null;
        }
      });
    }
  }

  void _clearMessages() {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _successMessage = null;
    });
  }

  void _showSuccess(String message) {
    setState(() {
      _successMessage = message;
      _errorMessage = null;
    });
  }

  Future<void> _handleForgotPassword() async {
    _clearMessages();

    if (_emailController.text.isEmpty) {
      _showError(FallbackValues.errorPleaseEnterEmail);
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      if (mounted) {
        _showSuccess(FallbackValues.successPasswordResetSent);
      }
    } catch (e) {
      if (mounted) {
        _showError('${FallbackValues.errorFailedToSave}: ${e.toString()}');
      }
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateButtonState);
    _passwordController.removeListener(_updateButtonState);
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
      // Dismiss keyboard
      FocusScope.of(context).unfocus();
      
      _clearMessages();
      
      setState(() {
        _isLoading = true;
        _isLoadingEmail = true;
      });

      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        _showError(FallbackValues.errorPleaseEnterEmail);
        setState(() {
          _isLoading = false;
          _isLoadingEmail = false;
        });
        return;
      }

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        // Load user data and determine if new or existing user
        await _navigateAfterLogin(userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      if (mounted) {
        String errorMessage;
        
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No account found with this email address.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password. Please try again.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address format.';
            break;
          case 'invalid-credential':
            errorMessage = 'Invalid email or password. Please check your credentials and try again.';
            break;
          case 'user-disabled':
            errorMessage = 'This account has been disabled. Please contact support.';
            break;
          case 'too-many-requests':
            errorMessage = 'Too many failed attempts. Please try again later.';
            break;
          case 'operation-not-allowed':
            errorMessage = 'Email/password sign-in is not enabled. Please contact support.';
            break;
          case 'network-request-failed':
            errorMessage = 'Network error. Please check your connection and try again.';
            break;
          default:
            errorMessage = 'Sign-in failed: ${e.message ?? e.code}';
        }
        
        _showError(errorMessage);
      }
    } catch (e) {
      // Handle other errors
      if (mounted) {
        _showError('${FallbackValues.errorFailedToSave}: ${e.toString()}');
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

  Future<void> _signInWithGoogle() async {
    try {
      _clearMessages();
      
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
      
      // Successfully signed in
      if (mounted) {
        // Load user data and determine if new or existing user
        await _navigateAfterLogin(userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors
      if (mounted) {
        String errorMessage;
        
        switch (e.code) {
          case 'invalid-credential':
            errorMessage = 'The authentication credential is invalid or has expired. Please try signing in again.';
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
            errorMessage = 'Sign-in failed: ${e.message ?? e.code}';
        }
        
        _showError(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error signing in with Google';
        
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
        
        _showError(errorMessage);
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

  Future<void> _signInWithApple() async {
    try {
      _clearMessages();
      
      print('🍎 [Apple Sign-In] Starting Apple Sign-In process...');
      
      // Check if Sign in with Apple is available
      print('🍎 [Apple Sign-In] Checking if Sign in with Apple is available...');
      final isAvailable = await SignInWithApple.isAvailable();
      print('🍎 [Apple Sign-In] Sign in with Apple available: $isAvailable');
      
      if (!isAvailable) {
        throw Exception('Sign in with Apple is not available on this device');
      }
      
      setState(() {
        _isLoading = true;
        _isLoadingApple = true;
      });

      print('🍎 [Apple Sign-In] Requesting Apple ID credential...');
      print('🍎 [Apple Sign-In] Scopes: email, fullName');
      
      // Request credential for the currently signed in Apple account
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print('🍎 [Apple Sign-In] ✅ Successfully received Apple credential');
      print('🍎 [Apple Sign-In] User ID: ${appleCredential.userIdentifier}');
      print('🍎 [Apple Sign-In] Email: ${appleCredential.email ?? "not provided"}');
      print('🍎 [Apple Sign-In] Given Name: ${appleCredential.givenName ?? "not provided"}');
      print('🍎 [Apple Sign-In] Family Name: ${appleCredential.familyName ?? "not provided"}');
      print('🍎 [Apple Sign-In] Has identity token: ${appleCredential.identityToken != null}');
      print('🍎 [Apple Sign-In] Has authorization code: ${appleCredential.authorizationCode != null}');

      if (appleCredential.identityToken == null) {
        print('🍎 [Apple Sign-In] ❌ ERROR: identityToken is null!');
        throw Exception('Apple Sign-In failed: identity token is null');
      }

      print('🍎 [Apple Sign-In] Creating OAuth credential with Firebase...');
      // Create an `OAuthCredential` from the credential returned by Apple
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      print('🍎 [Apple Sign-In] Signing in with Firebase...');
      // Sign in the user with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(oauthCredential);
      print('🍎 [Apple Sign-In] ✅ Successfully signed in with Firebase');
      print('🍎 [Apple Sign-In] Firebase User ID: ${userCredential.user?.uid}');

      // Successfully signed in
      if (mounted) {
        // If this is the first time signing in, update the user's display name
        if (appleCredential.givenName != null && appleCredential.familyName != null) {
          await userCredential.user?.updateDisplayName(
            '${appleCredential.givenName} ${appleCredential.familyName}',
          );
        }

        // Load user data and determine if new or existing user
        await _navigateAfterLogin(userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      print('🍎 [Apple Sign-In] ❌ FirebaseAuthException occurred:');
      print('🍎 [Apple Sign-In] Error code: ${e.code}');
      print('🍎 [Apple Sign-In] Error message: ${e.message}');
      
      if (mounted) {
        String errorMessage;
        
        switch (e.code) {
          case 'invalid-credential':
            errorMessage = 'The authentication credential is invalid or has expired. Please try signing in again.';
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
            errorMessage = 'Sign-in failed: ${e.message ?? e.code}';
        }
        
        _showError(errorMessage);
      }
    } catch (e, stackTrace) {
      print('🍎 [Apple Sign-In] ❌ ERROR occurred:');
      print('🍎 [Apple Sign-In] Error type: ${e.runtimeType}');
      print('🍎 [Apple Sign-In] Error message: $e');
      print('🍎 [Apple Sign-In] Error toString: ${e.toString()}');
      print('🍎 [Apple Sign-In] Stack trace: $stackTrace');
      
      if (mounted) {
        String errorMessage = 'Error signing in with Apple';
        
        // Check for specific error types
        if (e.toString().contains('SignInWithAppleAuthorizationException')) {
          print('🍎 [Apple Sign-In] Detected SignInWithAppleAuthorizationException');
          if (e.toString().contains('canceled') || e.toString().contains('cancel')) {
            print('🍎 [Apple Sign-In] User canceled the sign-in');
            // User canceled, just reset loading state
            setState(() {
              _isLoading = false;
              _isLoadingApple = false;
            });
            return;
          }
          errorMessage = 'Apple Sign-In configuration error. Please check your setup.';
        } else if (e.toString().contains('AKAuthenticationError')) {
          print('🍎 [Apple Sign-In] Detected AKAuthenticationError');
          errorMessage = 'Apple authentication error. Check device/account settings.';
        } else if (e.toString().contains('ASAuthorizationError')) {
          print('🍎 [Apple Sign-In] Detected ASAuthorizationError');
          errorMessage = 'Apple authorization error. Check bundle ID configuration.';
        } else {
          errorMessage = '${FallbackValues.errorFailedToSave}: ${e.toString()}';
        }
        
        print('🍎 [Apple Sign-In] Showing error to user: $errorMessage');
        
        _showError(errorMessage);
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
    // Get component colors from Contentful
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
    final primaryButtonDisabledBg = AppTheme.getComponentBackgroundColor(
      context,
      'login_signInButton_disabledBackground',
      fallback: Color(int.parse(FallbackValues.textSecondary.replaceFirst('#', '0xFF'))),
    );
    // Use yellow accent for enabled state, or try to get enabled background from Contentful
    final primaryButtonEnabledBg = AppTheme.getComponentBackgroundColor(
      context,
      'login_signInButton_background',
      fallback: Color(int.parse(FallbackValues.yellowAccent.replaceFirst('#', '0xFF'))),
    );
    final primaryButtonBg = _isButtonEnabled ? primaryButtonEnabledBg : primaryButtonDisabledBg;
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
    final dividerColor = AppTheme.getComponentTextColor(
      context,
      'login_separator_text',
      fallback: Color(int.parse(FallbackValues.textSecondary.replaceFirst('#', '0xFF'))),
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
        meshOpacity: 0.5, // Reduced opacity to make background less disturbing
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
                      // Sign In Title - Centered, white with double bold style
                      Center(
                        child: Text(
                          FallbackValues.buttonSignIn,
                          style: AppTheme.getDoubleBoldTextStyle(
                            color: titleColor,
                            fontSize: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Error Message Display
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.getComponentBackgroundColor(
                              context,
                              'login_errorSnackbar_background',
                              fallback: Colors.red,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                color: Colors.white,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _clearMessages,
                              ),
                            ],
                          ),
                        ),
                      // Success Message Display
                      if (_successMessage != null)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.getComponentBackgroundColor(
                              context,
                              'login_successSnackbar_background',
                              fallback: Colors.green,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                color: Colors.white,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: _clearMessages,
                              ),
                            ],
                          ),
                        ),
                      // Show spacing only if there's a message
                      if (_errorMessage != null || _successMessage != null)
                        const SizedBox(height: 8),
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
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (!_isLoading && _isButtonEnabled) {
                            _signInWithEmail();
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      // Forgot Password Link
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: Text(
                            'Forgot password?',
                            style: AppTheme.getDoubleBoldTextStyle(
                              color: linkColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: (_isLoading || !_isButtonEnabled) ? null : _signInWithEmail,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryButtonBg,
                              foregroundColor: primaryButtonText,
                              disabledBackgroundColor: primaryButtonDisabledBg,
                              disabledForegroundColor: primaryButtonText.withOpacity(0.6),
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
                              : Text(
                                  FallbackValues.buttonSignIn,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // OR Separator - Yellow and bolder
                      Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: linkColor, // Yellow color
                              thickness: 2.0, // Made bolder
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'OR',
                              style: AppTheme.getDoubleBoldTextStyle(
                                color: linkColor, // Yellow color
                                fontSize: 14,
                                fontWeight: FontWeight.w900, // Extra bold
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: linkColor, // Yellow color
                              thickness: 2.0, // Made bolder
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Sign in with Google Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _signInWithGoogle,
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
                            _isLoadingGoogle ? 'Signing in...' : 'Sign in with Google',
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
                          onPressed: _isLoading ? null : _signInWithApple,
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
                                _isLoadingApple ? 'Signing in...' : 'Sign in with Apple',
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
            // Footer at the bottom - using Spacer approach
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New to LinkUp Mobile? ',
                      style: AppTheme.getDoubleBoldTextStyle(
                        color: bodyText,
                        fontSize: 14,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Create an account!',
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


