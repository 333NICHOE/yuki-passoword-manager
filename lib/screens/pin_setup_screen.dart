import 'package:flutter/material.dart';
import '../services/pin_service.dart';
import '../widgets/pin_input_widget.dart';
import '../utils/constant.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final PinService _pinService = PinService();
  String _currentPin = '';
  String _confirmPin = '';
  bool _isConfirmingPin = false;
  bool _isLoading = false;
  String _errorMessage = '';

  void _onPinChanged(String pin) {
    setState(() {
      _errorMessage = '';
      
      if (!_isConfirmingPin) {
        _currentPin = pin;
        if (pin.length == 4) {
          // Move to confirmation step
          _isConfirmingPin = true;
          _confirmPin = '';
        }
      } else {
        _confirmPin = pin;
        if (pin.length == 4) {
          _setupPin();
        }
      }
    });
  }

  Future<void> _setupPin() async {
    if (_currentPin != _confirmPin) {
      setState(() {
        _errorMessage = 'PINs do not match. Please try again.';
        _isConfirmingPin = false;
        _currentPin = '';
        _confirmPin = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await _pinService.setupPin(_currentPin);
    
    if (success) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to setup PIN. Please try again.';
        _isConfirmingPin = false;
        _currentPin = '';
        _confirmPin = '';
      });
    }
  }

  void _goBack() {
    if (_isConfirmingPin) {
      setState(() {
        _isConfirmingPin = false;
        _confirmPin = '';
        _errorMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              if (_isConfirmingPin)
                Row(
                  children: [
                    IconButton(
                      onPressed: _goBack,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),
              
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
                      _isConfirmingPin 
                          ? 'Confirm your PIN'
                          : 'Set up your PIN',
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      _isConfirmingPin
                          ? 'Please enter your PIN again to confirm'
                          : 'Create a 4-digit PIN to secure your passwords',
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
                      currentPin: _isConfirmingPin ? _confirmPin : _currentPin,
                      isLoading: _isLoading,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}