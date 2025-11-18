// lib/features/dashboard/presentation/widgets/dashboard_header.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inboundmobile/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class DashboardHeader extends StatelessWidget {
  final bool isSupervisor;
  final VoidCallback onCreatePressed;

  const DashboardHeader({
    super.key,
    required this.isSupervisor,
    required this.onCreatePressed,
  });

  String _formatDate(DateTime date) => DateFormat('EEEE, MMMM d, y').format(date);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 20,
        left: 20, right: 20, bottom: 40,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Welcome back!\n",
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900),
              ),
              if (isSupervisor)
                FloatingActionButton.small(
                  onPressed: onCreatePressed,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: const FaIcon(FontAwesomeIcons.plus, color: Colors.white),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(_formatDate(DateTime.now()), style: const TextStyle(color: Colors.white70, fontSize: 18)),
        ],
      ),
    );
  }
}