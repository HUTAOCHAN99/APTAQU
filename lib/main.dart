import 'dart:async';
import 'package:al_quran/core/api/audio_service.dart';
import 'package:al_quran/core/provider/audio_provider.dart';
import 'package:al_quran/presentation/screens/auth/otp_screen.dart';
import 'package:al_quran/presentation/screens/game/crossword_screen.dart';
import 'package:al_quran/presentation/screens/game/game_screen.dart';
import 'package:al_quran/presentation/screens/game/quiz_screen.dart';
import 'package:al_quran/presentation/screens/profile/edit_profile_screen.dart';
import 'package:al_quran/presentation/screens/profile/profile_screen.dart';
import 'package:al_quran/presentation/screens/tafsir/bahasa/sign_language_screen.dart';
import 'package:al_quran/presentation/screens/tafsir/bahasa/tafsir_bahasa_screen.dart';
import 'package:al_quran/presentation/screens/tafsir/imli/tafsir_ilmi_screen.dart';
import 'package:al_quran/presentation/screens/tafsir/tarikh/tafsir_tarikh_screen.dart';
import 'package:al_quran/presentation/screens/tafsir/tematik/tafsir_tematik_screen.dart';
import 'package:al_quran/presentation/widgets/game/crossword_template_manager.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:al_quran/core/provider/auth_provider.dart';
import 'package:al_quran/core/services/auth_service.dart';
import 'package:al_quran/presentation/screens/auth/login_screen.dart';
import 'package:al_quran/presentation/screens/auth/register_screen.dart';
import 'package:al_quran/presentation/screens/auth/reset_password_screen.dart';
import 'package:al_quran/presentation/screens/auth/splash_screen.dart';
import 'package:al_quran/presentation/screens/home_screen.dart';
import 'package:al_quran/presentation/screens/auth/new_password_screen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<AudioService>(create: (_) => AudioService()),
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(
          create: (context) => AudioProvider(context.read<AudioService>()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _handleDeepLink(initialUri);
      });
    }

    _linkSubscription = _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  // Modify the _handleDeepLink function
  void _handleDeepLink(Uri uri) async {
    if (!mounted) return;

    debugPrint('Deep link received: $uri');

    final navigator = Navigator.of(context);

    if (uri.scheme == 'alquranapp') {
      if (uri.host == 'reset-password') {
        final token = uri.queryParameters['token'] ?? '';
        final email = uri.queryParameters['email'] ?? '';

        if (token.isNotEmpty && email.isNotEmpty) {
          navigator.pushReplacement(
            MaterialPageRoute(
              builder: (context) =>
                  NewPasswordScreen(email: email, token: token),
            ),
          );
        }
      } else if (uri.host == 'auth-callback') {
        try {
          final response = await Supabase.instance.client.auth
              .getSessionFromUrl(uri);
          debugPrint('Authentication response: ${response.session}');
          if (mounted) {
            navigator.pushReplacementNamed('/home');
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error during authentication: $e')),
            );
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Al Quran App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FutureBuilder(
          future: context.read<AuthProvider>().isLoggedInAndVerified(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }
            return snapshot.data == true
                ? const HomeScreen()
                : const LoginScreen();
          },
        ),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/otp': (context) => OTPScreen(
          email: ModalRoute.of(context)!.settings.arguments as String,
          isRegistration: true,
        ),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/new-password': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, String>?;
          return NewPasswordScreen(
            token: args?['token'] ?? '', // Pastikan nama parameter sesuai
            email: args?['email'] ?? '',
          );
        },
        '/home': (context) => const HomeScreen(),
        '/tafsir-bahasa': (context) => const TafsirBahasaScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/tafsir-ilmi': (context) => const TafsirIlmiScreen(),
        '/tafsir-tarikh': (context) => TafsirTarikhScreen(),
        '/tafsir-tematik': (context) => TafsirTematikScreen(),
        '/game': (context) => const GameScreen(),
        // In main.dart, update the routes:
        '/quiz': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return QuizScreen(category: args?['category'] ?? 'Umum');
        },
        '/crossword': (context) {
          // Get a random template from the manager
          final template = CrosswordTemplateManager.getRandomTemplates(1).first;
          return CrosswordScreen(template: template);
        },
         '/sign-language': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, int>?;
          return SignLanguageScreen(
            surahNumber: args?['surahNumber'] ?? 1,
            ayahNumber: args?['ayahNumber'] ?? 1,
          );
         },
      },
    );
  }
}
