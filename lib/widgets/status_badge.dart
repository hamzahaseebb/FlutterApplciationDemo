import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  
  const StatusBadge({super.key, required this.status});
  
  Color _getStatusColor() {
    switch (status) {
      case 'Received':
        return Colors.orange;
      case 'Washing':
        return Colors.blue;
      case 'Ready':
        return Colors.green;
      case 'Delivered':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon() {
    switch (status) {
      case 'Received':
        return Icons.pending_actions;
      case 'Washing':
        return Icons.local_laundry_service;
      case 'Ready':
        return Icons.check_circle;
      case 'Delivered':
        return Icons.delivery_dining;
      default:
        return Icons.help;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getStatusColor();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getStatusIcon(), size: 16, color: statusColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}