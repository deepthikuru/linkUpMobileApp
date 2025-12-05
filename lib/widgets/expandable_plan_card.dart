import 'package:flutter/material.dart';
import '../models/plan_model.dart';
import '../utils/theme.dart';

class ExpandablePlanCard extends StatelessWidget {
  final Plan plan;
  final bool isExpanded;
  final bool showUnlimited;
  final VoidCallback onTap;
  final VoidCallback? onContinue;

  const ExpandablePlanCard({
    super.key,
    required this.plan,
    required this.isExpanded,
    required this.showUnlimited,
    required this.onTap,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    // Get base background color
    final baseColor = AppTheme.getComponentBackgroundColor(
      context,
      'planCard_background',
      fallback: Colors.white,
    );
    
    // Apply subtle solid color when expanded/selected
    final cardColor = isExpanded
        ? AppTheme.getComponentBackgroundColor(
            context,
            'planCard_backgroundSelected',
            fallback: const Color(0xFFE8F4F8), // Light blue solid color
          )
        : baseColor;
    
    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isExpanded
              ? AppTheme.getComponentBorderColor(
                  context,
                  'planCard_borderSelected',
                  fallback: AppTheme.mainBlue,
                )
              : AppTheme.getComponentBorderColor(
                  context,
                  'planCard_border',
                  fallback: Colors.grey[500]!,
                ),
          width: isExpanded ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Collapsed/Header section - always visible
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      if (plan.displayName != null && plan.displayName!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: isExpanded
                                ? (AppTheme.getComponentGradient(
                                        context,
                                        'planCard_badgeGradientStart',
                                        fallback: AppTheme.blueGradient) ??
                                    AppTheme.blueGradient)
                                : null,
                            color: isExpanded
                                ? null
                                : AppTheme.getComponentBackgroundColor(
                                    context,
                                    'planCard_badgeBackground',
                                    fallback: AppTheme.secondBlue.withOpacity(0.1),
                                  ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isExpanded
                                  ? Colors.transparent
                                  : AppTheme.getComponentBorderColor(
                                      context,
                                      'planCard_badgeBorder',
                                      fallback: AppTheme.secondBlue.withOpacity(0.5),
                                    ),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            plan.displayName!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isExpanded
                                  ? AppTheme.getComponentTextColor(
                                      context,
                                      'planCard_badgeTextSelected',
                                      fallback: Colors.white,
                                    )
                                  : AppTheme.getComponentTextColor(
                                      context,
                                      'planCard_badgeText',
                                      fallback: AppTheme.mainBlue,
                                    ),
                            ),
                          ),
                        ),
                      // Price
                      Text(
                        '\$${plan.totalPlanPrice}/month',
                        style: AppTheme.getDoubleBoldTextStyle(
                          color: AppTheme.secondBlue,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  if (plan.displayName != null && plan.displayName!.isNotEmpty)
                    const SizedBox(height: 4)
                  else
                    const SizedBox(height: 0),
                  Text(
                    plan.planName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description text - shown before expanding
                  Text(
                    _buildDescription(plan),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isExpanded ? 'Tap to collapse' : 'Tap to view details',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.mainBlue,
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: AppTheme.mainBlue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Expanded section - shows when isExpanded is true
          if (isExpanded) ...[
            Divider(
              height: 1,
              color: AppTheme.getComponentBorderColor(
                context,
                'planCard_divider',
                fallback: Colors.grey[300],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Features list (description is already shown in collapsed view)
                  ..._buildFeaturesList(context, plan),
                  const SizedBox(height: 12),
                  // Continue button
                  if (onContinue != null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getComponentBackgroundColor(
                            context,
                            'button-danger',
                            fallback: AppTheme.mainBlue,
                          ),
                          foregroundColor: AppTheme.getComponentTextColor(
                            context,
                            'button-danger',
                            fallback: Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String value,
    required String label,
    required BuildContext? context,
  }) {
    final iconColor = context != null
        ? AppTheme.getComponentIconColor(
            context,
            'planCard_featureIcon',
            fallback: AppTheme.mainBlue,
          )
        : AppTheme.mainBlue;
    final labelColor = context != null
        ? AppTheme.getComponentTextColor(
            context,
            'planCard_featureLabel_text',
            fallback: Colors.grey,
          )
        : Colors.grey;

    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.normal,
            color: labelColor,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatCalls(int minutes, bool showUnlimited) {
    if (showUnlimited) {
      return 'Unlimited';
    }
    if (minutes >= 9999000) {
      return 'Unlimited';
    }
    if (minutes >= 1000) {
      return '${minutes ~/ 1000}K';
    }
    return '$minutes';
  }

  String _formatMessages(int messages, bool showUnlimited) {
    if (showUnlimited) {
      return 'Unlimited';
    }
    if (messages >= 9999000) {
      return 'Unlimited';
    }
    if (messages >= 1000) {
      return '${messages ~/ 1000}K';
    }
    return '$messages';
  }

  String _formatData(int mb, bool showUnlimited) {
    if (showUnlimited) {
      return 'Unlimited';
    }
    if (mb >= 1000) {
      return '${mb ~/ 1000}GB';
    }
    return '${mb}MB';
  }

  String _buildDescription(Plan plan) {
    final data = _formatData(plan.data, false);
    final displayName = plan.displayName ?? '';

    if (displayName.contains('STARTER')) {
      return '1GB, Light users';
    } else if (displayName.contains('EXPLORE')) {
      return '5 GB, Everyday use + international perks';
    } else if (displayName.contains('PREMIUM')) {
      return '12 GB, Streaming & multi-service';
    } else if (displayName.contains('UNLIMITED PLUS')) {
      return '50GB, all the data, all the speed';
    } else if (displayName.contains('UNLIMITED')) {
      return '30GB, Heavy usage and roaming';
    }

    return '$data, ${plan.planDescription.isNotEmpty ? plan.planDescription : "High-speed data"}';
  }

  List<Widget> _buildFeaturesList(BuildContext context, Plan plan) {
    final features = <Widget>[];
    final displayName = plan.displayName ?? '';

    // Build features based on plan type
    if (displayName.contains('STARTER')) {
      features.add(_buildFeatureBullet(
        context,
        'Unlimited Talk & Text (USA, Canada, Mexico)',
      ));
      features.add(_buildFeatureBullet(
        context,
        '1 GB high-speed data (5G/4G LTE)',
      ));
      features.add(_buildFeatureBullet(context, 'Perfect for light data use'));
      features.add(_buildFeatureBullet(
        context,
        'Affordable/Flexible data add-ons',
      ));
      features.add(_buildFeatureBullet(
        context,
        'Global Roaming via "Wifi - Calling"',
      ));
    } else if (displayName.contains('EXPLORE')) {
      features.add(_buildFeatureBullet(
        context,
        'Unlimited Talk & Text (USA, Canada, Mexico)',
      ));
      features.add(_buildFeatureBullet(context, '5 GB high-speed data'));
      features.add(_buildFeatureBullet(
        context,
        'Affordable/Flexible data add-ons',
      ));
      features.add(_buildFeatureBullet(
        context,
        'Free Roaming in Mexico & Canada',
      ));
      features.add(_buildFeatureBullet(
        context,
        'Global Roaming via "Wifi - Calling"',
      ));
    } else if (displayName.contains('PREMIUM')) {
      features.add(_buildFeatureBullet(
        context,
        'Unlimited Talk & Text (USA, Canada, Mexico)',
      ));
      features.add(_buildFeatureBullet(context, '12 GB high-speed data'));
      features.add(_buildFeatureBullet(
        context,
        '100+ International Calling Destinations',
      ));
      features.add(_buildFeatureBullet(
        context,
        'Free Roaming in Mexico & Canada',
      ));
      features.add(_buildFeatureBullet(
        context,
        'Global Roaming via "Wifi - Calling"',
      ));
    } else if (displayName.contains('UNLIMITED PLUS')) {
      features.add(_buildFeatureBullet(
        context,
        'Unlimited data (50GB High-speed, then reduced)',
      ));
      features.add(_buildFeatureBullet(
        context,
        'Unlimited Talk & Text (USA, Canada, Mexico)',
      ));
      features.add(_buildFeatureBullet(
        context,
        '100+ International Calling Destinations',
      ));
      features.add(_buildFeatureBullet(
        context,
        'Free Roaming in Mexico & Canada',
      ));
      features.add(_buildFeatureBullet(
        context,
        'Global Roaming via "Wifi - Calling"',
      ));
    } else if (displayName.contains('UNLIMITED')) {
      features.add(_buildFeatureBullet(
        context,
        'Unlimited data (30GB High-speed, then reduced)',
      ));
      features.add(_buildFeatureBullet(context, '30 GB high-speed data'));
      features.add(_buildFeatureBullet(
        context,
        '100+ International Calling Destinations',
      ));
      features.add(_buildFeatureBullet(
        context,
        'Free Roaming in Mexico & Canada',
      ));
      features.add(_buildFeatureBullet(
        context,
        'Global Roaming via "Wifi - Calling"',
      ));
    } else {
      // Fallback: Use displayFeaturesDescription if available
      if (plan.displayFeaturesDescription.isNotEmpty) {
        for (var feature in plan.displayFeaturesDescription) {
          features.add(_buildFeatureBullet(context, feature));
        }
      } else {
        // Generic fallback
        if ((plan.talk >= 9999000 || plan.talk == 0) &&
            (plan.text >= 9999000 || plan.text == 0)) {
          features.add(_buildFeatureBullet(
            context,
            'Unlimited Talk & Text (USA, Canada, Mexico)',
          ));
        }

        final dataText = _formatData(plan.data, showUnlimited);
        if (plan.data >= 1000) {
          if (plan.isUnlimitedPlan == 'Y') {
            features.add(_buildFeatureBullet(
              context,
              'Unlimited data ($dataText High-speed, then reduced)',
            ));
            features.add(_buildFeatureBullet(
              context,
              '$dataText high-speed data',
            ));
          } else {
            features.add(_buildFeatureBullet(
              context,
              '$dataText high-speed data',
            ));
          }
        }

        features.add(_buildFeatureBullet(
          context,
          'Affordable/Flexible data add-ons',
        ));

        if (plan.totalPlanPrice >= 30) {
          features.add(_buildFeatureBullet(
            context,
            '100+ International Calling Destinations',
          ));
        }

        if (plan.totalPlanPrice >= 20) {
          features.add(_buildFeatureBullet(
            context,
            'Free Roaming in Mexico & Canada',
          ));
        }

        features.add(_buildFeatureBullet(
          context,
          'Global Roaming via "Wifi - Calling"',
        ));
      }
    }

    return features;
  }

  Widget _buildFeatureBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 10),
            child: SizedBox(
              width: 8,
              height: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.yellowAccent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

