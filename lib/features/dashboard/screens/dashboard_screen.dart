import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inboundmobile/app/router/app_router.dart';
import 'package:inboundmobile/core/constants/app_colors.dart';
import 'package:inboundmobile/core/helpers/%20snackbar_helper.dart';
import 'package:inboundmobile/core/helpers/loader_utils.dart';
import 'package:inboundmobile/features/authentication/provider/auth_provider.dart';
import 'package:inboundmobile/features/dashboard/data/session_repository.dart';
import 'package:inboundmobile/features/dashboard/model/session_model.dart';
import 'package:inboundmobile/features/dashboard/provider/session_provider.dart';
import 'package:inboundmobile/features/dashboard/widgets/dashboard_header.dart';
import 'package:inboundmobile/features/dashboard/widgets/empty_state_widget.dart';
import 'package:inboundmobile/features/dashboard/widgets/session_header.dart';
import 'package:inboundmobile/features/dashboard/widgets/session_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

@RoutePage()
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final SessionRepository _sessionRepo;
  late final AuthProvider _authProvider;

  bool _isSupervisor = false;
  bool _isLoading = false;

  // Two separate lists for supervisors
  List<SessionModel> _assignedSessions = [];
  List<SessionModel> _toAttendSession = [];

  @override
  void initState() {
    super.initState();
    _sessionRepo = SessionRepository();
    _authProvider = AuthProvider();
    _checkUserRoleAndLoadSessions();
  }

  Future<void> _checkUserRoleAndLoadSessions() async {
    setState(() => _isLoading = true);
    try {
      final isSupervisor = await _authProvider.isSupervisor();
      setState(() => _isSupervisor = isSupervisor);
      await _refreshSessions();
    } catch (e) {
      if (mounted)
        showSnackBar(context, "Failed to load role", AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshSessions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      if (_isSupervisor) {
        // Fetch both independently
        final assigned = await _sessionRepo.fetchSupervisorSessions();
        final toattend = await _sessionRepo.todaySession();

        setState(() {
          _assignedSessions = assigned;
          _toAttendSession = toattend;
        });
      } else {
        final sessions = await _sessionRepo.todaySession();
        sessions.sort(
          (a, b) => (a.startTime ?? DateTime.now()).compareTo(
            b.startTime ?? DateTime.now(),
          ),
        );
        setState(() {
          _assignedSessions = [];
          _toAttendSession = sessions;
        });
      }
    } catch (e) {
      if (mounted)
        showSnackBar(context, "Failed to load sessions", AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(DateTime date) =>
      DateFormat('EEEE, MMMM d, y').format(date);
  String _formatTime(DateTime? time) =>
      time != null ? DateFormat('EEEE, h:mm a').format(time) : 'Not set';

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
      await _refreshSessions();
    } else {
      showSnackBar(context, result.toString(), AppColors.error);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = Provider.of<SessionProvider>(context);
    if (sessionProvider.isLoading) return const CustomLoader();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshSessions,
        color: AppColors.primary,
        child: Stack(
          children: [
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                DashboardHeader(
                  isSupervisor: _isSupervisor,
                  onCreatePressed:
                      () => context.router.push(const CreateSessionRoute()),
                ),
                const SizedBox(height: 20),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Dashboard",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ))
                else ...[
                  if (_isSupervisor && _assignedSessions.isNotEmpty) ...[
                    SesctionHeader(title: "My Assigned Sessions"),
                    SessionList(sessions: _assignedSessions, isOwnedByMe: true, onCheckIn: _handleCheckIn,onRefresh: _refreshSessions),
                    const SizedBox(height: 24),
                  ],

                  if (_toAttendSession.isNotEmpty) ...[
                    SesctionHeader(title: "Today's Sessions"),
                    SessionList(sessions: _toAttendSession, isOwnedByMe: false, onCheckIn: _handleCheckIn, onRefresh: _refreshSessions),
                    const SizedBox(height: 24),
                  ] else if (!_isSupervisor) ...[
                    SesctionHeader(title: "Today's Sessions"),
                    EmptyStateWidget(),
                    const SizedBox(height: 24),
                  ],

                  // Show empty state only for supervisors when both lists are empty
                  if (_isSupervisor &&
                      _assignedSessions.isEmpty &&
                      _toAttendSession.isEmpty) ...[
                    EmptyStateWidget(),
                    const SizedBox(height: 24),
                  ],
                ],
              ],
            ),
            if (_isLoading)
              const LinearProgressIndicator(
                backgroundColor: Color.fromARGB(0, 22, 18, 18),
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
          ],
        ),
      ),
    );
  }
}