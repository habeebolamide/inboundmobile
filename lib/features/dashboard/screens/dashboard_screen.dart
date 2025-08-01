import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inboundmobile/app/router/app_router.dart';
import 'package:inboundmobile/core/constants/app_colors.dart';
import 'package:inboundmobile/core/helpers/%20snackbar_helper.dart';
import 'package:inboundmobile/core/helpers/loader_utils.dart';
import 'package:inboundmobile/features/authentication/provider/auth_provider.dart';
import 'package:inboundmobile/features/dashboard/data/session_repository.dart';
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
  bool isLoading = false;
  bool isSupervisor = false; // Track if the user is a supervisor
  final location = SessionRepository();
  final authprovider = AuthProvider();
  String formattedDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM d, y').format(now);
  }

  String formattedSDate(time) {
    return DateFormat('h:mm a').format(time);
  }

  @override
  void initState() async{
    super.initState();
    isSupervisor = await authprovider.isSupervisor();
    Future.microtask(() {
      Provider.of<SessionProvider>(context, listen: false).todaySession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
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
                    String status =
                        session.status ?? 'unknown'; // Get status from session

                    Color chipColor;
                    FaIcon icon;
                    String labelText;

                    // Determine chip properties based on session status
                    switch (status.toLowerCase()) {
                      case 'scheduled':
                        chipColor = AppColors.primary; // Color for scheduled
                        icon = FaIcon(
                          FontAwesomeIcons.calendar,
                          color: Colors.white,
                        );
                        labelText = 'Scheduled';
                        break;
                      case 'ongoing':
                        chipColor = AppColors.success; // Color for ongoing
                        icon = FaIcon(
                          FontAwesomeIcons.play,
                          color: Colors.white,
                        );
                        labelText = 'Ongoing';
                        break;
                      case 'ended':
                        chipColor = Colors.grey; // Color for ended
                        icon = FaIcon(
                          FontAwesomeIcons.stop,
                          color: Colors.white,
                        );
                        labelText = 'Ended';
                        break;
                      case 'cancelled':
                        chipColor = Colors.red; // Color for cancelled
                        icon = FaIcon(
                          FontAwesomeIcons.stop,
                          color: Colors.white,
                        );
                        labelText = 'Cancelled';
                        break;
                      default:
                        chipColor =
                            Colors.grey; // Default color for unknown status
                        icon = FaIcon(
                          FontAwesomeIcons.question,
                          color: Colors.white,
                        );
                        labelText = 'Unknown';
                        break;
                    }

                    return Card(
                      margin: EdgeInsets.all(_deviceWidth * 0.05),
                      child: Padding(
                        padding: EdgeInsets.all(_deviceWidth * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  session.title ?? 'Untitled',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    labelText,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  avatar: icon,
                                  backgroundColor: chipColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Time: ${formattedSDate(session.startTime)} - ${formattedSDate(session.endTime)}",
                            ),
                            const SizedBox(height: 5),
                            Text("Location: ${session.location ?? 'Unknown'}"),
                            
                            const SizedBox(height: 15),
                            ElevatedButton(
                              onPressed:
                                  session.checkin_status == 'yes'
                                      ? null
                                      : () async {
                                        setState(() {
                                          isLoading =
                                              true; // Show the loader when the button is pressed
                                        });

                                        if (status.toLowerCase() == 'ongoing') {
                                          final message = await location
                                              .getCurrentLocation(session.id ?? 0);

                                          if (message == null) {
                                            showSnackBar(
                                              context,
                                              "Checked in successfully",
                                              AppColors.success,
                                            );
                                            sessionProvider.todaySession();
                                          } else {
                                            showSnackBar(
                                              context,
                                              message.toString(),
                                              AppColors.error,
                                            );
                                          }
                                          setState(() {
                                            isLoading = false;
                                          });

                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Cannot check in for $status session',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                              ),
                              child:
                                  isLoading
                                      ? Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ) 
                                      : Text(
                                        'CheckIn',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                            ),
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
          color: AppColors.primary,
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
                if (isSupervisor)
                IconButton.filled(
                 onPressed: () async{
                  // final SharedPreferences prefs = await SharedPreferences.getInstance();
                  // prefs.clear();
                  // context.router.replace(LoginRoute());
                    context.router.push(const CreateSessionRoute());
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
