import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_colors_service.dart';
import '../utils/theme.dart';

/// Banner widget that displays when the app is offline
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colorsService = Provider.of<AppColorsService>(context);
    
    if (!colorsService.isOffline) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.getComponentBackgroundColor(context, 'offlineBanner_background', fallback: AppTheme.warningColorDynamic(context).withOpacity(0.1)),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            size: 16,
            color: AppTheme.getComponentIconColor(context, 'offlineBanner_icon', fallback: AppTheme.warningColorDynamic(context)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You\'re offline. Some content may be outdated.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.getComponentTextColor(context, 'offlineBanner_text', fallback: AppTheme.textSecondaryDynamic(context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

