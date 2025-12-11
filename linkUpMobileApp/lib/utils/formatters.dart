import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extract only digits from both values
    final newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final oldText = oldValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limit to 10 digits
    if (newText.length > 10) {
      return oldValue;
    }
    
    // Format the text
    String formatted = '';
    
    if (newText.length >= 10) {
      formatted = '(${newText.substring(0, 3)}) ${newText.substring(3, 6)}-${newText.substring(6, 10)}';
    } else if (newText.length >= 6) {
      formatted = '(${newText.substring(0, 3)}) ${newText.substring(3, 6)}-${newText.substring(6)}';
    } else if (newText.length >= 3) {
      formatted = '(${newText.substring(0, 3)}) ${newText.substring(3)}';
    } else {
      formatted = newText;
    }
    
    // Calculate cursor position
    int cursorPosition;
    
    // Check if user is deleting (backspace)
    final isDeleting = newText.length < oldText.length;
    
    if (isDeleting) {
      // When deleting, always place cursor at the end
      // This allows backspace to continue through formatting characters smoothly
      cursorPosition = formatted.length;
    } else {
      // When typing, calculate cursor position based on digit count
      cursorPosition = _getCursorPositionForDigitCount(newText.length, newText.length);
    }
    
    // Ensure cursor doesn't go beyond formatted text length
    cursorPosition = cursorPosition.clamp(0, formatted.length);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
  
  // Helper method to calculate cursor position based on digit count
  int _getCursorPositionForDigitCount(int totalDigits, int digitsBeforeCursor) {
    if (totalDigits == 0) {
      return 0;
    } else if (totalDigits <= 3) {
      // Format: (XXX)
      return 1 + digitsBeforeCursor.clamp(0, totalDigits);
    } else if (totalDigits <= 6) {
      // Format: (XXX) YYY
      if (digitsBeforeCursor <= 3) {
        return 1 + digitsBeforeCursor;
      } else {
        return 6 + (digitsBeforeCursor - 3);
      }
    } else {
      // Format: (XXX) YYY-ZZZZ
      if (digitsBeforeCursor <= 3) {
        return 1 + digitsBeforeCursor;
      } else if (digitsBeforeCursor <= 6) {
        return 6 + (digitsBeforeCursor - 3);
      } else {
        return 10 + (digitsBeforeCursor - 6);
      }
    }
  }
}

class CreditCardFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.length <= 4) {
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    } else if (text.length <= 8) {
      return TextEditingValue(
        text: '${text.substring(0, 4)} ${text.substring(4)}',
        selection: TextSelection.collapsed(offset: newValue.text.length),
      );
    } else if (text.length <= 12) {
      return TextEditingValue(
        text: '${text.substring(0, 4)} ${text.substring(4, 8)} ${text.substring(8)}',
        selection: TextSelection.collapsed(offset: newValue.text.length),
      );
    } else {
      return TextEditingValue(
        text: '${text.substring(0, 4)} ${text.substring(4, 8)} ${text.substring(8, 12)} ${text.substring(12, text.length > 16 ? 16 : text.length)}',
        selection: TextSelection.collapsed(offset: newValue.text.length),
      );
    }
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extract only digits from both values
    final newText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final oldText = oldValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Limit to 4 digits (MM/YY)
    if (newText.length > 4) {
      return oldValue;
    }
    
    // Count how many digits are before the cursor in the old formatted text
    int oldDigitsBeforeCursor = 0;
    final oldCursorPos = oldValue.selection.baseOffset;
    for (int i = 0; i < oldCursorPos && i < oldValue.text.length; i++) {
      if (RegExp(r'\d').hasMatch(oldValue.text[i])) {
        oldDigitsBeforeCursor++;
      }
    }
    
    // Count how many digits are before the cursor in the new raw text
    // This tells us where the user is typing
    int newDigitsBeforeCursor = 0;
    final newCursorPos = newValue.selection.baseOffset;
    for (int i = 0; i < newCursorPos && i < newValue.text.length; i++) {
      if (RegExp(r'\d').hasMatch(newValue.text[i])) {
        newDigitsBeforeCursor++;
      }
    }
    
    // Determine if user is deleting
    final isDeleting = newText.length < oldText.length;
    
    // Calculate target digit position for cursor
    int targetDigitPosition;
    if (isDeleting) {
      // When deleting, keep cursor at the same digit position (clamped)
      targetDigitPosition = oldDigitsBeforeCursor.clamp(0, newText.length);
    } else {
      // When typing, the cursor should be after the newly typed digit
      // If we're adding a digit, advance the position
      if (newText.length > oldText.length) {
        targetDigitPosition = newDigitsBeforeCursor.clamp(0, newText.length);
      } else {
        // Moving cursor without typing
        targetDigitPosition = newDigitsBeforeCursor.clamp(0, newText.length);
      }
    }
    
    // Format the text as MM/YY
    String formatted;
    if (newText.isEmpty) {
      formatted = '';
    } else if (newText.length <= 2) {
      formatted = newText;
    } else {
      formatted = '${newText.substring(0, 2)}/${newText.substring(2)}';
    }
    
    // Calculate cursor position in the formatted text
    int cursorPosition;
    if (formatted.isEmpty) {
      cursorPosition = 0;
    } else if (targetDigitPosition <= 2) {
      // Cursor is in the month part (positions 0-2)
      cursorPosition = targetDigitPosition;
    } else {
      // Cursor is in the year part (after the slash)
      // Format: "MM/YY" - positions: 0,1,2(slash),3,4
      cursorPosition = 3 + (targetDigitPosition - 2);
    }
    
    // Ensure cursor is within bounds
    cursorPosition = cursorPosition.clamp(0, formatted.length);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

