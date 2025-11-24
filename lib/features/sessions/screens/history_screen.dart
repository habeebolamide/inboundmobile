import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inboundmobile/core/constants/app_colors.dart';
import 'package:inboundmobile/core/helpers/%20snackbar_helper.dart';
import 'package:inboundmobile/core/helpers/loader_utils.dart';
import 'package:inboundmobile/features/dashboard/data/session_repository.dart';
import 'package:inboundmobile/features/dashboard/model/session_model.dart';
import 'package:intl/intl.dart';

@RoutePage()
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final sessions = SessionRepository();
  List<SessionModel> sessionList = []; // Store fetched sessions
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    try {
      final fetchedSessions = await sessions.fetchSessions();
      setState(() {
        sessionList = fetchedSessions;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, e.toString(), AppColors.error);
    }
  }

  String formattedSDate(time) {
    return DateFormat('EEE h:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Session History')),
      body: RefreshIndicator(
        onRefresh: _loadSessions,
        child:
            isLoading
                ? const CustomLoader()
                : sessionList.isEmpty
                ? const Center(child: Text('No sessions found'))
                : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: sessionList.length,
                  itemBuilder: (context, index) {
                    final session = sessionList[index];
                    String status =
                        session.status ?? 'unknown'; // Get status from session

                    Color chipColor;
                    FaIcon icon;
                    String labelText;
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
                      elevation: 4.0,
                      margin: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 4.0,
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    session.title ?? 'Untitled',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
