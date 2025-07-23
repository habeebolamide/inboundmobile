import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inboundmobile/app/router/app_router.dart';

@RoutePage()
class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [DashboardRoute(), HistoryRoute()],

      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          backgroundColor: const Color(0xFFF6F5FF),

          body: child,
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: tabsRouter.activeIndex,
            selectedItemColor: const Color(0xFF6D3EDD),
            unselectedItemColor: Colors.grey,
            onTap: tabsRouter.setActiveIndex,
            items: [
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.house),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.clock),
                label: 'History',
              ),
            ],
          ),
        );
      },
    );
  }
}
