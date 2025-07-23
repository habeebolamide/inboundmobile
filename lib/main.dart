import 'package:flutter/material.dart';
import 'package:inboundmobile/app/router/auth_guard.dart';
import 'package:inboundmobile/features/authentication/provider/auth_provider.dart';
import 'package:provider/provider.dart';
import 'app/router/app_router.dart';
final _appRouter = AppRouter(AuthGuard(),LoginGuard()); // ✅ Initialize router

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
