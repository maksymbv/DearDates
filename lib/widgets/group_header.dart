import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

/// Заголовок группы для отображения в списке
class GroupHeader extends StatelessWidget {
  final String groupName;
  final Color Function(BuildContext) getSecondaryTextColor;
  final bool isFirst;

  const GroupHeader({
    super.key,
    required this.groupName,
    required this.getSecondaryTextColor,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: isFirst ? 0 : 24,
        bottom: 12,
      ),
      child: Text(
        groupName,
        style: AppTextStyles.caption(context).copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: getSecondaryTextColor(context),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

