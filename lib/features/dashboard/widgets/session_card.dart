import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inboundmobile/core/constants/app_colors.dart';
import 'package:inboundmobile/core/helpers/%20snackbar_helper.dart';
import 'package:inboundmobile/features/dashboard/data/session_repository.dart';
import 'package:inboundmobile/features/dashboard/model/session_model.dart';
import 'package:intl/intl.dart';

class SessionCard extends StatefulWidget {
  final SessionModel session;
  final bool isOwnedByMe;
  final VoidCallback onRefresh;

  const SessionCard({
    super.key,
    required this.session,
    required this.isOwnedByMe,
    required this.onRefresh,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  final _sessionRepo = SessionRepository();
  bool _isLoading = false;

  String _formatTime(DateTime? time) =>
      time != null ? DateFormat('EEE h:mm a').format(time) : 'Not set';

  Future<void> _handleStartSession() async {
    // if (widget.session.status?.toLowerCase() != 'scheduled') return;

    setState(() => _isLoading = true);

    try {
      final success = await _sessionRepo.startSession(widget.session.id ?? '');

      if (!mounted) return;

      if (success == null) {
        showSnackBar(
          context,
          "Session started successfully!",
          AppColors.success,
        );

        widget.onRefresh.call();
      } else {
        showSnackBar(context, success, AppColors.error);
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, e.toString(), AppColors.error);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCheckIn(SessionModel session) async {
    // return print('Check-in for session ${session.id}');
    if (session.status?.toLowerCase() != 'ongoing') {
      showSnackBar(context, "Session is not ongoing", AppColors.error);
      return;
    }
    if (session.checkin_status == 'yes') return;

    setState(() => _isLoading = true);
    final result = await _sessionRepo.CheckinToSession(session.id ?? '0');

    if (!mounted) return;

    if (result == null) {
      showSnackBar(context, "Checked in successfully!", AppColors.success);
      widget.onRefresh.call();
    } else {
      showSnackBar(context, result.toString(), AppColors.error);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final status = (widget.session.status?.toLowerCase()) ?? 'unknown';
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
        status == 'ongoing' && widget.session.checkin_status != 'yes';

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
                    widget.session.title ?? 'Untitled',
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
              "Time: ${_formatTime(widget.session.startTime)} - ${_formatTime(widget.session.endTime)}",
            ),
            Text("Location: ${widget.session.location ?? 'Not specified'}"),
            const SizedBox(height: 16),

            // Check-in button logic
            if (canCheckIn && !widget.isOwnedByMe)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _handleCheckIn(widget.session);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            "Check In",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              )
            else if (status == 'ongoing' && !widget.isOwnedByMe)
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

            if (widget.isOwnedByMe) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _isLoading || status != 'scheduled'
                              ? null
                              : _handleStartSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon:
                          _isLoading
                              ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const FaIcon(FontAwesomeIcons.play, size: 16),
                      label: const Text(
                        "Start Session",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

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
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),

                  //Cancel SESSION Button
                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading || status != 'scheduled'
                              ? null
                              : (){},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const FaIcon(FontAwesomeIcons.stop, size: 10),
                      label: const Text(
                        "Cancel Session",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
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
