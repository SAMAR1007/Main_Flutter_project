import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../core/constants/app_colors.dart';
import '../core/providers/cart_provider.dart';
import '../core/providers/order_provider.dart';
import 'esewa_payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  String _paymentMethod = 'cash_on_delivery';
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<bool> _authenticateWithBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();

      if (!canCheck || !isDeviceSupported) {
        if (!mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication is not available on this device'),
            backgroundColor: Colors.orange,
          ),
        );
        // Allow proceeding if biometrics not available
        return true;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to proceed with eSewa payment',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );

      if (!authenticated && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }

      return authenticated;
    } catch (e) {
      debugPrint('Biometric auth error: $e');
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication error: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    // Require biometric authentication for eSewa payments
    if (_paymentMethod == 'esewa') {
      final authenticated = await _authenticateWithBiometrics();
      if (!authenticated) return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final shippingAddress = {
      'fullName': _fullNameController.text.trim(),
      'phoneNumber': _phoneNumberController.text.trim(),
      'street': _streetController.text.trim(),
      'city': _cityController.text.trim(),
      'state': _stateController.text.trim(),
      'postalCode': _postalCodeController.text.trim(),
      'country': 'Nepal',
    };

    // Step 1: Create the order
    final order = await orderProvider.createOrder(
      items: cartProvider.toOrderItems(),
      shippingAddress: shippingAddress,
      paymentMethod: _paymentMethod,
    );

    if (!mounted) return;

    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage ?? 'Failed to place order'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Step 2: If eSewa, initiate payment and open WebView
    if (_paymentMethod == 'esewa') {
      await _handleEsewaPayment(
        orderId: order.id,
        amount: order.totalAmount,
        cartProvider: cartProvider,
        orderProvider: orderProvider,
      );
    } else {
      // Cash on Delivery — order is already placed
      cartProvider.clearCart();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleEsewaPayment({
    required String orderId,
    required double amount,
    required CartProvider cartProvider,
    required OrderProvider orderProvider,
  }) async {
    // Get payment form data from backend
    final paymentData = await orderProvider.initiateEsewaPayment(
      orderId: orderId,
      amount: amount,
    );

    if (!mounted) return;

    if (paymentData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage ?? 'Failed to initiate payment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final formUrl = paymentData['formUrl'] as String;
    final formData = Map<String, dynamic>.from(paymentData['formData'] as Map);

    // Open eSewa payment portal in WebView
    final result = await Navigator.of(context).push<EsewaPaymentResult>(
      MaterialPageRoute(
        builder: (_) => EsewaPaymentScreen(
          formUrl: formUrl,
          formData: formData,
        ),
      ),
    );

    if (!mounted) return;

    if (result != null && result.success && result.encodedData != null) {
      // Verify payment with backend
      final verified = await orderProvider.verifyEsewaPayment(
        orderId: orderId,
        encodedData: result.encodedData!,
      );

      if (!mounted) return;

      if (verified) {
        cartProvider.clearCart();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment successful! Order confirmed.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderProvider.errorMessage ?? 'Payment verification failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // User cancelled or payment failed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment was cancelled or failed'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${cartProvider.totalItemCount} item(s)',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: Rs.${cartProvider.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Shipping Address Section
              const Text(
                'Shipping Address',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _fullNameController,
                decoration: _inputDecoration('Full Name', Icons.person_outline),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _phoneNumberController,
                decoration: _inputDecoration('Phone Number', Icons.phone_outlined),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _streetController,
                decoration: _inputDecoration('Street Address', Icons.home_outlined),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Street address is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: _inputDecoration('City', Icons.location_city_outlined),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _stateController,
                      decoration: _inputDecoration('State', Icons.map_outlined),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'State is required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _postalCodeController,
                decoration: _inputDecoration('Postal Code', Icons.markunread_mailbox_outlined),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Postal code is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Payment Method Section
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _paymentMethod == 'cash_on_delivery'
                        ? AppColors.primary
                        : Colors.grey[300]!,
                    width: _paymentMethod == 'cash_on_delivery' ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RadioListTile<String>(
                  title: const Text('Cash on Delivery'),
                  subtitle: const Text('Pay when you receive'),
                  value: 'cash_on_delivery',
                  groupValue: _paymentMethod,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => _paymentMethod = value!);
                  },
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _paymentMethod == 'esewa'
                        ? AppColors.primary
                        : Colors.grey[300]!,
                    width: _paymentMethod == 'esewa' ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RadioListTile<String>(
                  title: const Text('eSewa'),
                  subtitle: const Text('Pay via eSewa wallet'),
                  value: 'esewa',
                  groupValue: _paymentMethod,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    setState(() => _paymentMethod = value!);
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).padding.bottom,
        ),
        child: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            return ElevatedButton(
              onPressed: orderProvider.isLoading ? null : _placeOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                orderProvider.isLoading
                    ? 'Processing...'
                    : _paymentMethod == 'esewa'
                        ? 'Pay with eSewa - Rs.${cartProvider.totalPrice.toStringAsFixed(2)}'
                        : 'Place Order - Rs.${cartProvider.totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
