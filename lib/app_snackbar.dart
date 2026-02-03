import 'package:flutter/material.dart';

class AppSnackbar {
  static void showSuccess(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Color(0xFF242424),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: Colors.green.shade800,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Color(0xFF242424),
      child: Row(
        children: [
          Icon(Icons.error_outline_outlined, color: Colors.red.shade800),
          SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  static void showWarning(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Color(0xFF242424),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
          SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    show(
      context,
      message: message,
      backgroundColor: Color(0xFF242424),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.blue.shade800),
          SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.white54)),
          ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String message,
    Widget? child,
    Color backgroundColor = Colors.black87,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Clear existing snackbars to prevent queuing delays
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final snackBar = SnackBar(
      content:
          child ?? Text(message, style: const TextStyle(color: Colors.white)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Fixed the geometry error
      ),
      margin: const EdgeInsets.only(bottom: 30, left: 14, right: 14),
      duration: duration,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
