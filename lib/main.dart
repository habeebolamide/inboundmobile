import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:inboundmobile/app/router/auth_guard.dart';
import 'package:inboundmobile/features/authentication/provider/auth_provider.dart';
import 'package:inboundmobile/features/dashboard/provider/session_provider.dart';
import 'package:provider/provider.dart';
import 'app/router/app_router.dart';
final _appRouter = AppRouter(AuthGuard(),LoginGuard()); // ✅ Initialize router

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  try {
    await dotenv.load(fileName: ".env"); // Load environment variables
  } catch (e) {
    throw Exception('Error loading .env file: $e'); // Print error if any
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'InBound',
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.config(),
    );
  }
}
