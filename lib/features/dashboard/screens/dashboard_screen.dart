import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inboundmobile/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

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
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topLayerWidget(),
                SizedBox(height: 20),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Dashboard Content Goes Here",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
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
          // padding:  EdgeInsets.symmetric(horizontal: 10.0, vertical: 35.0),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  " Welcome,back!\n",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton.filled(
                  onPressed: (){},
                  icon: FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 25),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                )
              ],
            ),
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
