import 'package:auto_route/auto_route.dart';
import 'package:inboundmobile/features/authentication/screens/login_screen.dart';
import 'package:inboundmobile/features/splash/screen/splash_screen.dart';
import 'auth_guard.dart';
import 'package:flutter/material.dart';



part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final AuthGuard authGuard;

  AppRouter(this.authGuard);

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page, path: '/'),
    AutoRoute(page: LoginRoute.page, path: '/login'),
  ];
}
