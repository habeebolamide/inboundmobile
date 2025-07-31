import 'package:auto_route/auto_route.dart';
import 'package:inboundmobile/features/authentication/screens/login_screen.dart';
import 'package:inboundmobile/features/dashboard/screens/dashboard_screen.dart';
import 'package:inboundmobile/features/sessions/screens/create_session_screen.dart';
import 'package:inboundmobile/features/sessions/screens/history_screen.dart';
import 'package:inboundmobile/features/splash/screen/splash_screen.dart';
import 'auth_guard.dart';
import '../../layout.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  final AuthGuard authGuard;
  final LoginGuard loginGuard;
  AppRouter(this.authGuard,this.loginGuard);

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashRoute.page,initial: true),
    AutoRoute(page: LoginRoute.page,guards: [loginGuard]),
    AutoRoute(page: CreateSessionRoute.page, guards: [authGuard]),
    AutoRoute(
      page: LayoutRoute.page,
      guards: [authGuard],
      children: [
        AutoRoute(path: 'dashboard', page: DashboardRoute.page,initial: true),
        AutoRoute(path: 'history', page: HistoryRoute.page),
      ],
    ),

    // AutoRoute(page: DashboardRoute.page, path: '/dashboard',guards: [authGuard]),
  ];
}
