import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class PinService {
  static const String _pinKey = 'user_pin';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Hash the PIN for secure storage
  String _hashPin(String pin) {
    var bytes = utf8.encode(pin);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Check if PIN is already set up
  Future<bool> isPinSetup() async {
    try {
      final storedPin = await _storage.read(key: _pinKey);
      return storedPin != null && storedPin.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Set up a new PIN
  Future<bool> setupPin(String pin) async {
    try {
      if (pin.length != 4) {
        return false;
      }
      
      final hashedPin = _hashPin(pin);
      await _storage.write(key: _pinKey, value: hashedPin);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Verify PIN
  Future<bool> verifyPin(String pin) async {
    try {
      final storedPin = await _storage.read(key: _pinKey);
      if (storedPin == null) {
        return false;
      }
      
      final hashedPin = _hashPin(pin);
      return storedPin == hashedPin;
    } catch (e) {
      return false;
    }
  }

  // Change PIN (requires old PIN verification)
  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      final isOldPinValid = await verifyPin(oldPin);
      if (!isOldPinValid) {
        return false;
      }
      
      return await setupPin(newPin);
    } catch (e) {
      return false;
    }
  }

  // Reset PIN (for development/testing purposes)
  Future<void> resetPin() async {
    try {
      await _storage.delete(key: _pinKey);
    } catch (e) {
      // Handle error silently
    }
  }
}