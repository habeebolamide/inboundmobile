import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inboundmobile/app/router/app_router.dart';
import 'package:inboundmobile/core/constants/app_colors.dart';
import 'package:inboundmobile/core/helpers/loader_utils.dart';
import 'package:inboundmobile/features/dashboard/provider/session_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@RoutePage()
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late double _deviceHeight;
  late double _deviceWidth;

  String formattedDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM d, y').format(now);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<SessionProvider>(context, listen: false).todaySession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    // print('Testing session:${sessionProvider.sessions}');
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    if (sessionProvider.isLoading == true) {
      return const CustomLoader(); // Your animated loader here
    }

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topLayerWidget(),
                const SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: _deviceWidth * 0.05,
                  ),
                  child: const Text(
                    "Today's Sessions",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                if (sessionProvider.sessions.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(child: Text("No sessions available.")),
                  )
                else
                  ...sessionProvider.sessions.map((session) {
                    return Card(
                      margin: EdgeInsets.all(_deviceWidth * 0.05),
                      child: Padding(
                        padding: EdgeInsets.all(_deviceWidth * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              session.title ?? 'Untitled',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text("Time: ${session.startTime} - ${session.endTime}"),
                            const SizedBox(height: 5),
                            Text("Location: ${session.location ?? 'Unknown'}"),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topLayerWidget() {
    return SizedBox(
      height: _deviceHeight * 0.25,
      width: _deviceWidth,
      child: Container(
        padding: EdgeInsets.only(
          top: _deviceHeight * 0.02,
          left: _deviceWidth * 0.05,
          right: _deviceWidth * 0.05,
        ),
        decoration: const BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(50),
            bottomRight: Radius.circular(50),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  " Welcome back!\n",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton.filled(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('token');
                    context.router.replace(const LoginRoute());
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.plus,
                    color: Colors.white,
                    size: 25,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  formattedDate(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
