// widgets/session_list.dart
import 'package:flutter/material.dart';
import 'package:inboundmobile/features/dashboard/model/session_model.dart';
import 'package:inboundmobile/features/dashboard/widgets/session_card.dart';

class SessionList extends StatelessWidget {
  final List<SessionModel> sessions;
  final bool isOwnedByMe;
  final void Function(SessionModel) onCheckIn;

  const SessionList({
    super.key,
    required this.sessions,
    required this.isOwnedByMe,
    required this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sessions.length,
      itemBuilder: (context, index) => SessionCard(
        session: sessions[index],
        isOwnedByMe: isOwnedByMe,
        onCheckIn: () => onCheckIn(sessions[index]),
      ),
    );
  }
}