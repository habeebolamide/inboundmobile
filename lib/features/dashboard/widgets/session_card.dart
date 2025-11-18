// lib/features/dashboard/presentation/widgets/session_card.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inboundmobile/core/constants/app_colors.dart';
import 'package:inboundmobile/features/dashboard/model/session_model.dart';
import 'package:intl/intl.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;
  final bool isOwnedByMe;
  final VoidCallback onCheckIn;

  const SessionCard({
    super.key,
    required this.session,
    required this.isOwnedByMe,
    required this.onCheckIn,
  });

  String _formatTime(DateTime? time) =>
      time != null ? DateFormat('h:mm a').format(time) : 'Not set';

  @override
  Widget build(BuildContext context) {
    final status = (session.status?.toLowerCase()) ?? 'unknown';
    final (chipColor, icon, label) = switch (status) {
      'scheduled' => (
        AppColors.primary,
        FontAwesomeIcons.calendar,
        'Scheduled',
      ),
      'ongoing' => (AppColors.success, FontAwesomeIcons.playCircle, 'Ongoing'),
      'ended' => (Colors.grey.shade600, FontAwesomeIcons.stop, 'Ended'),
      'cancelled' => (Colors.red, FontAwesomeIcons.ban, 'Cancelled'),
      _ => (Colors.orange, FontAwesomeIcons.circleQuestion, 'Unknown'),
    };

    final bool canCheckIn =
        status == 'ongoing' && session.checkin_status != 'yes';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                    label,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                  avatar: FaIcon(icon, size: 14, color: Colors.white),
                  backgroundColor: chipColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "Time: ${_formatTime(session.startTime)} - ${_formatTime(session.endTime)}",
            ),
            Text("Location: ${session.location ?? 'Not specified'}"),
            const SizedBox(height: 16),

            // Check-in button logic
            if (canCheckIn)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onCheckIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: const Text(
                    "Check In",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )
            else if (status == 'ongoing')
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text(
                    "Checked In",
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            if (isOwnedByMe && (status == 'scheduled')) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const FaIcon(FontAwesomeIcons.play, size: 10),
                      label: const Text(
                        "Start Session",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // END SESSION Button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      // Disable if not ongoing
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const FaIcon(FontAwesomeIcons.stop, size: 10),
                      label: const Text(
                        "End Session",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
