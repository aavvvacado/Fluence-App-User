import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import 'transaction_success_modal.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final String merchantName;
  final String merchantCode;
  final double amount;

  const PaymentProcessingScreen({
    super.key,
    required this.merchantName,
    required this.merchantCode,
    required this.amount,
  });

  @override
  State<PaymentProcessingScreen> createState() => _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isProcessing = true;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _startProcessing();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startProcessing() async {
    _animationController.forward();
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      setState(() {
        _isProcessing = false;
        _isSuccess = true;
      });
      
      // Show success modal after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        showTransactionSuccessModal(
          context: context,
          transactionId: 'TX${DateTime.now().millisecondsSinceEpoch}',
          merchantName: widget.merchantName,
          amount: widget.amount,
          timestamp: DateTime.now(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _isProcessing ? null : IconButton(
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Processing Animation
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _isSuccess ? Colors.green : AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: _isSuccess
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 60,
                          )
                        : CircularProgressIndicator(
                            value: _animation.value,
                            strokeWidth: 4,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Status Text
              Text(
                _isProcessing ? 'Processing your payment...' : 'Payment successful!',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Merchant Info
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
                  children: [
                    Text(
                      widget.merchantName,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Code: ${widget.merchantCode}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'AED ${widget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (_isProcessing) ...[
                const SizedBox(height: 32),
                const Text(
                  'Please wait while we process your payment...',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
