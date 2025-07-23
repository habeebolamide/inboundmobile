import 'package:auto_route/auto_route.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_router.dart';

class AuthGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      resolver.next(true); // Allow navigation
    } else {
      router.push(LoginRoute()); // Block & redirect
    }
  }
}

class LoginGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      // ✅ User is logged in, redirect to dashboard or main layout
      router.replace(const LayoutRoute());
    } else {
      // ✅ User not logged in, allow access to login
      resolver.next(true);
    }
  }
}
