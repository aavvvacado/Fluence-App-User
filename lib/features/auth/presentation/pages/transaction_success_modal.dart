import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class TransactionSuccessModal extends StatelessWidget {
  final String transactionId;
  final String merchantName;
  final double amount;
  final DateTime timestamp;

  const TransactionSuccessModal({
    super.key,
    required this.transactionId,
    required this.merchantName,
    required this.amount,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.white,
                size: 40,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Success Title
            const Text(
              'Transaction Success',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Success Message
            const Text(
              'Credits will reflect after verification',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Transaction Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Transaction ID:', transactionId),
                  const SizedBox(height: 12),
                  _buildDetailRow('Merchant:', merchantName),
                  const SizedBox(height: 12),
                  _buildDetailRow('Amount Paid:', 'AED ${amount.toStringAsFixed(2)}'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Time:', _formatDateTime(timestamp)),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Done Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate back to home or wallet
                  context.go('/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.black,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$month $day, $year, $hour:$minute ${dateTime.hour >= 12 ? 'PM' : 'AM'}';
  }
}

// Helper function to show the modal
void showTransactionSuccessModal({
  required BuildContext context,
  required String transactionId,
  required String merchantName,
  required double amount,
  required DateTime timestamp,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => TransactionSuccessModal(
      transactionId: transactionId,
      merchantName: merchantName,
      amount: amount,
      timestamp: timestamp,
    ),
  );
}
