import 'package:flutter/material.dart';
import '../models/order_models.dart';
import '../utils/theme.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = order.status == OrderStatus.completed
        ? AppTheme.getComponentIconColor(context, 'orderCard_status_completed', fallback: Colors.green)
        : order.status == OrderStatus.cancelled
            ? AppTheme.getComponentIconColor(context, 'orderCard_status_cancelled', fallback: Colors.red)
            : AppTheme.getComponentIconColor(context, 'orderCard_status_inProgress', fallback: Colors.orange);

    return Card(
      elevation: 0,
      color: AppTheme.getComponentBackgroundColor(context, 'orderCard_background', fallback: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppTheme.getComponentBorderColor(context, 'orderCard_border', fallback: Colors.grey[300]!),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Orange dot
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Order number and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.status.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Date and phone number
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(order.orderDate),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.getComponentTextColor(context, 'orderCard_date_text', fallback: Colors.grey),
                    ),
                  ),
                  if (order.phoneNumber != null && order.phoneNumber!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      order.phoneNumber!,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.getComponentTextColor(context, 'orderCard_phoneNumber_text', fallback: Colors.grey),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 8),
              // Chevron
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Icon(
                  Icons.chevron_right,
                  color: AppTheme.getComponentIconColor(context, 'orderCard_chevronIcon', fallback: Colors.grey),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

