// lib/features/dashboard/presentation/widgets/dashboard_header.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inboundmobile/core/constants/app_colors.dart';
import 'package:intl/intl.dart';

class SesctionHeader extends StatelessWidget {
  final String title;

  const SesctionHeader({
    super.key,
    required this.title,
  });

  String _formatDate(DateTime date) => DateFormat('EEEE, MMMM d, y').format(date);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}