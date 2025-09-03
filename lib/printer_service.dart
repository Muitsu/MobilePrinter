import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

/// A class that acts as a wrapper for the print_bluetooth_thermal package.
///
/// This class simplifies the process of interacting with a Bluetooth thermal printer
/// by providing a high-level API for common tasks like connecting, disconnecting,
/// and printing. It handles the underlying package calls and provides a
/// more convenient interface.
class PrinterService {
  static final PrinterService _instance = PrinterService._internal();

  factory PrinterService() {
    return _instance;
  }

  PrinterService._internal();

  /// Checks if a printer is currently connected.
  Future<bool> get isConnected async {
    bool permission = await PrintBluetoothThermal.isPermissionBluetoothGranted;
    debugPrint('Have permission? $permission');
    return await PrintBluetoothThermal.connectionStatus;
  }

  Future<List<BluetoothInfo>> getPairedDevices() async {
    try {
      final List<BluetoothInfo> devices =
          await PrintBluetoothThermal.pairedBluetooths;
      return devices;
    } catch (e) {
      debugPrint('Error getting paired devices: $e');
      return [];
    }
  }

  Future<bool> connect(String macAddress) async {
    try {
      final bool result = await PrintBluetoothThermal.connect(
        macPrinterAddress: macAddress,
      );
      if (result) {
        debugPrint('Successfully connected to printer with MAC: $macAddress');
      } else {
        debugPrint('Failed to connect to printer with MAC: $macAddress');
      }
      return result;
    } catch (e) {
      debugPrint('Error connecting to printer: $e');
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      final bool result = await PrintBluetoothThermal.disconnect;
      if (result) {
        debugPrint('Successfully disconnected from printer');
      } else {
        debugPrint('Failed to disconnect from printer');
      }
      return result;
    } catch (e) {
      debugPrint('Error disconnecting from printer: $e');
      return false;
    }
  }

  Future<bool> printTestReceipt() async {
    if (!await isConnected) {
      debugPrint('Printer is not connected. Cannot print.');
      return false;
    }

    try {
      List<int> bytes = [];

      // Add a header
      bytes += [27, 97, 1]; // Center align
      bytes += [27, 33, 16]; // Double height and width
      bytes += 'Test Receipt'.codeUnits;
      bytes += [10]; // Line feed
      bytes += [10]; // Line feed

      // Reset text style and add body
      bytes += [27, 33, 0]; // Reset to default
      bytes += [27, 97, 0]; // Left align
      bytes += '--------------------------------'.codeUnits;
      bytes += [10];
      bytes += 'Item 1: \$10.00'.codeUnits;
      bytes += [10];
      bytes += 'Item 2: \$5.50'.codeUnits;
      bytes += [10];
      bytes += 'Total: \$15.50'.codeUnits;
      bytes += [10];
      bytes += '--------------------------------'.codeUnits;
      bytes += [10];
      bytes += [10];
      bytes += [10];

      // Print the bytes
      await PrintBluetoothThermal.writeBytes(bytes);
      debugPrint('Successfully sent print job.');
      return true;
    } catch (e) {
      debugPrint('Error printing test receipt: $e');
      return false;
    }
  }
}
