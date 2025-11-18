import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

/// Бейдж для отображения группы в карточке профиля
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        groupName,
        style: AppTextStyles.caption(context).copyWith(
          fontSize: 11,
          color: primaryColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

