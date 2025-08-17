import 'package:flutter/material.dart';

class PinInputWidget extends StatefulWidget {
  final Function(String) onPinChanged;
  final String currentPin;
  final bool isLoading;

  const PinInputWidget({
    super.key,
    required this.onPinChanged,
    required this.currentPin,
    this.isLoading = false,
  });

  @override
  State<PinInputWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  String _pin = '';

  @override
  void initState() {
    super.initState();
    _pin = widget.currentPin;
  }

  @override
  void didUpdateWidget(PinInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPin != oldWidget.currentPin) {
      setState(() {
        _pin = widget.currentPin;
      });
    }
  }

  void _onNumberPressed(String number) {
    if (_pin.length < 4 && !widget.isLoading) {
      setState(() {
        _pin += number;
      });
      widget.onPinChanged(_pin);
    }
  }

  void _onBackspacePressed() {
    if (_pin.isNotEmpty && !widget.isLoading) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
      widget.onPinChanged(_pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // PIN dots display
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < _pin.length 
                    ? const Color(0xFFFF9A9E)
                    : Colors.grey[300],
                border: Border.all(
                  color: const Color(0xFFFF9A9E),
                  width: 2,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 48),
        
        // Number pad
        if (widget.isLoading)
          const CircularProgressIndicator()
        else
          _buildNumberPad(),
      ],
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        // Row 1: 1, 2, 3
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('1'),
            _buildNumberButton('2'),
            _buildNumberButton('3'),
          ],
        ),
        const SizedBox(height: 16),
        
        // Row 2: 4, 5, 6
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('4'),
            _buildNumberButton('5'),
            _buildNumberButton('6'),
          ],
        ),
        const SizedBox(height: 16),
        
        // Row 3: 7, 8, 9
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton('7'),
            _buildNumberButton('8'),
            _buildNumberButton('9'),
          ],
        ),
        const SizedBox(height: 16),
        
        // Row 4: empty, 0, backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 70, height: 70), // Empty space
            _buildNumberButton('0'),
            _buildBackspaceButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFF0ED),
          border: Border.all(color: const Color(0xFFFFD6D9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9A9E).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2D1B1B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _onBackspacePressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFFF0ED),
          border: Border.all(color: const Color(0xFFFFD6D9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF9A9E).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            size: 24,
            color: Color(0xFF2D1B1B),
          ),
        ),
      ),
    );
  }
}