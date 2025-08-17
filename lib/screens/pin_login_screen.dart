import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../widgets/pin_input_widget.dart';
import '../utils/constant.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final PinService _pinService = PinService();
  String _currentPin = '';
  bool _isLoading = false;
  String _errorMessage = '';
  int _attemptCount = 0;
  static const int _maxAttempts = 5;

  void _onPinChanged(String pin) {
    setState(() {
      _currentPin = pin;
      _errorMessage = '';
      
      if (pin.length == 4) {
        _verifyPin();
      }
    });
  }

  Future<void> _verifyPin() async {
    setState(() {
      _isLoading = true;
    });

    final isValid = await _pinService.verifyPin(_currentPin);
    
    if (isValid) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      setState(() {
        _isLoading = false;
        _attemptCount++;
        _currentPin = '';
        
        if (_attemptCount >= _maxAttempts) {
          _errorMessage = 'Too many failed attempts. Please restart the app.';
        } else {
          _errorMessage = 'Incorrect PIN. ${_maxAttempts - _attemptCount} attempts remaining.';
        }
      });
    }
  }

  void _resetPin() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset PIN'),
        content: const Text(
          'Are you sure you want to reset your PIN? This will require you to set up a new PIN.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _pinService.resetPin();
              if (mounted) {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/pin-setup');
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo or icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF9A9E).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Title
                    Text(
                      ApplicationConstants.appName,
                      style: Theme.of(context).textTheme.displayLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Subtitle
                    Text(
                      'Enter your PIN',
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      'Please enter your 4-digit PIN to access your passwords',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    
                    // Error message
                    if (_errorMessage.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, 
                                 color: Colors.red[600], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: TextStyle(
                                  color: Colors.red[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // PIN input
                    PinInputWidget(
                      onPinChanged: _onPinChanged,
                      currentPin: _currentPin,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
              
              // Reset PIN option
              if (_attemptCount > 0)
                TextButton(
                  onPressed: _resetPin,
                  child: const Text(
                    'Forgot PIN? Reset',
                    style: TextStyle(
                      color: Color(0xFFFF9A9E),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}