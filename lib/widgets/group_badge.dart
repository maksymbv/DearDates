import 'package:flutter/material.dart';
import '../themes/app_text_styles.dart';

/// Badge for displaying the group in the profile card
class GroupBadge extends StatelessWidget {
  final String groupName;
  final Color primaryColor;

  const GroupBadge({
    super.key,
    required this.groupName,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      groupName,
      style: AppTextStyles.caption(context).copyWith(
        fontSize: 13,
        color: primaryColor,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
    );
  }
}

