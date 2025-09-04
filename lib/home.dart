import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mobile_printer/printer_service.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final printerService = PrinterService();
  // At the top of your class
  StreamSubscription<List<BluetoothDevice>>? _deviceSubscription;
  List<BluetoothDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _deviceSubscription = printerService.scanDevices().listen((devices) {
      setState(() {
        _devices = devices;
      });
    });
  }

  @override
  void dispose() {
    _deviceSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final printer = _devices[index];
          return ListTile(
            title: Text(printer.advName),
            subtitle: Text(" ${printer.remoteId.str}"),
            onTap: () async {
              if (await printerService.isConnected) {
                await printerService.disconnect();
              } else {
                await printerService.connect(printer);
              }
            },
            trailing: IconButton(
              icon: const Icon(Icons.print),
              onPressed: () async {
                await printerService.testTicket();
              },
            ),
          );
        },
      ),
    );
  }
}
