// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mobile_printer/app_snackbar.dart';
import 'package:mobile_printer/radar_animation.dart';
import 'package:mobile_printer/printer_service.dart';

class SearchPrinterScreen extends StatefulWidget {
  const SearchPrinterScreen({super.key});

  @override
  State<SearchPrinterScreen> createState() => _SearchPrinterScreenState();
}

class _SearchPrinterScreenState extends State<SearchPrinterScreen> {
  final printerService = PrinterService();
  StreamSubscription<List<BluetoothDevice>>? _deviceSubscription;
  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  @override
  void initState() {
    super.initState();
    _startScan();
  }

  void _startScan() {
    _deviceSubscription = printerService
        .scanDevices(timeout: const Duration(seconds: 20))
        .listen((devices) {
          setState(() {
            _devices = devices;
          });
        });
    setSavedDevice();
  }

  void setSavedDevice() {
    setState(() {
      _selectedDevice = printerService.savedPrinter;
    });
  }

  @override
  void dispose() {
    _deviceSubscription?.cancel();
    printerService.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Connect Device",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Icon(Icons.help_outline, color: Color(0xFF00B4D8)),
          SizedBox(width: 15),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          RadarAnimation(),
          const SizedBox(height: 30),
          const Text(
            "Searching for nearby printers...",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Make sure your printer is in pairing mode.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Expanded(child: _buildDeviceList()),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                "Discovered Devices",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Spacer(),
              SizedBox(
                height: 10,
                width: 10,
                child: CircularProgressIndicator(
                  color: Color(0xFF00B4D8),
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: _devices.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final device = _devices[index];
                return ListTile(
                  tileColor: const Color(0xFFF8F9FB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: const Icon(
                    Icons.bluetooth,
                    color: Color(0xFF00B4D8),
                  ),
                  title: Text(
                    device.platformName.isEmpty
                        ? "Unknown Device"
                        : device.platformName,
                  ),
                  trailing:
                      _selectedDevice != null &&
                          device.remoteId.str == _selectedDevice!.remoteId.str
                      ? const Icon(Icons.check_circle, color: Color(0xFF00B4D8))
                      : const Icon(Icons.chevron_right),
                  onTap: () async {
                    if (await printerService.isConnected) {
                      final success = await printerService.disconnect();
                      if (success) {
                        AppSnackbar.showSuccess(
                          context,
                          "Success Disconnected",
                        );
                        setSavedDevice();
                      } else {
                        AppSnackbar.showError(context, "Failed Disconnect");
                      }
                    } else {
                      final success = await printerService.connect(device);
                      if (success) {
                        AppSnackbar.showSuccess(
                          context,
                          "Successfully Connected",
                        );
                        setSavedDevice();
                      } else {
                        AppSnackbar.showError(
                          context,
                          "Failed to Connect Device",
                        );
                      }
                    }
                  },
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Don't see your printer?",
                style: TextStyle(color: Color(0xFF00B4D8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
