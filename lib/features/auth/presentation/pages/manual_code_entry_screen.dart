import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class ManualCodeEntryScreen extends StatefulWidget {
  const ManualCodeEntryScreen({super.key});

  @override
  State<ManualCodeEntryScreen> createState() => _ManualCodeEntryScreenState();
}

class _ManualCodeEntryScreenState extends State<ManualCodeEntryScreen> {
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.black,
          ),
        ),
        title: const Text(
          'Pay Merchant',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Header
            const Text(
              'Enter Merchant Code',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              'Enter the merchant code manually',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 48),
            
            // Code Input Field
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Merchant Code',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codeController,
                    focusNode: _focusNode,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter code (e.g., CAFE123)',
                      hintStyle: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        color: Colors.grey,
                        letterSpacing: 1,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Example codes
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Example Codes:',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildExampleCode('CAFE123', 'Cafe Arabica'),
                  _buildExampleCode('REST456', 'Restaurant XYZ'),
                  _buildExampleCode('SHOP789', 'Shopping Mall'),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Continue Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _codeController.text.isNotEmpty ? _continueWithCode : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Continue',
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

  Widget _buildExampleCode(String code, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              code,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _continueWithCode() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    
    // Simulate merchant lookup
    final merchantData = _getMerchantByCode(code);
    
    if (merchantData != null) {
      context.push('/payment/amount', extra: merchantData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Merchant with code "$code" not found'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic>? _getMerchantByCode(String code) {
    // Simulate merchant lookup - in real app, this would be an API call
    final merchants = {
      'CAFE123': {
        'merchantName': 'Cafe Arabica',
        'merchantCode': 'CAFE123',
        'merchantIcon': Icons.local_cafe,
      },
      'REST456': {
        'merchantName': 'Restaurant XYZ',
        'merchantCode': 'REST456',
        'merchantIcon': Icons.restaurant,
      },
      'SHOP789': {
        'merchantName': 'Shopping Mall',
        'merchantCode': 'SHOP789',
        'merchantIcon': Icons.shopping_bag,
      },
    };
    
    return merchants[code];
  }
}
