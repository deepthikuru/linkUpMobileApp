import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'providers/user_registration_view_model.dart';
import 'providers/navigation_state.dart';
import 'utils/theme.dart';
import 'services/notification_service.dart';
import 'services/contentful_service.dart';
import 'services/app_colors_service.dart';
import 'services/component_colors_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Notification Service
  try {
    await NotificationService().initialize();
    print('✅ Notification service initialized in main');
  } catch (e) {
    print('❌ Error initializing notification service: $e');
    // Don't block app startup if notifications fail
  }

  // Initialize Contentful Service
  try {
    await ContentfulService().initialize(
      spaceId: 'w44htb0sb9sl',
      accessToken: 'rm5ph3ht3B4U-6PG9zM_opMFnoVojXmHOe3T9R9C8JQ',
      previewAccessToken: 'wdRyb5ysWZkGDt9IXM-O2BaLCQiiZxW-ZIoBTdhcxMc',
      environment: 'master',
      usePreview: false, // Set to true to use Preview API for draft content
    );
    print('✅ Contentful service initialized in main');
  } catch (e) {
    print('❌ Error initializing Contentful service: $e');
    // Don't block app startup if Contentful fails
  }

  // Initialize App Colors Service (loads from cache immediately)
  try {
    await AppColorsService().initialize();
    print('✅ App colors service initialized in main');
  } catch (e) {
    print('❌ Error initializing app colors service: $e');
    // App continues with default colors
  }

  // Initialize Component Colors Service (loads from cache immediately)
  try {
    await ComponentColorsService().initialize();
    print('✅ Component colors service initialized in main');
  } catch (e) {
    print('❌ Error initializing component colors service: $e');
    // App continues with default colors
  }
  
  runApp(const LinkMobileApp());
}

class LinkMobileApp extends StatelessWidget {
  const LinkMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserRegistrationViewModel()),
        ChangeNotifierProvider(create: (_) => NavigationState()),
        ChangeNotifierProvider.value(value: AppColorsService()),
        ChangeNotifierProvider.value(value: ComponentColorsService()), // Add ComponentColorsService
      ],
      child: Consumer<AppColorsService>(
        builder: (context, colorsService, _) {
          return MaterialApp(
            title: 'LinkUp Mobile',
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppTheme.mainBlueDynamic(context),
                primary: AppTheme.mainBlueDynamic(context),
                secondary: AppTheme.secondBlueDynamic(context),
                surface: AppTheme.appBackgroundDynamic(context),
                error: AppTheme.errorColorDynamic(context),
              ),
              textTheme: GoogleFonts.montserratTextTheme(),
              fontFamily: GoogleFonts.montserrat().fontFamily,
              appBarTheme: AppBarTheme(
                backgroundColor: AppTheme.headerBackgroundDynamic(context),
                foregroundColor: AppTheme.headerTextDynamic(context),
                elevation: 0,
                titleTextStyle: GoogleFonts.montserrat(
                  color: AppTheme.headerTextDynamic(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mainBlueDynamic(context),
                  foregroundColor: Colors.white,
                  textStyle: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
