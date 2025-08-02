import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:inboundmobile/app/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';


@RoutePage()
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Profile Screen',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async{
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                context.router.replace(LoginRoute());
              },
              child: const Text('Logout'),
            ),
          ],
        )
      ),
    );
  }
}